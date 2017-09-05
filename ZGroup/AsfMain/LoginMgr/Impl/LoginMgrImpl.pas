unit LoginMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-19
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Login,
  Config,
  Windows,
  Classes,
  SysUtils,
  Controls,
  LoginMgr,
  LoginType,
  AppContext,
  SyncAsyncImpl;

type

  TLoginMgrImpl = class(TSyncAsyncImpl, ILoginMgr)
  private
    // 登录对象
    FLogin: TLogin;
    // 配置接口
    FConfig: IConfig;
  protected
    // 初始化
    procedure DoCreateLogin;
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    {ISyncAsync}

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

    { ILoginMgr }

    // 是不是登录 GF 服务
    function IsLoginGF(ALoginType: TLoginType): Boolean; safecall;
    // 基础服务重新登录
    procedure BaseGFUserLogin(AErrorCode: Integer; const AValue: WideString); safecall;
    // 资产服务重新登录
    procedure AssetGFUserLogin(AErrorCode: Integer; const AValue: WideString); safecall;
  end;

implementation

uses
  UserInfo,
  LoginUFXUser,
  LoginGILUser,
  LoginPBOXUser;

{ TLoginMgrImpl }

constructor TLoginMgrImpl.Create;
begin
  inherited;

end;

destructor TLoginMgrImpl.Destroy;
begin

  inherited;
end;

procedure TLoginMgrImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  FConfig := FAppContext.GetConfig as IConfig;
  DoCreateLogin;
end;

procedure TLoginMgrImpl.UnInitialize;
begin
  if FLogin <> nil then begin
    FLogin.UnInitialize;
    FLogin.Free;
    FLogin := nil;
  end;
  FConfig := nil;
  inherited UnInitialize;
end;

procedure TLoginMgrImpl.SyncBlockExecute;
begin
  if FLogin <> nil then begin
    if FLogin.ShowLoginMainUI = mrOk then begin
      if  FLogin.IsLoginGF(ltAll) then begin
        if FConfig <> nil then begin
          FConfig.GetUserInfo.SaveCache;
          FConfig.ForceInitUserDirectories;
        end;
      end;
    end;
  end;
end;

procedure TLoginMgrImpl.AsyncNoBlockExecute;
begin

end;

function TLoginMgrImpl.Dependences: WideString;
begin

end;

function TLoginMgrImpl.IsLoginGF(ALoginType: TLoginType): Boolean;
begin
  Result := FLogin.IsLoginGF(ALoginType);
end;

procedure TLoginMgrImpl.BaseGFUserLogin(AErrorCode: Integer; const AValue: WideString);
begin

end;

procedure TLoginMgrImpl.AssetGFUserLogin(AErrorCode: Integer; const AValue: WideString);
begin

end;

procedure TLoginMgrImpl.DoCreateLogin;
begin
  if FConfig <> nil then begin
    if FConfig.GetUserInfo <> nil then begin
      case FConfig.GetUserInfo.GetAccountType of
        atUFX:
          begin
            FLogin := TLoginUFXUser.Create;
          end;
        atGIL:
          begin
            FLogin := TLoginGILUser.Create;
          end;
        atPBOX:
          begin
            FLogin := TLoginPBOXUser.Create;
          end;
      end;
      FLogin.Initialize(FAppContext);
    end;
  end;
end;

end.
