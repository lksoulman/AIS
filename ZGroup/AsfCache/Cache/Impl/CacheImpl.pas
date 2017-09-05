unit CacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-8
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Vcl.Forms,
  CacheGF,
  Windows,
  Classes,
  SysUtils,
  NativeXml,
  GFDataSet,
  CacheTable,
  AppContext,
  ServiceType,
  CommonQueue,
  LiteCallUni,
  WNDataSetInf,
  SyncAsyncImpl,
  SQLiteAdapter,
  GFDataMngr_TLB,
  ExecutorThread,
  CacheOperateType,
  Generics.Collections;

const
  DLLNAME_SQLITE = 'Sqlite.dll';
  REPLACE_STR_JSID      = '!JSID';

type

  TCacheImpl = class(TSyncAsyncImpl)
  private
  protected
    // Cache ����
    FName: string;
    // �ǲ��ǳ�ʼ��
    FIsInit: Boolean;
    // �����ļ�
    FCfgFile: string;
    // GF ������������
    FServiceType: TServiceType;
    // ϵͳ��
    FSysTable: TCacheTable;
    // �������ݱ�
    FTables: TList<TCacheTable>;
    // �������ֵ�
    FTableDic: TDictionary<string, TCacheTable>;
    // ָ�����ݶ���
    FCacheGFQueue: TSafeSemaphoreQueue<TCacheGF>;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ���ݿ����ӹ���
    FCacheDataAdapter: TSQLiteAdapter;
    // ����ָ�����ݵĶ���
    FHandleIndicatorDataThread: TExecutorThread;

    // ���ر�����
    procedure LoadTables;
    // �ͷű�����
    procedure UnLoadTables;
    // ��ʼ�����ӻ���
    procedure InitConnCache;
    // �ͷ����ӻ���
    procedure UnInitConnCache;
    // ��ʼ��ϵͳ��
    procedure InitSysTable;
    // ��ʼ�����ݱ�
    procedure InitDataTables;
    // ����List�ж��ű�
    procedure ClearListTables;

    // �������� DB
    procedure SetAttachDB(ADBFile, ADBAlias, APassword: string);
    // ����ϵͳ��
    procedure UpdateSysTable(ATable: TCacheTable);
    // �������ݼ�������
    procedure UpdateData(ADataSet: IWNDataSet; ATable: TCacheTable; AFields: TList<IWNField>; AJSIDField: IWNField);
    // ɾ��ָ�����ݴӱ�����
    procedure DeleteData(ADataSet: IWNDataSet; ATable: TCacheTable; AIDField: IWNField; AJSIDField: IWNField);

    // ������ʱ��
    procedure CreateTempTable(ATable: TCacheTable);
    // ɾ����ʱ��
    procedure DeleteTempTable(ATable: TCacheTable);
    // ������ʱɾ����
    procedure CreateTempDeleteTable(ATable: TCacheTable);
    // ɾ����ʱɾ����
    procedure DeleteTempDeleteTable(ATable: TCacheTable);
    // ������
    function CreateTableByNode(ANode: TXmlNode): TCacheTable;
    // ͨ���±��ȡ��
    function GetTableByIndex(AIndex: Integer): TCacheTable;


    // ͬ���������ݵ�����
    procedure DoUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
    // ͬ��ɾ�����ݴӻ���
    procedure DoDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
    // ͬ����������
    procedure DoSyncUpdateData;
    // ͬ��ɾ������
    procedure DoSyncDeleteData;
    // ͬ���ӱ�����������ݺ���
    procedure DoAfterSyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); virtual;
    // ͬ���ӱ�����ɾ�����ݺ���
    procedure DoAfterSyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); virtual;
    // �첽����ָ���ȡ��������
    procedure DoASyncUpdateData;
    // �첽����ָ���ȡɾ������
    procedure DoASyncDeleteData;
    // �첽ָ���ȡ���·��ػص�
    procedure GFUpdateDataArrive(const GFData: IGFData);
    // �첽ָ���ȡɾ�����ػص�
    procedure GFDeleteDataArrive(const GFData: IGFData);
    // �̴߳������ݶ���
    procedure DoHandleDataQueueThreadExecute(Sender: TObject);
    // �첽�ӱ�����������ݺ���
    procedure DoAfterASyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); virtual;
    // �첽�ӱ�����ɾ�����ݺ���
    procedure DoAfterASyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); virtual;
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;

    // �ж� Cache �ǲ��Ǵ��ڱ�
    function IsExistCacheTable(AName: string): Boolean;
  end;

implementation

uses
  DB,
  Utils,
  FastLogLevel,
  AsfSdkExport;

const
  // XML �����ļ�
  XML_NODE_TABLE = 'Table';
  XML_NODE_SYSTable = 'SysTable';
  XML_NODE_NAME = 'Name';
  XML_NODE_VERSION = 'Version';
  XML_NODE_UPDATEMEM = 'UpdateMem';
  XML_NODE_UPDATEMEMFIELDKEY = 'UpdateMemFieldKey';
  XML_NODE_CREATESQL = 'CreateSql';
  XML_NODE_INSERTSQL = 'InsertSql';
  XML_NODE_DELETESQL = 'DeleteSql';
  XML_NODE_COLFIELDS = 'ColFields';
  XML_NODE_INDICATOR = 'Indicator';
  XML_NODE_DELETEINDICATOR = 'DeleteIndicator';

  FIELD_JSID = 'JSID';

  SYSTABLE_FIELD_TABLENAME = 'TableName';
  SYSTABLE_FIELD_STORAGE = 'Storage';
  SYSTABLE_FIELD_VERSION = 'Version';
  SYSTABLE_FIELD_MAXJSID = 'MaxJSID';
  SYSTABLE_FIELD_DELJSID = 'DelJSID';

  REPLACE_STR_TABLENAME = '#TableName';

  SQL_QUERY_SYSTABLE = 'SELECT TableName, Storage, Version, MaxJSID, DelJSID FROM SysTable';
  SQL_TEMP_TABLE_CREATE = 'CREATE TEMP TABLE IF NOT EXISTS %s AS SELECT * FROM %s LIMIT 0';
  SQL_TEMP_TABLE_DELETE = 'DELETE FROM %s';
  SQL_COPY_TABLE_TO_TABLE = 'INSERT OR REPLACE INTO %s SELECT * FROM %s';
  SQL_TEMP_DEL_TABLE_CREATE = 'CREATE TEMP TABLE IF NOT EXISTS %s ("RecID" BIGINT NOT NULL PRIMARY KEY)';
  SQL_TEMP_DEL_TABLE_INSERT = 'INSERT OR REPLACE INTO %s VALUES (?)';
  SQL_TEMP_DEL_TABLE_DELETE = 'DELETE FROM %s WHERE ID IN (SELECT RecID FROM %s)';


{ TCacheImpl }

constructor TCacheImpl.Create;
begin
  inherited;
  FIsInit := False;
  FServiceType := stBase;
  FTables := TList<TCacheTable>.Create;
  FTableDic := TDictionary<string, TCacheTable>.Create;
  FCacheGFQueue := TSafeSemaphoreQueue<TCacheGF>.Create;
  FCacheDataAdapter := TSQLiteAdapter.Create;
  FCacheDataAdapter.DLLName := DLLNAME_SQLITE;
  FCacheDataAdapter.LoadClassName := Self.ClassName;
  FHandleIndicatorDataThread := TExecutorThread.Create;
  FHandleIndicatorDataThread.ThreadMethod := DoHandleDataQueueThreadExecute;
end;

destructor TCacheImpl.Destroy;
begin
  FCacheDataAdapter.Free;
  FCacheGFQueue.Free;
  FTableDic.Free;
  FTables.Free;
  inherited;
end;

procedure TCacheImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure TCacheImpl.UnInitialize;
begin

  inherited UnInitialize;
end;

procedure TCacheImpl.SyncBlockExecute;
begin

end;

procedure TCacheImpl.AsyncNoBlockExecute;
begin

end;

function TCacheImpl.Dependences: WideString;
begin

end;

function TCacheImpl.IsExistCacheTable(AName: string): Boolean;
var
  LTable: TCacheTable;
begin
  if FTableDic.TryGetValue(AName, LTable)
    and Assigned(LTable) and LTable.IsCreate then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

procedure TCacheImpl.ClearListTables;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FTables.Count - 1 do begin
    if FTables.Items[LIndex] <> nil then begin
      FTables.Items[LIndex].Free;
    end;
  end;
  FTables.Clear;
end;

procedure TCacheImpl.LoadTables;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LNode: TXmlNode;
  LXml: TNativeXml;
  LNodeList: TList;
  LTable: TCacheTable;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    if FileExists(FCfgFile) then begin
      LXml := TNativeXml.Create(nil);
      try
        LXml.LoadFromFile(FCfgFile);
        LXml.XmlFormat := xfReadable;
        LNode := LXml.Root;

        if FSysTable <> nil then begin
          FSysTable.Free;
        end;

        FSysTable := CreateTableByNode(LNode.FindNode(XML_NODE_SYSTable));
        if FSysTable = nil then begin
          FastSysLog(llError, Format('[%s][LoadTables][%s] Cache create table is nil.', [Self.ClassName, XML_NODE_SYSTable]));
          Exit;
        end;

        ClearListTables;
        LNodeList := TList.Create;
        try
          LNode.FindNodes(XML_NODE_TABLE, LNodeList);
          for LIndex := 0 to LNodeList.Count - 1 do begin
            LTable := CreateTableByNode(LNodeList.Items[LIndex]);
            if LTable <> nil then begin
              LTable.IndexID := FTables.Add(LTable);
              FTableDic.AddOrSetValue(LTable.Name, LTable);
            end else begin
              FastSysLog(llError, Format('[%s][LoadTables] Cache create table is nil.', [Self.ClassName]));
              Exit;
            end;
          end;
        finally
          LNodeList.Free;
        end;
      finally
        LXml.Free;
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[%s][LoadTables] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheImpl.UnLoadTables;
begin
  ClearListTables;
  if FSysTable <> nil then begin
    FSysTable.Free;
  end;
end;

procedure TCacheImpl.InitConnCache;
begin
  FCacheDataAdapter.InitDataBaseConn;
end;

procedure TCacheImpl.UnInitConnCache;
begin
  FCacheDataAdapter.UnInitDataBaseConn;
end;

procedure TCacheImpl.InitSysTable;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LTable: TCacheTable;
  LDataSet: IWNDataSet;
  LNameField, LVersionField, LMaxField, LDelField: IWNField;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FCacheDataAdapter.ExecuteSql(FSysTable.CreateSql);
    LDataSet := FCacheDataAdapter.QuerySql(SQL_QUERY_SYSTABLE);
    if (LDataSet <> nil) then begin
      if LDataSet.RecordCount > 0 then begin
        LDataSet.First;
        LNameField := LDataSet.FieldByName(SYSTABLE_FIELD_TABLENAME);
        LVersionField := LDataSet.FieldByName(SYSTABLE_FIELD_VERSION);
        LMaxField := LDataSet.FieldByName(SYSTABLE_FIELD_MAXJSID);
        LDelField := LDataSet.FieldByName(SYSTABLE_FIELD_DELJSID);
        while not LDataSet.Eof do begin
          if FTableDic.TryGetValue(LNameField.AsString, LTable)
            and (LTable <> nil) then begin
            if LVersionField.AsInteger = LTable.Version then begin
              LTable.IsCreate := True;
            end else begin
              LTable.IsCreate := False;
            end;
            LTable.MaxJSID := LMaxField.AsInt64;
            LTable.DelJSID := LDelField.AsInt64;
          end;
          LDataSet.Next;
        end;
      end;
      LDataSet := nil;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[%s][InitSysTable] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheImpl.InitDataTables;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LTable: TCacheTable;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FTables.Count - 1 do begin
      LTable := FTables.Items[LIndex];
      if (LTable <> nil) and (not LTable.IsCreate) then begin
        FCacheDataAdapter.ExecuteSql(LTable.CreateSql);
        UpdateSysTable(LTable);
        LTable.IsCreate := True;
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[%s][InitDataTables] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheImpl.SetAttachDB(ADBFile, ADBAlias, APassword: string);
begin
  FCacheDataAdapter.SetAttachDB(ADBFile, ADBAlias, APassword);
end;

procedure TCacheImpl.UpdateSysTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(FSysTable.InsertSql, [ATable.Name,
      ATable.Storage, ATable.Version, ATable.MaxJSID, ATable.DelJSID]));
end;

procedure TCacheImpl.UpdateData(ADataSet: IWNDataSet; ATable: TCacheTable; AFields: TList<IWNField>; AJSIDField: IWNField);
var
  LIndex: Integer;
  LSql: AnsiString;
  LIsSuccess: Boolean;
  LAPIStmt: pSQLite3Stmt;
  LRetCode, LMaxJSID: Int64;
begin
  LIsSuccess := False;
  LMaxJSID := ATable.MaxJSID;
  FCacheDataAdapter.BeginWrite;
  try
    FCacheDataAdapter.StartTransaction;
    try
      try
        CreateTempTable(ATable);
        DeleteTempTable(ATable);
        LSql := AnsiString(StringReplace(ATable.InsertSql, REPLACE_STR_TABLENAME,
          ATable.TempName, [rfReplaceAll]));
        LRetCode := FCacheDataAdapter.Prepare(LSql, LAPIStmt);
        if LRetCode = 0 then begin
          ADataSet.First;
          while not ADataSet.Eof do begin
            FCacheDataAdapter.Reset(LAPIStmt);
            for LIndex := 0 to ATable.ColFields.Count - 1 do begin
              FCacheDataAdapter.BindField(LAPIStmt, AFields[LIndex], LIndex + 1);
            end;
            FCacheDataAdapter.Step(LAPIStmt);
            if (AJSIDField <> nil)
              and (not AJSIDField.IsNull)
              and (AJSIDField.AsInt64 > ATable.MaxJSID) then begin
              ATable.MaxJSID := AJSIDField.AsInt64;
            end;
            ADataSet.Next;
          end;
          FCacheDataAdapter.ExecuteSql(Format(SQL_COPY_TABLE_TO_TABLE, [ATable.Name,
            ATable.TempName]));
          DeleteTempTable(ATable);
          UpdateSysTable(ATable);
          FCacheDataAdapter.Commit;
          LIsSuccess := True;
        end;
      except
        on Ex: Exception do begin
          FastSysLog(llERROR, Format('[%s][UpdateData] Update is exception, exception is %s.', [Self.ClassName, Ex.Message]));
        end;
      end;
    finally
      if not LIsSuccess then begin
        ATable.MaxJSID := LMaxJSID;
        FCacheDataAdapter.Rollback;
      end;
      if Assigned(LAPIStmt) then begin
        FCacheDataAdapter.Finalize(LAPIStmt);
      end;
    end;
  finally
    FCacheDataAdapter.EndWrite;
  end;
end;

procedure TCacheImpl.DeleteData(ADataSet: IWNDataSet; ATable: TCacheTable; AIDField: IWNField; AJSIDField: IWNField);
var
  LRetCode: Int64;
  LSql: AnsiString;
  LDelJSID: Integer;
  LIsSuccess: Boolean;
  LAPIStmt: pSQLite3Stmt;
begin
  LIsSuccess := False;
  LDelJSID := ATable.DelJSID;
  FCacheDataAdapter.BeginWrite;
  try
    FCacheDataAdapter.StartTransaction;
    try
      try
        CreateTempDeleteTable(ATable);
        DeleteTempDeleteTable(ATable);
        LSql := AnsiString(Format(SQL_TEMP_DEL_TABLE_INSERT, [ATable.TempDelName]));
        LRetCode := FCacheDataAdapter.Prepare(LSql, LAPIStmt);
        if LRetCode = 0 then begin
          ADataSet.First;
          while not ADataSet.Eof do begin
            FCacheDataAdapter.Reset(LAPIStmt);
            FCacheDataAdapter.BindField(LAPIStmt, AIDField, 1);
            FCacheDataAdapter.Step(LAPIStmt);
            if (AJSIDField <> nil)
              and (not AJSIDField.IsNull)
              and (AJSIDField.AsInt64 > ATable.DelJSID) then begin
              ATable.DelJSID := AJSIDField.AsInt64;
            end;
            ADataSet.Next;
          end;
          FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_DEL_TABLE_DELETE, [ATable.Name, ATable.TempDelName]));
          DeleteTempDeleteTable(ATable);
          UpdateSysTable(ATable);
          FCacheDataAdapter.Commit;
          LIsSuccess := True;
        end;
      except
        on Ex: Exception do begin
          FastSysLog(llERROR, Format('[%s][DeleteData] Delete is exception, exception is %s.', [Self.ClassName, Ex.Message]));
        end;
      end;
    finally
      if not LIsSuccess then begin
        ATable.DelJSID := LDelJSID;
        FCacheDataAdapter.Rollback;
      end;
      if Assigned(LAPIStmt) then begin
        FCacheDataAdapter.Finalize(LAPIStmt);
      end;
    end;
  finally
    FCacheDataAdapter.EndWrite;
  end;
end;

procedure TCacheImpl.CreateTempTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_CREATE, [ATable.TempName, ATable.Name]));
end;

procedure TCacheImpl.DeleteTempTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_DELETE, [ATable.TempName]));
end;

procedure TCacheImpl.CreateTempDeleteTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_DEL_TABLE_CREATE, [ATable.TempDelName]));
end;

procedure TCacheImpl.DeleteTempDeleteTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_DELETE, [ATable.TempDelName]));
end;

function TCacheImpl.CreateTableByNode(ANode: TXmlNode): TCacheTable;
begin
  Result := nil;
  if ANode = nil then Exit;

  Result := TCacheTable.Create;
  Result.Name := Utils.GetStringByChildNodeName(ANode, XML_NODE_NAME);
  Result.Version := Utils.GetIntegerByChildNodeName(ANode, XML_NODE_VERSION, Result.Version);
  Result.UpdateMem := Utils.GetIntegerByChildNodeName(ANode, XML_NODE_UPDATEMEM, Result.UpdateMem);
  Result.UpdateMemFieldKey := Utils.GetStringByChildNodeName(ANode, XML_NODE_UPDATEMEMFIELDKEY);
  Result.CreateSql := Utils.GetStringByChildNodeName(ANode, XML_NODE_CREATESQL);
  Result.InsertSql := Utils.GetStringByChildNodeName(ANode, XML_NODE_INSERTSQL);
  Result.DeleteSql := Utils.GetStringByChildNodeName(ANode, XML_NODE_DELETESQL);
  Result.Indicator := Utils.GetStringByChildNodeName(ANode, XML_NODE_INDICATOR);
  Result.DeleteIndicator := Utils.GetStringByChildNodeName(ANode, XML_NODE_DELETEINDICATOR);
  Result.ColFields.DelimitedText := Utils.GetStringByChildNodeName(ANode, XML_NODE_COLFIELDS);
end;

function TCacheImpl.GetTableByIndex(AIndex: Integer): TCacheTable;
begin
  if (AIndex >= 0) and (AIndex < FTables.Count) then begin
    Result := FTables.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

procedure TCacheImpl.DoUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
var
  LIndex: Integer;
  LIsUpdate: Boolean;
  LFields: TList<IWNField>;
  LField, LJSIDField: IWNField;
begin
  LFields := TList<IWNField>.Create;
  try
    LIsUpdate := True;
    LJSIDField := ADataSet.FieldByName(FIELD_JSID);
    for LIndex := 0 to ATable.ColFields.Count - 1 do begin
      LField := ADataSet.FieldByName(ATable.ColFields.Strings[LIndex]);
      if LField <> nil then begin
        LFields.Add(LField);
      end else begin
        LIsUpdate := False;
        break;
      end;
    end;
    if LIsUpdate then begin
      UpdateData(ADataSet, ATable, LFields, LJSIDField);
    end;
  finally
    LFields.Free;
  end;
end;

procedure TCacheImpl.DoDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
var
  LFields: TList<IWNField>;
  LIDField, LJSIDField: IWNField;
begin
  LFields := TList<IWNField>.Create;
  try
    if (ADataSet.RecordCount > 0)
      and (ADataSet.FieldCount > 0) then begin
      LIDField := ADataSet.Fields(0);
      if LIDField <> nil then begin
        LJSIDField := ADataSet.FieldByName(FIELD_JSID);
        DeleteData(ADataSet, ATable, LIDField, LJSIDField);
      end;
    end;
  finally
    LFields.Free;
  end;
end;

procedure TCacheImpl.DoSyncUpdateData;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LTableTick: Cardinal;
{$ELSE}
  LTableTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LIndicator: string;
  LTable: TCacheTable;
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FTables.Count - 1 do begin

      Application.ProcessMessages;
      LTable := FTables.Items[LIndex];
      LTableTick := GetTickCount;
      try
        if LTable.Indicator <> '' then begin
          LIndicator := StringReplace(LTable.Indicator, REPLACE_STR_JSID,
            IntToStr(LTable.MaxJSID), [rfReplaceAll]);
          LDataSet := FAppContext.GFSyncHighQuery(FServiceType, LIndicator, LTable.IndexID, INFINITE);
          if LDataSet <> nil then begin
            DoUpdateCacheData(LTable, LDataSet);
            DoAfterSyncUpdateCacheData(LTable, LDataSet);
            LDataSet := nil;
          end;
        end;
      finally
        LTableTick := GetTickCount - LTableTick;
        FastSysLog(llSLOW, Format('[%s][DoSyncDeleteData][Table][%s] Sync use time is %d ms.', [Self.ClassName, LTable.Name, LTableTick]), LTableTick);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[%s][DoSyncUpdateData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheImpl.DoSyncDeleteData;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LTableTick: Cardinal;
{$ELSE}
  LTableTick: Cardinal;
{$ENDIF}
  LIndex: Integer;
  LIndicator: string;
  LTable: TCacheTable;
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    for LIndex := 0 to FTables.Count - 1 do begin
      Application.ProcessMessages;

      LTable := FTables.Items[LIndex];
      LTableTick := GetTickCount;
      try

        if LTable.DeleteIndicator <> '' then begin
          LIndicator := StringReplace(LTable.DeleteIndicator, REPLACE_STR_JSID,
            IntToStr(LTable.DelJSID), [rfReplaceAll]);
          LDataSet := FAppContext.GFSyncHighQuery(FServiceType, LIndicator, LTable.IndexID, INFINITE);
          if LDataSet <> nil then begin
            DoDeleteCacheData(LTable, LDataSet);
            DoAfterSyncDeleteCacheData(LTable, LDataSet);
            LDataSet := nil;
          end;
        end;
      finally
        LTableTick := GetTickCount - LTableTick;
        FastSysLog(llSLOW, Format('[%s][DoSyncDeleteData][Table][%s] Sync use time is %d ms.', [Self.ClassName, LTable.Name, LTableTick]), LTableTick);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[%s][DoSyncDeleteData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheImpl.DoAfterSyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin
  
end;

procedure TCacheImpl.DoAfterSyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TCacheImpl.DoASyncUpdateData;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LEvent: Int64;
  LIndex: Integer;
  LIndicator: string;
  LTable: TCacheTable;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    LEvent := 0;
    TOnGFDataArrive(LEvent) := GFUpdateDataArrive;
    for LIndex := 0 to FTables.Count - 1 do begin
      LTable := FTables.Items[LIndex];
      if LTable.Indicator <> '' then begin
        LIndicator := StringReplace(LTable.Indicator, REPLACE_STR_JSID,
          IntToStr(LTable.MaxJSID), [rfReplaceAll]);
        FAppContext.GFASyncQuery(FServiceType, LIndicator, LEvent, LTable.IndexID);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[%s][DoASyncUpdateData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheImpl.DoASyncDeleteData;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LEvent: Int64;
  LIndex: Integer;
  LIndicator: string;
  LTable: TCacheTable;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
     LEvent := 0;
    TOnGFDataArrive(LEvent) := GFUpdateDataArrive;
    for LIndex := 0 to FTables.Count - 1 do begin
      LTable := FTables.Items[LIndex];
      if LTable.DeleteIndicator <> '' then begin
        LIndicator := StringReplace(LTable.DeleteIndicator, REPLACE_STR_JSID,
          IntToStr(LTable.DelJSID), [rfReplaceAll]);
        FAppContext.GFASyncQuery(FServiceType, LIndicator, LEvent, LTable.IndexID);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[%s][DoASyncDeleteData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheImpl.GFUpdateDataArrive(const GFData: IGFData);
var
  LCacheGF: TCacheGF;
  LDateSet: IWNDataSet;
begin
  if GFData.Succeed then begin
    LDateSet := Utils.GFData2WNDataSet(GFData);
    if (LDateSet <> nil)
      and (LDateSet.RecordCount > 0) then begin
      LCacheGF := TCacheGF.Create;
      LCacheGF.ID := GFData.Tag;
      LCacheGF.DataSet := LDateSet;
      LCacheGF.OperateType := coInsert;
      FCacheGFQueue.Enqueue(LCacheGF);
      FCacheGFQueue.ReleaseSemaphore;
    end;
  end;
end;

procedure TCacheImpl.GFDeleteDataArrive(const GFData: IGFData);
var
  LDateSet: IWNDataSet;
  LCacheGF: TCacheGF;
begin
  if GFData.Succeed then begin
    LDateSet := Utils.GFData2WNDataSet(GFData);
    if (LDateSet <> nil)
      and (LDateSet.RecordCount > 0) then begin
      LCacheGF := TCacheGF.Create;
      LCacheGF.ID := GFData.Tag;
      LCacheGF.DataSet := LDateSet;
      LCacheGF.OperateType := coDelete;
      FCacheGFQueue.Enqueue(LCacheGF);
      FCacheGFQueue.ReleaseSemaphore;
    end;
  end;
end;

procedure TCacheImpl.DoHandleDataQueueThreadExecute(Sender: TObject);
var
  LCacheGF: TCacheGF;
  LTable: TCacheTable;
begin
  case WaitForSingleObject(FCacheGFQueue.Semaphore, 1000) of
    WAIT_OBJECT_0:
      begin
        LCacheGF := FCacheGFQueue.Dequeue;
        if LCacheGF <> nil then begin
          case LCacheGF.OperateType of
            coInsert:
              begin
                LTable := GetTableByIndex(LCacheGF.ID);
                if LTable <> nil then begin
                  DoUpdateCacheData(LTable, LCacheGF.DataSet);
                  DoAfterASyncUpdateCacheData(LTable, LCacheGF.DataSet);
                  LCacheGF.DataSet := nil;
                end;
              end;
            coDelete:
              begin
                LTable := GetTableByIndex(LCacheGF.ID);
                if LTable <> nil then begin
                  DoDeleteCacheData(LTable, LCacheGF.DataSet);
                  DoAfterASyncDeleteCacheData(LTable, LCacheGF.DataSet);
                  LCacheGF.DataSet := nil;
                end;
              end;
          end;
          LCacheGF.Free;
        end;
      end;
  end;
end;

procedure TCacheImpl.DoAfterASyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TCacheImpl.DoAfterASyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

end.
