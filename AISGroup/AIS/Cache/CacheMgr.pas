unit CacheMgr;

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
  Windows,
  Classes,
  SysUtils,
  NativeXml,
  GFDataSet,
  CacheTable,
  AppContext,
  CommonQueue,
  CacheGFData,
  LiteCallUni,
  WNDataSetInf,
  SQLiteAdapter,
  GFDataMngr_TLB,
  ExecutorThread,
  Generics.Collections;

const
  DLLNAME_SQLITE = 'Sqlite.dll';
  REPLACE_STR_JSID      = '!JSID';

type

  TCacheMgr = class(TInterfacedObject)
  private
  protected
    // Cache ����
    FName: string;
    // �ǲ��ǳ�ʼ��
    FIsInit: Boolean;
    // �����ļ�
    FCfgFile: string;
    // GF ������������
    FGFType: TGFType;
    // ϵͳ��
    FSysTable: TCacheTable;
    // �������ݱ�
    FTables: TList<TCacheTable>;
    // �������ֵ�
    FTableDic: TDictionary<string, TCacheTable>;
    // ָ�����ݶ���
    FCacheGFDataQueue: TSafeSemaphoreQueue<TCacheGFData>;
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
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // �ж� Cache �ǲ��Ǵ��ڱ�
    function IsExistCacheTable(AName: string): Boolean;
  end;

implementation

uses
  DB,
  Forms,
  Utils,
  FastLogLevel;

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


{ TCacheMgr }

constructor TCacheMgr.Create;
begin
  inherited;
  FIsInit := False;
  FGFType := gtBaseData;
  FTables := TList<TCacheTable>.Create;
  FTableDic := TDictionary<string, TCacheTable>.Create;
  FCacheGFDataQueue := TSafeSemaphoreQueue<TCacheGFData>.Create;
  FCacheDataAdapter := TSQLiteAdapter.Create;
  FCacheDataAdapter.DLLName := DLLNAME_SQLITE;
  FCacheDataAdapter.LoadClassName := Self.ClassName;
  FHandleIndicatorDataThread := TExecutorThread.Create;
  FHandleIndicatorDataThread.ThreadMethod := DoHandleDataQueueThreadExecute;
end;

destructor TCacheMgr.Destroy;
begin
  FCacheDataAdapter.Free;
  FCacheGFDataQueue.Free;
  FTableDic.Free;
  FTables.Free;
  inherited;
end;

function TCacheMgr.IsExistCacheTable(AName: string): Boolean;
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

procedure TCacheMgr.ClearListTables;
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

procedure TCacheMgr.LoadTables;
var
{$IFDEF DEBUG}
  LTick: Integer;
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
          FastAppLog(llError, Format('[%s][LoadTables][%s] Cache create table is nil.', [Self.ClassName, XML_NODE_SYSTable]));
          Exit;
        end;

        ClearListTables;
        LNodeList := TList.Create;
        try
          LNode.FindNodes(XML_NODE_TABLE, LNodeList);
          for LIndex := 0 to LNodeList.Count - 1 do begin
            LNode := LNodeList.Items[LIndex];
            LTable := CreateTableByNode(LNodeList.Items[LIndex]);
            if LTable <> nil then begin
              LTable.IndexID := FTables.Add(LTable);
              FTableDic.AddOrSetValue(LTable.Name, LTable);
            end else begin
              FastAppLog(llError, Format('[%s][LoadTables] Cache create table is nil.', [Self.ClassName]));
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
    FAppContext.AppLog(llSLOW, Format('[%s][LoadTables] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheMgr.UnLoadTables;
begin
  ClearListTables;
  if FSysTable <> nil then begin
    FSysTable.Free;
  end;
end;

procedure TCacheMgr.InitConnCache;
begin
  FCacheDataAdapter.InitDataBaseConn;
end;

procedure TCacheMgr.UnInitConnCache;
begin
  FCacheDataAdapter.UnInitDataBaseConn;
end;

procedure TCacheMgr.InitSysTable;
var
{$IFDEF DEBUG}
  LTick: Integer;
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
    FAppContext.AppLog(llSLOW, Format('[%s][InitSysTable] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheMgr.InitDataTables;
var
{$IFDEF DEBUG}
  LTick: Integer;
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
    FAppContext.AppLog(llSLOW, Format('[%s][InitDataTables] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheMgr.SetAttachDB(ADBFile, ADBAlias, APassword: string);
begin
  FCacheDataAdapter.SetAttachDB(ADBFile, ADBAlias, APassword);
end;

procedure TCacheMgr.UpdateSysTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(FSysTable.InsertSql, [ATable.Name,
      ATable.Storage, ATable.Version, ATable.MaxJSID, ATable.DelJSID]));
end;

procedure TCacheMgr.UpdateData(ADataSet: IWNDataSet; ATable: TCacheTable; AFields: TList<IWNField>; AJSIDField: IWNField);
var
  LPzTail: IntPtr;
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
          FastAppLog(llERROR, Format('[%s][UpdateData] Update is exception, exception is %s.', [Self.ClassName, Ex.Message]));
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

procedure TCacheMgr.DeleteData(ADataSet: IWNDataSet; ATable: TCacheTable; AIDField: IWNField; AJSIDField: IWNField);
var
  LPzTail: IntPtr;
  LRetCode: Int64;
  LSql: AnsiString;
  LIsSuccess: Boolean;
  LAPIStmt: pSQLite3Stmt;
  tmpIndex, LDelJSID: Integer;
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
          FastAppLog(llERROR, Format('[%s][DeleteData] Delete is exception, exception is %s.', [Self.ClassName, Ex.Message]));
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

procedure TCacheMgr.CreateTempTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_CREATE, [ATable.TempName, ATable.Name]));
end;

procedure TCacheMgr.DeleteTempTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_DELETE, [ATable.TempName]));
end;

procedure TCacheMgr.CreateTempDeleteTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_DEL_TABLE_CREATE, [ATable.TempDelName]));
end;

procedure TCacheMgr.DeleteTempDeleteTable(ATable: TCacheTable);
begin
  FCacheDataAdapter.ExecuteSql(Format(SQL_TEMP_TABLE_DELETE, [ATable.TempDelName]));
end;

function TCacheMgr.CreateTableByNode(ANode: TXmlNode): TCacheTable;
var
  tmpNode: TXmlNode;
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

function TCacheMgr.GetTableByIndex(AIndex: Integer): TCacheTable;
begin
  if (AIndex >= 0) and (AIndex < FTables.Count) then begin
    Result := FTables.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

procedure TCacheMgr.DoUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
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

procedure TCacheMgr.DoDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
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

procedure TCacheMgr.DoSyncUpdateData;
var
{$IFDEF DEBUG}
  LTick: Integer;
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
      LTableTick := GetTickCount;
      try
        LTable := FTables.Items[LIndex];
        if LTable.Indicator <> '' then begin
          LIndicator := StringReplace(LTable.Indicator, REPLACE_STR_JSID,
            IntToStr(LTable.MaxJSID), [rfReplaceAll]);
          LDataSet := FAppContext.GFSyncQueryHighData(FGFType, LIndicator, LTable.IndexID, INFINITE);
          if LDataSet <> nil then begin
            DoUpdateCacheData(LTable, LDataSet);
            DoAfterSyncUpdateCacheData(LTable, LDataSet);
            LDataSet := nil;
          end;
        end;
      finally
        LTableTick := GetTickCount - LTableTick;
        FAppContext.AppLog(llSLOW, Format('[%s][DoSyncDeleteData][Table][%s] Sync use time is %d ms.', [Self.ClassName, LTable.Name, LTableTick]), LTableTick);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.AppLog(llSLOW, Format('[%s][DoSyncUpdateData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheMgr.DoSyncDeleteData;
var
{$IFDEF DEBUG}
  LTick: Integer;
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

      LTableTick := GetTickCount;
      try
        LTable := FTables.Items[LIndex];
        if LTable.DeleteIndicator <> '' then begin
          LIndicator := StringReplace(LTable.DeleteIndicator, REPLACE_STR_JSID,
            IntToStr(LTable.DelJSID), [rfReplaceAll]);
          LDataSet := FAppContext.GFSyncQueryHighData(FGFType, LIndicator, LTable.IndexID, INFINITE);
          if LDataSet <> nil then begin
            DoDeleteCacheData(LTable, LDataSet);
            DoAfterSyncDeleteCacheData(LTable, LDataSet);
            LDataSet := nil;
          end;
        end;
      finally
        LTableTick := GetTickCount - LTableTick;
        FAppContext.AppLog(llSLOW, Format('[%s][DoSyncDeleteData][Table][%s] Sync use time is %d ms.', [Self.ClassName, LTable.Name, LTableTick]), LTableTick);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.AppLog(llSLOW, Format('[%s][DoSyncDeleteData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheMgr.DoAfterSyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin
  
end;

procedure TCacheMgr.DoAfterSyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TCacheMgr.DoASyncUpdateData;
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

    TOnGFDataArrive(LEvent) := GFUpdateDataArrive;
    for LIndex := 0 to FTables.Count - 1 do begin
      LTable := FTables.Items[LIndex];
      if LTable.Indicator <> '' then begin
        LIndicator := StringReplace(LTable.Indicator, REPLACE_STR_JSID,
          IntToStr(LTable.MaxJSID), [rfReplaceAll]);
        FAppContext.GFASyncQueryData(FGFType, LIndicator, LEvent, LTable.IndexID);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.AppLog(llSLOW, Format('[%s][DoASyncUpdateData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheMgr.DoASyncDeleteData;
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

    TOnGFDataArrive(LEvent) := GFUpdateDataArrive;
    for LIndex := 0 to FTables.Count - 1 do begin
      LTable := FTables.Items[LIndex];
      if LTable.DeleteIndicator <> '' then begin
        LIndicator := StringReplace(LTable.DeleteIndicator, REPLACE_STR_JSID,
          IntToStr(LTable.DelJSID), [rfReplaceAll]);
        FAppContext.GFASyncQueryData(gtBaseData, LIndicator, LEvent, LTable.IndexID);
      end;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.AppLog(llSLOW, Format('[%s][DoASyncDeleteData] Execute use time is %d ms.', [Self.ClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TCacheMgr.GFUpdateDataArrive(const GFData: IGFData);
var
  LDateSet: IWNDataSet;
  LCacheGFData: TCacheGFData;
begin
  if GFData.Succeed then begin
    LDateSet := Utils.GFData2WNDataSet(GFData);
    if (LDateSet <> nil)
      and (LDateSet.RecordCount > 0) then begin
      LCacheGFData := TCacheGFData.Create;
      LCacheGFData.ID := GFData.Tag;
      LCacheGFData.DataSet := LDateSet;
      LCacheGFData.DataType := GFInsert;
      FCacheGFDataQueue.Enqueue(LCacheGFData);
      FCacheGFDataQueue.ReleaseSemaphore;
    end;
  end;
end;

procedure TCacheMgr.GFDeleteDataArrive(const GFData: IGFData);
var
  LDateSet: IWNDataSet;
  LCacheGFData: TCacheGFData;
begin
  if GFData.Succeed then begin
    LDateSet := Utils.GFData2WNDataSet(GFData);
    if (LDateSet <> nil)
      and (LDateSet.RecordCount > 0) then begin
      LCacheGFData := TCacheGFData.Create;
      LCacheGFData.ID := GFData.Tag;
      LCacheGFData.DataSet := LDateSet;
      LCacheGFData.DataType := GFDelete;
      FCacheGFDataQueue.Enqueue(LCacheGFData);
      FCacheGFDataQueue.ReleaseSemaphore;
    end;
  end;
end;

procedure TCacheMgr.DoHandleDataQueueThreadExecute(Sender: TObject);
var
  LTable: TCacheTable;
  LData: TCacheGFData;
begin
  case WaitForSingleObject(FCacheGFDataQueue.Semaphore, 1000) of
    WAIT_OBJECT_0:
      begin
        LData := FCacheGFDataQueue.Dequeue;
        if LData <> nil then begin
          case LData.DataType of
            GFInsert:
              begin
                LTable := GetTableByIndex(LData.ID);
                if LTable <> nil then begin
                  DoUpdateCacheData(LTable, LData.DataSet);
                  DoAfterASyncUpdateCacheData(LTable, LData.DataSet);
                  LData.DataSet := nil;
                end;
              end;
            GFDelete:
              begin
                LTable := GetTableByIndex(LData.ID);
                if LTable <> nil then begin
                  DoDeleteCacheData(LTable, LData.DataSet);
                  DoAfterASyncDeleteCacheData(LTable, LData.DataSet);
                  LData.DataSet := nil;
                end;
              end;
          end;
          LData.Free;
        end;
      end;
  end;
end;

procedure TCacheMgr.DoAfterASyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TCacheMgr.DoAfterASyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

end.
