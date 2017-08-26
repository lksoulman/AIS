unit ServiceAssetImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Service,
  SyncAsync,
  AppContext,
  ServiceImpl,
  ServiceAsset,
  GFDataMngr_TLB;

type

  TServiceAssetImpl = class(TGFServiceImpl, IServiceAsset)
  private
  protected
    // 登录
    procedure DoUserLogin(AErrorCode: Integer; const AValue: AnsiString); override;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ISyncAsync }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); override;
    // 释放不需要的资源
    procedure UnInitialize; override;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; override;
    // 同步执行方法
    procedure SyncExecute; override;
    // 异步执行方法
    procedure AsyncExecute; override;

    { IGFServiceAsset }

    // 设置代理
    function SetProxy: Boolean; safecall;
    // 获取 GF 数据服务接口
    function GetGFDataManager: IGFDataManager; safecall;
    // 重新设置密码
    function PasswordReset(AUserName, AOldPassword, ANewPassword: WideString; var AErrorCode: Integer; var AErrorMsg: WideString): Boolean; safecall;
    // 聚源用户登录资产服务方法
    function GilUserLogin(AServerUrl, AUserName, AUserPassword: WideString; var APasswordInfo, AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
    // UFX 用户登录资产服务方法
    function UFXUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
    // PBox 用户登录资产服务方法
    function PBoxUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
  end;

implementation

uses
  Config,
  LoginMgr,
  FastLogLevel,
  ServiceConst;

{ TServiceAssetImpl }

constructor TServiceAssetImpl.Create;
begin
  Inherited;

end;

destructor TServiceAssetImpl.Destroy;
begin

  Inherited;
end;

procedure TServiceAssetImpl.Initialize(AContext: IAppContext);
begin
  Inherited Initialize(AContext);
end;

procedure TServiceAssetImpl.UnInitialize;
begin
  Inherited UnInitialize;
end;

function TServiceAssetImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TServiceAssetImpl.SyncExecute;
begin

end;

procedure TServiceAssetImpl.AsyncExecute;
begin

end;

function TServiceAssetImpl.SetProxy: Boolean;
begin
  DoSetProxy;
end;

function TServiceAssetImpl.GetGFDataManager: IGFDataManager;
begin
  Result := FGFDataManager;
end;

function TServiceAssetImpl.PasswordReset(AUserName, AOldPassword, ANewPassword: WideString; var AErrorCode: Integer; var AErrorMsg: WideString): Boolean;
begin
  Result := False;
  AErrorCode := 0;
  AErrorMsg := '';
  if FServerUrl = '' then Exit;

  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_ASSET_NIL;
    Exit;
  end;

  SetProxy;
  try
    Result := FGFDataManager.PassSetup(0, FServerUrl, AUserName, AOldPassword, ANewPassword, AErrorCode, AErrorMsg);
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_ASSET_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.PasswordReset] FGFDataManager.PassSetup Exception, Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, AErrorCode, AErrorMsg]));
    end;
  end;
end;

function TServiceAssetImpl.GilUserLogin(AServerUrl, AUserName, AUserPassword: WideString; var APasswordInfo, AErrorMsg: WideString; var AErrorCode: Integer): Boolean;
var
  LErrorCode: Integer;
  LErrorMsg: WideString;
begin
  Result := False;
  AErrorMsg := '';
  AErrorCode := ECODE_OTHER;
  FServerUrl := AServerUrl;
  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_ASSET_NIL;
    Exit;
  end;

  SetProxy;
  try
    AErrorMsg := FGFDataManager.JYUserLogin(0, AServerUrl, AUserName, AUserPassword, LErrorCode, LErrorMsg, APasswordInfo);
    if LErrorCode = 0 then begin
      AErrorCode := ECODE_SUCCESS;
      Result := True;
    end else if LErrorCode = -1003 then begin
      AErrorCode := ECODE_SERVICE_ASSET_NETWORK_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] Network is Except, (Url=%s), (ErrorMsg=%s)', [AServerUrl, AErrorMsg]));
    end else begin
      AErrorMsg := LErrorMsg;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] return other error, (ErrorCode=%d), (ErrorMsg=%s)', [LErrorCode, LErrorMsg]));
    end;
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_ASSET_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] FGFDataManager.JYUserLogin is Exception, Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, LErrorCode, LErrorMsg]));
    end;
  end;
end;

function TServiceAssetImpl.UFXUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean;
var
  LErrorCode: Integer;
  LErrorMsg: WideString;
begin
  Result := False;
  AErrorMsg := '';
  AErrorCode := ECODE_OTHER;
  FServerUrl := AServerUrl;
  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_ASSET_NIL;
    Exit;
  end;

  try
    Result := FGFDataManager.UserLogin(0, AServerUrl, AAssetUserName + '@' + AOrgNo + '@' + AAssetNo, AAssetUserPassword, LErrorCode, LErrorMsg);
    if Result then begin
      LErrorCode := ECODE_SUCCESS;
      AErrorMsg := LErrorMsg;
    end else begin
      if LErrorCode = -1003 then begin
        AErrorCode := ECODE_SERVICE_ASSET_NETWORK_EXCEPT;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] Network is Except, (Url=%s), (ErrorMsg=%s)', [AServerUrl, AErrorMsg]));
      end else begin // 用户名密码问题
        AErrorMsg := LErrorMsg;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] return other error, (ErrorCode=%d), (ErrorMsg=%s)', [LErrorCode, LErrorMsg]));
      end;
    end;
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_ASSET_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.GilUserLogin] FGFDataManager.JYUserLogin Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, LErrorCode, LErrorMsg]));
    end;
  end;
end;

function TServiceAssetImpl.PBoxUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean;
var
  LErrorCode: Integer;
  LErrorMsg: WideString;
begin
  Result := False;
  AErrorMsg := '';
  AErrorCode := ECODE_OTHER;
  FServerUrl := AServerUrl;
  if FGFDataManager = nil then begin
    AErrorCode := ECODE_SERVICE_ASSET_NIL;
    Exit;
  end;

  try
    Result := FGFDataManager.PBOXLogin(0, AServerUrl, AAssetUserName + '@' + AOrgNo + '@' + AAssetNo, AAssetUserPassword, LErrorCode, LErrorMsg);
    if Result then begin
      LErrorCode := ECODE_SUCCESS;
      AErrorMsg := LErrorMsg;
    end else begin
      if LErrorCode = -1003 then begin
        AErrorCode := ECODE_SERVICE_ASSET_NETWORK_EXCEPT;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.PBoxUserLogin] Network is Except, (Url=%s), (ErrorMsg=%s)', [AServerUrl, AErrorMsg]));
      end else begin // 用户名密码问题
        AErrorMsg := LErrorMsg;
        FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.PBoxUserLogin] return other error, (ErrorCode=%d), (ErrorMsg=%s)', [LErrorCode, LErrorMsg]));
      end;
    end;
  except
    on Ex: Exception do begin
      AErrorCode := ECODE_SERVICE_ASSET_EXEC_EXCEPT;
      FAppContext.AppLog(llError, Format('[TGFServiceAssetImpl.PBoxUserLogin] FGFDataManager.JYUserLogin Exception, Exception is %s, (ErrorCode=%d), (ErrorMsg=%s)', [Ex.Message, LErrorCode, LErrorMsg]));
    end;
  end;
end;

procedure TServiceAssetImpl.DoUserLogin(AErrorCode: integer; const AValue: AnsiString);
var
  LValue: WideString;
begin
  if FAppContext = nil then Exit;
  LValue := AValue;
  if FAppContext.GetLoginMgr <> nil then begin
    (FAppContext.GetLoginMgr as ILoginMgr).AssetGFUserLogin(AErrorCode, LValue);
  end;
end;

end.
