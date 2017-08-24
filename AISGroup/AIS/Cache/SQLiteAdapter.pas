unit SQLiteAdapter;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-8
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  DB,
  Uni,
  CRTypes,
  DBAccess,
  UniScript,
  LiteCallUni,
  LiteClassesUni,
  LiteFunctionUni,
  SQLiteUniProvider,
  WNDataSetInf,
  SQLiteDataSet;

type

  // Sqlite 数据库
  TSQLiteAdapter = class
  private
    // 加载类名称
    FLoadClassName: string;
    // 数据加载 DLL
    FDLLName: string;
    // 数据库名称
    FDataBaseName: string;
    // 数据库密码
    FDataPassword: string;
    // Sqlite3 API 接口
    FSQLite3API: TSQLite3API;
    // Sqlite 连接
    FSQLiteConn: TUniConnection;
    // 关联 Sql
    FAttachDBSql: string;
    // 关联数据库文件
    FAttachDBFile: string;
    // 关联数据库别名
    FAttachDBAlias: string;
    // 关联数据库密码
    FAttachDBPassword: string;
    // 是不是存在关联数据库文件
    FIsExistAttachDBFile: boolean;
    // 读写锁
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  protected
    // 创建数据库连接
    function CreateSQLiteConn: TUniConnection;
    // 创建关联数据库连接
    function CreateAttachDBSQLiteConn: TUniConnection;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 开始读锁
    procedure BeginRead;
    // 结束读锁
    procedure EndRead;
    // 开始写锁
    procedure BeginWrite;
    // 结束写锁
    procedure EndWrite;
    // 提交
    procedure Commit;
    // 回滚
    procedure Rollback;
    // 设置事务开始
    procedure StartTransaction;
    // 单步
    function Step(ASQLite3Stmt: pSQLite3Stmt): Int64;
    // 重新设置
    procedure Reset(ASQLite3Stmt: pSQLite3Stmt);
    // 完成处理
    procedure Finalize(ASQLite3Stmt: pSQLite3Stmt);
    // SQL Prepare
    function Prepare(const ASql: AnsiString; var ASQLite3Stmt: pSQLite3Stmt): Int64;
    // 初始化数据库连接
    procedure InitDataBaseConn;
    // 关闭数据连接
    procedure UnInitDataBaseConn;
    // 是不是存在数据库
    function IsExistDataBase: Boolean;
    // 执行 SQL
    procedure ExecuteSql(const ASql: string);
    // 执行脚本
    procedure ExecuteScript(const AScript: string);
    // 查询 SQL
    function QuerySql(const ASql: string): IWNDataSet;
    // 多数据库关联查询 SQL
    function AttachDBQuerySql(const ASql: string): IWNDataSet;
    // 关联数据库
    procedure SetAttachDB(ADBFile, ADBAlias, APassword: string);
    // 绑定数据集的数据
    procedure BindField(SQLite3Stmt: pSQLite3Stmt; AField: IWNField; ACount: Integer);

    property DLLName: string read FDLLName write FDLLName;
    property LoadClassName: string read FLoadClassName write FLoadClassName;
    property DataBaseName: string read FDataBaseName write FDataBaseName;
    property DataPassword: string read FDataPassword write FDataPassword;
  end;

implementation

uses
  Utils,
  FastLogLevel;

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
    FastAppLog(llError, Format('[TSQLiteDataBase][Commit] Load Class is %s, FSQLiteConn is nil.', [FLoadClassName]));
    Exit;
  end;

  FSQLiteConn.Commit;
end;

procedure TSQLiteAdapter.Rollback;
begin
  if FSQLiteConn = nil then begin
    FastAppLog(llError, Format('[TSQLiteDataBase][Rollback] Load Class is %s, FSQLiteConn is nil.', [FLoadClassName]));
    Exit;
  end;

  FSQLiteConn.Rollback;
end;

procedure TSQLiteAdapter.StartTransaction;
begin
  if FSQLiteConn = nil then begin
    FastAppLog(llError, Format('[TSQLiteDataBase][StartTransaction] Load Class is %s, FSQLiteConn is nil.', [FLoadClassName]));
    Exit;
  end;

  FSQLiteConn.StartTransaction;
end;

function TSQLiteAdapter.Step(ASQLite3Stmt: pSQLite3Stmt): Int64;
begin
  Result := -1;
  if FSQLite3API = nil then begin
    FastAppLog(llError, Format('[TSQLiteDataBase][Step] Load Class is %s, FSQLite3API is nil.', [FLoadClassName]));
    Exit;
  end;

  Result := FSQLite3API.sqlite3_step(ASQLite3Stmt);
end;

procedure TSQLiteAdapter.Reset(ASQLite3Stmt: pSQLite3Stmt);
begin
  if FSQLite3API = nil then begin
    FastAppLog(llError, Format('[TSQLiteDataBase][Reset] Load Class is %s, FSQLite3API is nil.', [FLoadClassName]));
    Exit;
  end;

  FSQLite3API.sqlite3_reset(ASQLite3Stmt);
end;

procedure TSQLiteAdapter.Finalize(ASQLite3Stmt: pSQLite3Stmt);
begin
  if FSQLite3API = nil then begin
    FastAppLog(llError, Format('[TSQLiteDataBase][Finalize] Load Class is %s, FSQLite3API is nil.', [FLoadClassName]));
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
    FastAppLog(llError, Format('[TSQLiteDataBase][Prepare] Load Class is %s, FSQLite3API is nil.', [FLoadClassName]));
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
        FastAppLog(llError, Format('[TSQLiteAdapter][InitDataBaseConn] Load Class is %s, FSqliteConn.Open is exception, exception is %s.', [FLoadClassName, Ex.Message]));
      end;
    end;
    try
      FSQLite3API := (TDBAccessUtils.GetIConnection(FSQLiteConn) as TSQLiteConnection).api;
    except
      on Ex: Exception do begin
        FastAppLog(llError, Format('[TSQLiteAdapter][InitDataBaseConn] Load Class is %s, Init FSQLite3API is exception, exception is %s.', [FLoadClassName, Ex.Message]));
      end;
    end;
  end else begin
    FastAppLog(llError, Format('[TSQLiteAdapter][InitDataBaseConn] Load Class is %s, FSqliteConn is nil.', [FLoadClassName]));
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FastAppLog(llSLOW, Format('[TSQLiteAdapter][InitDataBaseConn] Load Class is %s, execute use time %d ms.', [FLoadClassName, LTick]), LTick);
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
      FastAppLog(llError, Format('[TSQLiteAdapter][UnInitDataBaseConn] Load Class is %s, FSQLiteConn.Free or FSQLiteConn.Close is exception, exception is %s.', [FLoadClassName, Ex.Message]));
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
    FastAppLog(llWARN, Format('[TSQLiteAdapter][SetAttachDB] Load Class is %s, AttachDBFile is nil.', [FLoadClassName]));
    Exit;
  end;

  if not FileExists(ADBFile) then begin
    FIsExistAttachDBFile := True;
    FastAppLog(llWARN, Format('[TSQLiteAdapter][SetAttachDB] Load Class is %s, AttachDBFile(%s) is not exist.', [FLoadClassName, ADBFile]));
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
  LValue: string;
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
    FastAppLog(llError, Format('[TSQLiteAdapter][ExcuteSql] Load Class is %s, FSqliteConn is nil, Execute Sql(%s).', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, '')]));
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
        FastAppLog(llError, Format('[TSQLiteAdapter][ExcuteSql] Load Class is %s, Execute Sql(%s) is exception, exception is %s.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), Ex.Message]));
      end;
    end;
  finally
    LSqliteExec.Free;
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FastAppLog(llSLOW, Format('[TSQLiteAdapter][ExecuteSql] Load Class is %s, Execute Sql(%s) use time %d ms.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), LTick]), LTick);
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
    FastAppLog(llError, Format('[TSQLiteAdapter][ExcuteScript] Load Class is %s, FSqliteConn is nil, Execute Script(%s).', [FLoadClassName, Utils.ReplaceEnterNewLine(AScript, ' ')]));
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
        FastAppLog(llError, Format('[TSQLiteAdapter][ExcuteScript] Load Class is %s, Execute Script(%s) is exception, exception is %s.', [FLoadClassName, Utils.ReplaceEnterNewLine(AScript, ' '), Ex.Message]));
      end;
    end;
  finally
    LUniScript.Free;
  end;
{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FastAppLog(llSLOW, Format('[TSQLiteAdapter][ExecuteScript] Load Class is %s, Execute Script(%s) use time %d ms.', [FLoadClassName, Utils.ReplaceEnterNewLine(AScript, ' '), LTick]), LTick);
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
      FastAppLog(llError, Format('[TSQLiteAdapter][QuerySql] Load Class is %s, LSQLiteConn is nil, Query Sql(%s).', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, '')]));
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
          FastAppLog(llError, Format('[TSQLiteAdapter][QuerySql] Load Class is %s, Execute Sql(%s) is exception, exception is %s.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), Ex.Message]));
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
  FastAppLog(llSLOW, Format('[TSQLiteAdapter][QuerySql] Load Class is %s, Execute Sql(%s) use time %d ms.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), LTick]), LTick);
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
      FastAppLog(llError, Format('[TSQLiteAdapter][AttachDBQuerySql] Load Class is %s, LSQLiteConn is nil, Query Sql(%s).', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, '')]));
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
          FastAppLog(llError, Format('[TSQLiteAdapter][AttachDBQuerySql] Load Class is %s, Execute Sql(%s) is exception, exception is %s.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), Ex.Message]));
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
  FastAppLog(llSLOW, Format('[TSQLiteAdapter][AttachDBQuerySql] Load Class is %s, Execute Sql(%s) use time %d ms.', [FLoadClassName, Utils.ReplaceEnterNewLine(ASql, ''), LTick]), LTick);
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
            FastAppLog(llWARN, Format('[TSQLiteAdapter][BindField] Load Class is %s, fteBcd, fteblob, fteImage without handling', [FLoadClassName]));
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
      FastAppLog(llERROR, Format('[TSQLiteAdapter][BindField] Load Class is %s, AField.FieldType is %s.', [LValue]));
    end;
  end;
end;

end.

