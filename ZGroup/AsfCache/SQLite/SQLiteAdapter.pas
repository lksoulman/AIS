unit SQLiteAdapter;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SQLite Adapter
// Author：      lksoulman
// Date：        2017-8-8
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  DB,
  Uni,
  CRTypes,
  Windows,
  Classes,
  SysUtils,
  DBAccess,
  UniScript,
  AppContext,
  LiteCallUni,
  WNDataSetInf,
  SQLiteDataSet,
  LiteClassesUni,
  LiteFunctionUni,
  CommonRefCounter,
  SQLiteUniProvider;

type

  // SQLite Adapter
  TSQLiteAdapter = class(TAutoObject)
  private
    // Load Class Name
    FLoadClassName: string;
    // SQLite DLL
    FDLLName: string;
    // DataBase Name
    FDataBaseName: string;
    // DataBase Password
    FDataPassword: string;
    // Application Context
    FAppContext: IAppContext;
    // SQLite3 API
    FSQLite3API: TSQLite3API;
    // SQLite Connection
    FSQLiteConn: TUniConnection;
    // AttachDB Sql
    FAttachDBSql: string;
    // AttachDB File
    FAttachDBFile: string;
    // AttachDB Alias
    FAttachDBAlias: string;
    // AttachDB Password
    FAttachDBPassword: string;
    // Is Exist AttachDB File
    FIsExistAttachDBFile: boolean;
    // Read And Write Lock
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  protected
    // Create SQLite Connection
    function CreateSQLiteConn: TUniConnection;
    // Create AttachDB SQLite Connection
    function CreateAttachDBSQLiteConn: TUniConnection;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
    // Begin Read
    procedure BeginRead;
    // End Read
    procedure EndRead;
    // Begin Write
    procedure BeginWrite;
    // End Write
    procedure EndWrite;
    // Commit
    procedure Commit;
    // Rollback
    procedure Rollback;
    // StartTransaction
    procedure StartTransaction;
    // Step
    function Step(ASQLite3Stmt: pSQLite3Stmt): Int64;
    // Reset
    procedure Reset(ASQLite3Stmt: pSQLite3Stmt);
    // Finalize
    procedure Finalize(ASQLite3Stmt: pSQLite3Stmt);
    // SQL Prepare
    function Prepare(const ASql: AnsiString; var ASQLite3Stmt: pSQLite3Stmt): Int64;
    // Init DataBase Connection
    procedure InitDataBaseConn;
    // Un Init DataBase Connection
    procedure UnInitDataBaseConn;
    // Is Exist DataBase
    function IsExistDataBase: Boolean;
    // Execute SQL
    procedure ExecuteSql(const ASql: string);
    // Execute Script
    procedure ExecuteScript(const AScript: string);
    // Query SQL
    function QuerySql(const ASql: string): IWNDataSet;
    // AttachDBQuery SQL
    function AttachDBQuerySql(const ASql: string): IWNDataSet;
    // Set AttachBD
    procedure SetAttachDB(ADBFile, ADBAlias, APassword: string);
    // BindField
    procedure BindField(SQLite3Stmt: pSQLite3Stmt; AField: IWNField; ACount: Integer);

    property DLLName: string read FDLLName write FDLLName;
    property LoadClassName: string read FLoadClassName write FLoadClassName;
    property DataBaseName: string read FDataBaseName write FDataBaseName;
    property DataPassword: string read FDataPassword write FDataPassword;
  end;

implementation

uses
  Utils,
  LogLevel;

{ TSQLiteAdapter }

constructor TSQLiteAdapter.Create;
begin
  inherited;
  FIsExistAttachDBFile := False;
  FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

destructor TSQLiteAdapter.Destroy;
begin
  FReadWriteLock.Free;
  inherited;
end;

procedure TSQLiteAdapter.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TSQLiteAdapter.UnInitialize;
begin

  FAppContext := nil;
end;

procedure TSQLiteAdapter.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

procedure TSQLiteAdapter.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TSQLiteAdapter.BeginWrite;
begin
  FReadWriteLock.BeginWrite;
end;

procedure TSQLiteAdapter.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

procedure TSQLiteAdapter.Commit;
begin
  if FSQLiteConn = nil then begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteDataBase][Commit] Load Class is %s, FSQLiteConn is nil.', [FLoadClassName]));
    end;
    Exit;
  end;

  FSQLiteConn.Commit;
end;

procedure TSQLiteAdapter.Rollback;
begin
  if FSQLiteConn = nil then begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteDataBase][Rollback] Load Class is %s, FSQLiteConn is nil.', [FLoadClassName]));
    end;
    Exit;
  end;

  FSQLiteConn.Rollback;
end;

procedure TSQLiteAdapter.StartTransaction;
begin
  if FSQLiteConn = nil then begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteDataBase][StartTransaction] Load Class is %s, FSQLiteConn is nil.', [FLoadClassName]));
    end;
    Exit;
  end;

  FSQLiteConn.StartTransaction;
end;

function TSQLiteAdapter.Step(ASQLite3Stmt: pSQLite3Stmt): Int64;
begin
  Result := -1;
  if FSQLite3API = nil then begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteDataBase][Step] Load Class is %s, FSQLite3API is nil.', [FLoadClassName]));
    end;
    Exit;
  end;

  Result := FSQLite3API.sqlite3_step(ASQLite3Stmt);
end;

procedure TSQLiteAdapter.Reset(ASQLite3Stmt: pSQLite3Stmt);
begin
  if FSQLite3API = nil then begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteDataBase][Reset] Load Class is %s, FSQLite3API is nil.', [FLoadClassName]));
    end;
    Exit;
  end;

  FSQLite3API.sqlite3_reset(ASQLite3Stmt);
end;

procedure TSQLiteAdapter.Finalize(ASQLite3Stmt: pSQLite3Stmt);
begin
  if FSQLite3API = nil then begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteDataBase][Finalize] Load Class is %s, FSQLite3API is nil.', [FLoadClassName]));
    end;
    Exit;
  end;

  FSQLite3API.sqlite3_finalize(ASQLite3Stmt);
end;

function TSQLiteAdapter.Prepare(const ASql: AnsiString; var ASQLite3Stmt: pSQLite3Stmt): Int64;
var
  LTail: IntPtr;
begin
  if FSQLite3API = nil then begin
    Result := -1;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteDataBase][Prepare] Load Class is %s, FSQLite3API is nil.', [FLoadClassName]));
    end;
    Exit;
  end;

  Result := FSQLite3API.sqlite3_prepare_v2(FSQLite3API.SQLite, PAnsiChar(ASql), Length(ASql), ASQLite3Stmt, LTail);
end;

function TSQLiteAdapter.CreateSQLiteConn: TUniConnection;
begin
  if IsExistDataBase then begin
    Result := TUniConnection.Create(nil);
    Result.ProviderName := 'SQLite';
    Result.Database := FDataBaseName;
    Result.SpecificOptions.Values['ClientLibrary'] := FDLLName;
    if FDataPassword <> '' then begin
      FSQLiteConn.SpecificOptions.Values['EncryptionKey'] := FDataPassword;
    end;
  end else begin
    Result := nil;
  end;
end;

function TSQLiteAdapter.CreateAttachDBSQLiteConn: TUniConnection;
begin
//  if not FIsExistAttachDBFile then begin
//    Result := nil;
//    Exit;
//  end;
  Result := CreateSQLiteConn;
//  if Result <> nil then begin
//    if FAttachDBSql <> '' then begin
//      Result.ExecLiteSql(FAttachDBSql);
//    end else begin
//      FastAppLog(llError, Format('[TSQLiteDataBase][CreateAttachDBSQLiteConn] Load Class is %s, AttachDBSql is nil.', [FLoadClassName]));
//    end;
//  end;
end;

procedure TSQLiteAdapter.InitDataBaseConn;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}
  FSQLiteConn := TUniConnection.Create(nil);
  FSQLiteConn.ProviderName := 'SQLite';
  FSQLiteConn.Database := FDataBaseName;
  FSQLiteConn.SpecificOptions.Values['ClientLibrary'] := FDLLName;
  // 如果数据不存在就强制创建一个
  if not IsExistDataBase then begin
    FSQLiteConn.SpecificOptions.Values['ForceCreateDatabase'] := 'True';
  end;

  if FDataPassword <> '' then begin
    FSQLiteConn.SpecificOptions.Values['EncryptionKey'] := FDataPassword;
  end;

  if FSQLiteConn <> nil then begin
    try
      FSqliteConn.Open;
      ExecuteSql('PRAGMA cache_size=8000');
      ExecuteSql('PRAGMA temp_store=2');
      ExecuteSql('PRAGMA synchronous=NORMAL');
    except
      on Ex: Exception do begin
        if FAppContext <> nil then begin
          FAppContext.SysLog(llError, Format('[TSQLiteAdapter][InitDataBaseConn] Load Class is %s, FSqliteConn.Open is exception, exception is %s.', [FLoadClassName, Ex.Message]));
        end;
      end;
    end;
    try
      FSQLite3API := (TDBAccessUtils.GetIConnection(FSQLiteConn) as TSQLiteConnection).api;
    except
      on Ex: Exception do begin
        if FAppContext <> nil then begin
          FAppContext.SysLog(llError, Format('[TSQLiteAdapter][InitDataBaseConn] Load Class is %s, Init FSQLite3API is exception, exception is %s.', [FLoadClassName, Ex.Message]));
        end;
      end;
    end;
  end else begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteAdapter][InitDataBaseConn] Load Class is %s, FSqliteConn is nil.', [FLoadClassName]));
    end;
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  if FAppContext <> nil then begin
    FAppContext.SysLog(llSLOW, Format('[TSQLiteAdapter][InitDataBaseConn] Load Class is %s, execute use time %d ms.', [FLoadClassName, LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TSQLiteAdapter.UnInitDataBaseConn;
begin
  try
    if FSQLiteConn <> nil then begin
      FSQLiteConn.Close;
      FSQLiteConn.Free;
      FSQLiteConn := nil;
    end;
  except
    on Ex: Exception do begin
      if FAppContext <> nil then begin
        FAppContext.SysLog(llError, Format('[TSQLiteAdapter][UnInitDataBaseConn] Load Class is %s, FSQLiteConn.Free or FSQLiteConn.Close is exception, exception is %s.', [FLoadClassName, Ex.Message]));
      end;
    end;
  end;
end;

function TSQLiteAdapter.IsExistDataBase: Boolean;
begin
  Result := FileExists(FDataBaseName);
end;

procedure TSQLiteAdapter.SetAttachDB(ADBFile, ADBAlias, APassword: string);
var
  LSql, LAlias, LPassword: string;
begin
  FAttachDBSql := '';
  if ADBFile = '' then begin
    FIsExistAttachDBFile := False;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llWARN, Format('[TSQLiteAdapter][SetAttachDB] Load Class is %s, AttachDBFile is nil.', [FLoadClassName]));
    end;
    Exit;
  end;

  if not FileExists(ADBFile) then begin
    FIsExistAttachDBFile := True;
    if FAppContext <> nil then begin
      FAppContext.SysLog(llWARN, Format('[TSQLiteAdapter][SetAttachDB] Load Class is %s, AttachDBFile(%s) is not exist.', [FLoadClassName, ADBFile]));
    end;
    Exit;
  end;
  FAttachDBFile := ADBFile;
  FAttachDBAlias := ADBAlias;
  FAttachDBPassword := APassword;
  LAlias := ' AS #%s# ';
  LPassword := ' KEY #%s# ';
  LSql := Format(' ATTACH DATABASE #%s# ', [FAttachDBFile]);
  if FAttachDBAlias <> '' then begin
    LSql := LSql + Format(LAlias, [FAttachDBAlias]);
  end;
  if FAttachDBPassword <> '' then begin
    LSql := LSql + Format(LPassword, [FAttachDBPassword]);
  end;
  FAttachDBSql := LSql;
  ExecuteScript(FAttachDBSql);
end;

procedure TSQLiteAdapter.ExecuteSql(const ASql: string);
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LSqliteExec: TUniSQL;
{$ELSE}
  LSqliteExec: TUniSQL;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}
  if FSQLiteConn = nil then begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteAdapter][ExcuteSql] Load Class is %s, FSqliteConn is nil, Execute Sql(%s).', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, '')]));
    end;
    Exit;
  end;

  LSqliteExec := TUniSQL.Create(nil);
  try
    try
      LSqliteExec.Connection := FSQLiteConn;
      LSqliteExec.Sql.Text := ASql;
      LSqliteExec.Execute;
    except
      on Ex: Exception do begin
        if FAppContext <> nil then begin
          FAppContext.SysLog(llError, Format('[TSQLiteAdapter][ExcuteSql] Load Class is %s, Execute Sql(%s) is exception, exception is %s.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), Ex.Message]));
        end;
      end;
    end;
  finally
    LSqliteExec.Free;
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  if FAppContext <> nil then begin
    FAppContext.SysLog(llSLOW, Format('[TSQLiteAdapter][ExecuteSql] Load Class is %s, Execute Sql(%s) use time %d ms.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TSQLiteAdapter.ExecuteScript(const AScript: string);
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LUniScript: TUniScript;
{$ELSE}
  LUniScript: TUniScript;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}
  if FSQLiteConn = nil then begin
    if FAppContext <> nil then begin
      FAppContext.SysLog(llError, Format('[TSQLiteAdapter][ExcuteScript] Load Class is %s, FSqliteConn is nil, Execute Script(%s).', [FLoadClassName, Utils.ReplaceEnterNewLine(AScript, ' ')]));
    end;
    Exit;
  end;
  // 说明: 由于TUniScript多语句执行回滚有问题，暂时不使用，
  // 采用分号分隔语句的方式先替代处理
  LUniScript := TUniScript.Create(nil);
  try
    try
      LUniScript.Connection := FSQLiteConn;
      LUniScript.Sql.Text := AScript;
      LUniScript.Execute;
    except
      on Ex: Exception do begin
        if FAppContext <> nil then begin
          FAppContext.SysLog(llError, Format('[TSQLiteAdapter][ExcuteScript] Load Class is %s, Execute Script(%s) is exception, exception is %s.', [FLoadClassName, Utils.ReplaceEnterNewLine(AScript, ' '), Ex.Message]));
        end;
      end;
    end;
  finally
    LUniScript.Free;
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  if FAppContext <> nil then begin
    FAppContext.SysLog(llSLOW, Format('[TSQLiteAdapter][ExecuteScript] Load Class is %s, Execute Script(%s) use time %d ms.', [FLoadClassName, Utils.ReplaceEnterNewLine(AScript, ' '), LTick]), LTick);
  end;
{$ENDIF}
end;

function TSQLiteAdapter.QuerySql(const ASql: string): IWNDataSet;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LQuery: TUniQuery;
  LSQLiteConn: TUniConnection;
{$ELSE}
LQuery: TUniQuery;
  LSQLiteConn: TUniConnection;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}
  Result := nil;
  FReadWriteLock.BeginRead;
  try
    LSQLiteConn := CreateSQLiteConn;
    if LSQLiteConn = nil then begin
      if FAppContext <> nil then begin
        FAppContext.SysLog(llError, Format('[TSQLiteAdapter][QuerySql] Load Class is %s, LSQLiteConn is nil, Query Sql(%s).', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, '')]));
      end;
      Exit;
    end;

    LQuery := TUniQuery.Create(nil);
    LQuery.Disconnected := True;
    LQuery.ReadOnly := True;
    LQuery.FetchRows := 10000;
    LQuery.Connection := LSQLiteConn;
    LQuery.Sql.Text := ASql;
    try
      try
        LQuery.Open;
      except
        on Ex: Exception do begin
          if FAppContext <> nil then begin
            FAppContext.SysLog(llError, Format('[TSQLiteAdapter][QuerySql] Load Class is %s, Execute Sql(%s) is exception, exception is %s.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), Ex.Message]));
          end;
        end;
      end;
      if LQuery.RecordCount = 10000 then begin
        TDBAccessUtils.SetFetchAll(LQuery, True);
      end;
      Result := TSQLiteDataSet.Create(LQuery);
    finally
      LSQLiteConn.Close;
    end;
  finally
    FReadWriteLock.EndRead;
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  if FAppContext <> nil then begin
    FAppContext.SysLog(llSLOW, Format('[TSQLiteAdapter][QuerySql] Load Class is %s, Execute Sql(%s) use time %d ms.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), LTick]), LTick);
  end;
{$ENDIF}
end;

function TSQLiteAdapter.AttachDBQuerySql(const ASql: string): IWNDataSet;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
  LQuery: TUniQuery;
  LSQLiteConn: TUniConnection;
{$ELSE}
LQuery: TUniQuery;
  LSQLiteConn: TUniConnection;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}
  Result := nil;
  FReadWriteLock.BeginRead;
  try
    LSQLiteConn := CreateSQLiteConn;
    if LSQLiteConn = nil then begin
      if FAppContext <> nil then begin
        FAppContext.SysLog(llError, Format('[TSQLiteAdapter][AttachDBQuerySql] Load Class is %s, LSQLiteConn is nil, Query Sql(%s).', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, '')]));
      end;
      Exit;
    end;

    LQuery := TUniQuery.Create(nil);
    LQuery.Disconnected := True;
    LQuery.ReadOnly := True;
    LQuery.FetchRows := 10000;
    LQuery.Connection := LSQLiteConn;
    LQuery.Sql.Text := ASql;
    try
      try
        LQuery.Open;
      except
        on Ex: Exception do begin
          if FAppContext <> nil then begin
            FAppContext.SysLog(llError, Format('[TSQLiteAdapter][AttachDBQuerySql] Load Class is %s, Execute Sql(%s) is exception, exception is %s.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), Ex.Message]));
          end;
        end;
      end;
      if LQuery.RecordCount = 10000 then begin
        TDBAccessUtils.SetFetchAll(LQuery, True);
      end;
      Result := TSQLiteDataSet.Create(LQuery);
    finally
      LSQLiteConn.Close;
    end;
  finally
    FReadWriteLock.EndRead;
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  if FAppContext <> nil then begin
    FAppContext.SysLog(llSLOW, Format('[TSQLiteAdapter][AttachDBQuerySql] Load Class is %s, Execute Sql(%s) use time %d ms.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TSQLiteAdapter.BindField(SQLite3Stmt: pSQLite3Stmt; AField: IWNField; ACount: Integer);
var
  LValue: AnsiString;
begin
  try
    if not AField.IsNull then begin
      case AField.FieldType of
        fteVarchar, fteChar:
          begin
            LValue := Utf8Encode(AField.AsString);
            FSQLite3API.sqlite3_bind_text(SQLite3Stmt, ACount, PAnsiChar(LValue),
              -1, SQLITE_TRANSIENT);
          end;
        fteDatetime:
          begin
            LValue := AnsiString(FormatDateTime('YYYY-MM-DD hh:nn:ss zzz',
              AField.AsDateTime));
            FSQLite3API.sqlite3_bind_text(SQLite3Stmt, ACount, PAnsiChar(LValue),
              -1, SQLITE_TRANSIENT);
          end;
        fteInteger, fteBool:
          FSQLite3API.sqlite3_bind_int(SQLite3Stmt, ACount, AField.AsInteger);
        fteInteger64:
          FSQLite3API.sqlite3_bind_int64(SQLite3Stmt, ACount, AField.AsInt64);
        fteFloat:
          FSQLite3API.sqlite3_bind_double(SQLite3Stmt, ACount, AField.AsFloat);
        fteBcd, fteblob, fteImage:
          begin
            if FAppContext <> nil then begin
              FAppContext.SysLog(llWARN, Format('[TSQLiteAdapter][BindField] Load Class is %s, fteBcd, fteblob, fteImage without handling', [FLoadClassName]));
            end;
          end;
      end;
    end else begin
      FSQLite3API.sqlite3_bind_null(SQLite3Stmt, ACount);
    end;
  except
    on Ex: Exception do begin
      case AField.FieldType of
        fteVarchar:
          LValue := 'fteVarchar';
        fteChar:
          LValue := 'fteChar';
        fteDatetime:
          LValue := 'fteDatetime';
        fteInteger:
          LValue := 'fteInteger';
        fteBool:
          LValue := 'fteBool';
        fteInteger64:
          LValue := 'fteInteger64';
        fteFloat:
          LValue := 'fteFloat';
        fteBcd:
          LValue := 'fteBcd';
        fteblob:
          LValue := 'fteblob';
        fteImage:
          LValue := 'fteImage';
      end;
      if FAppContext <> nil then begin
        FAppContext.SysLog(llERROR, Format('[TSQLiteAdapter][BindField] Load Class is %s, AField.FieldType is %s.', [LValue]));
      end;
    end;
  end;
end;

end.

