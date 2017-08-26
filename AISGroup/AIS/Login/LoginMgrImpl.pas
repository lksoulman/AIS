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
  Windows,
  Classes,
  SysUtils,
  Controls,
  Login,
  Config,
  LoginMgr,
  SyncAsync,
  AppContext,
  LoginGFType;

type

  TLoginMgrImpl = class(TInterfacedObject, ISyncAsync, ILoginMgr)
  private
    // 登录对象
    FLogin: TLogin;
    // 配置接口
    FConfig: IConfig;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
    // 初始化
    procedure DoCreateLogin;
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    {ISyncAsync}

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; safecall;
    // 同步执行方法
    procedure SyncExecute; safecall;
    // 异步执行方法
    procedure AsyncExecute; safecall;

    { ILoginMgr }

    // 是不是登录 GF 服务
    function IsLoginGF(AGFType: TLoginGFType): Boolean; safecall;
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

procedure TLoginMgrImpl.DoCreateLogin;
begin
  if FConfig <> nil then begin
    if FConfig.GetUserInfo <> nil then begin
      case FConfig.GetUserInfo.GetLoginType of
        ltUFX:
          begin
            FLogin := TLoginUFXUser.Create;
          end;
        ltGIL:
          begin
            FLogin := TLoginGILUser.Create;
          end;
        ltPBOX:
          begin
            FLogin := TLoginPBOXUser.Create;
          end;
      end;
      FLogin.Initialize(FAppContext);
    end;
  end;
end;

procedure TLoginMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
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
  FAppContext := nil;
end;

function TLoginMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TLoginMgrImpl.SyncExecute;
begin
  if FLogin <> nil then begin
    if FLogin.ShowLoginMainUI = mrOk then begin
      if  FLogin.IsLoginGF(lGFAll) then begin
        if FConfig <> nil then begin
          FConfig.GetUserInfo.SaveCache;
          FConfig.ForceInitUserDirectories;
        end;
      end;
    end;
  end;
end;

procedure TLoginMgrImpl.AsyncExecute;
begin

end;

function TLoginMgrImpl.IsLoginGF(AGFType: TLoginGFType): Boolean;
begin
  Result := FLogin.IsLoginGF(AGFType);
end;

procedure TLoginMgrImpl.BaseGFUserLogin(AErrorCode: Integer; const AValue: WideString);
begin

end;

procedure TLoginMgrImpl.AssetGFUserLogin(AErrorCode: Integer; const AValue: WideString);
begin

end;

end.
