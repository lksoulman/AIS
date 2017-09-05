unit HqAuthImpl;

interface

uses
  HqAuth,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  WNDataSetInf,
  SyncAsyncImpl,
  Generics.Collections;

type

  // Hq authority interface implementation
  THqAuthImpl = class(TSyncAsyncImpl, IHqAuth)
  private
    // is not has HK Real authority
    FIsHasHKReal: Boolean;
    // is not has Level2 authority
    FIsHasLevel2: Boolean;
    // LevelII 登录用户名
    FLevel2UserName: string;
    // LevelII 登录密码
    FLevel2Password: string;
  protected
    // 获取港股实时权限数据
    procedure DoGetHKReal;
    //  获取LevelII权限数据
    procedure DoGetLevel2;
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
    // blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;

    { IHqAuth }

    // is not has HK Real authority
    function GetIsHasHKReal: Boolean; safecall;
    // is not has Level2 authority
    function GetIsHasLevel2: Boolean; safecall;
    // Get Level2 username
    function GetLevel2UserName: WideString; safecall;
    // Get Level2 password
    function GetLevel2Password: WideString; safecall;
  end;

implementation

uses
  LoginMgr,
  LoginType,
  ServiceType,
  FastLogLevel,
  AsfSdkExport;

{ THqAuthImpl }

constructor THqAuthImpl.Create;
begin
  inherited;
  FIsHasHKReal := False;
  FIsHasLevel2 := False;
end;

destructor THqAuthImpl.Destroy;
begin
  inherited;
end;

procedure THqAuthImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure THqAuthImpl.UnInitialize;
begin

  FAppContext := nil;
end;

procedure THqAuthImpl.SyncBlockExecute;
begin
  if (FAppContext.GetLoginMgr <> nil) then begin
    if (FAppContext.GetLoginMgr as ILoginMgr).IsLoginGF(ltBase) then begin
      DoGetLevel2;
      DoGetHKReal;
    end else begin
      FastSysLog(llERROR, '[THqAuthImpl][SyncBlockExecute] GetLoginMgr.IsLoginGF(lGFBase) return is false, permission is not load.');
    end;
  end else begin
    FastSysLog(llERROR, '[THqAuthImpl][SyncBlockExecute] GetLoginMgr is nil');
  end;
end;

procedure THqAuthImpl.AsyncNoBlockExecute;
begin

end;

function THqAuthImpl.Dependences: WideString;
begin
  Result := Format('%s', [GUIDToString(ILoginMgr)]);
end;

function THqAuthImpl.GetIsHasHKReal: Boolean;
begin
  Result := FIsHasHKReal;
end;

function THqAuthImpl.GetIsHasLevel2: Boolean;
begin
  Result := FIsHasLevel2;
end;

function THqAuthImpl.GetLevel2UserName: WideString;
begin
  Result := FLevel2UserName;
end;

function THqAuthImpl.GetLevel2Password: WideString;
begin
  Result := FLevel2Password;
end;

procedure THqAuthImpl.DoGetHKReal;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FIsHasHKReal := False;
    LDataSet := FAppContext.GFSyncHighQuery(stBase, 'USER_QX_HK()', 0, 5000);
    if LDataSet <> nil then begin
      if LDataSet.RecordCount > 0 then begin
        LDataSet.First;
        if (LDataSet.FieldCount > 0)
          and (not LDataSet.Fields(0).IsNull) then begin
          FIsHasHKReal := (LDataSet.Fields(0).AsInteger > 0);
        end else begin
          FastIndicatorLog(llERROR, Format('[THqAuthImpl][DoGetHKReal] [Indicator][%s] Return data fieldcount is 0 or field data is nil.', ['USER_QX_HK()']));
        end;
      end else begin
        FastIndicatorLog(llERROR, Format('[THqAuthImpl][DoGetHKReal] [Indicator][%s] Return data is nil.', ['USER_QX_HK()']));
      end;
    end else begin
      FastIndicatorLog(llERROR, Format('[THqAuthImpl][DoGetHKReal] [Indicator][%s] Return data is nil.', ['USER_QX_HK()']));
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[THqAuthImpl][DoGetHKReal] Load HKReal data to dictionary use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure THqAuthImpl.DoGetLevel2;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FIsHasLevel2 := False;
    LDataSet := FAppContext.GFSyncHighQuery(stBase, 'USER_LEVEL2_INFO()', 0, 5000);
    if LDataSet <> nil then begin
      if LDataSet.RecordCount > 0 then begin
        LDataSet.First;
        if (LDataSet.FieldCount > 2) then begin
          FLevel2UserName := LDataSet.Fields(0).AsString;
          FLevel2Password := LDataSet.Fields(1).AsString;
          FIsHasLevel2 := True;
        end else begin
          FastIndicatorLog(llERROR, Format('[THqAuthImpl][DoGetLevel2] [Indicator][%s] Return data fieldcount low 2.', ['USER_LEVEL2_INFO()']));
        end;
      end else begin
        FastIndicatorLog(llERROR, Format('[THqAuthImpl][DoGetLevel2] [Indicator][%s] Return data is nil.', ['USER_LEVEL2_INFO()']));
      end;
    end else begin
      FastIndicatorLog(llERROR, Format('[THqAuthImpl][DoGetLevel2] [Indicator][%s] Return data is nil.', ['USER_LEVEL2_INFO()']));
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[THqAuthImpl][DoGetLevel2] Load LevelII data to dictionary use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

end.
