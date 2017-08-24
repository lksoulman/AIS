unit Login;

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
  Config,
  Windows,
  Classes,
  SysUtils,
  Controls,
  AppContext,
  LoginGFType,
  LoginMainUI,
  ServiceBase,
  ServiceAsset;

type

  TLogin = class
  private
  protected
    // 配置接口
    FConfig: IConfig;
    // 是不是基础服务登录成功
    FIsBaseLogin: Boolean;
    // 是不是资产服务登录成功
    FIsAssetLogin: Boolean;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 登录主窗口
    FLoginMainUI: TLoginMainUI;
    // GF 基础服务
    FServiceBase: IServiceBase;
    // GF 资产服务
    FServiceAsset: IServiceAsset;


    // 客户端简单检查是不是需要绑定
    function DoSimpleCheckIsNeedBind: boolean;
    // 获取错误码对应的信息
    function DoGetErrorMsg(AErrorCode: Integer): string;
    // 基础服务绑定和登录
    function DoBaseLogin: boolean; virtual;
    // 资产服务登录
    function DoAssetLogin: Boolean; virtual;
    // 被回调方法
    function DoCallBackLoginFunc: Boolean; virtual;
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); virtual;
    // 释放不需要的资源
    procedure UnInitialize; virtual;


    // 展示绑定窗口
    procedure ShowLoginBindUI;
    // 展示登录主窗口
    function ShowLoginMainUI: Integer;
    // 展示登录信息
    procedure ShowLoginInfo(AMsg: WideString);
    // 是不是登录 GF 服务
    function IsLoginGF(AGFType: TLoginGFType): Boolean; virtual;
    // 基础服务重新登录
    procedure BaseGFUserLogin(AErrorCode: Integer; AValue: WideString); virtual;
    // 资产服务重新登录
    procedure AssetGFUserLogin(AErrorCode: Integer; AValue: WideString); virtual;
  end;

implementation

uses
  UserInfo,
  ServerInfo,
  FastLogLevel,
  ServiceConst;

{ TLogin }

constructor TLogin.Create;
begin
  inherited;
  FIsBaseLogin := False;
  FIsAssetLogin := False;
  FLoginMainUI := TLoginMainUI.Create(nil);
  FLoginMainUI.SetLoginFunc(DoCallBackLoginFunc);
end;

destructor TLogin.Destroy;
begin
  FLoginMainUI.Free;
  inherited;
end;

procedure TLogin.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  if FAppContext <> nil then begin
    FLoginMainUI.Initialize(FAppContext);
    FConfig := FAppContext.GetConfig as IConfig;
    FServiceBase := FAppContext.GetServiceBase as IServiceBase;
    FServiceAsset := FAppContext.GetServiceAsset as IServiceAsset;
  end;
end;

procedure TLogin.UnInitialize;
begin
  FServiceAsset := nil;
  FServiceBase := nil;
  FConfig := nil;
  FLoginMainUI.UnInitialize;
  FAppContext := nil;
end;

function TLogin.DoSimpleCheckIsNeedBind: boolean;
begin
  Result := False;
  if FConfig.GetUserInfo <> nil then begin
    if (FConfig.GetUserInfo.GetBindLicense = '')
      or (FConfig.GetUserInfo.GetBindOrgSign = '') then begin
      Result := True;
    end
  end;
end;

function TLogin.DoGetErrorMsg(AErrorCode: Integer): string;
begin
  Result := '';
end;

function TLogin.DoBaseLogin: boolean;
var
  LErrorCode: Integer;
  LErrorMsg, LServerUrl, LBindLicense, LBindOrgSign, LMsg: WideString;
begin
  Result := False;
  FConfig.GetBaseIndicatorServerInfo;
  FConfig.GetBaseIndicatorServerInfo.FirstServer;
  while not FConfig.GetBaseIndicatorServerInfo.IsEOF do begin
    LServerUrl := FConfig.GetBaseIndicatorServerInfo.GetServerUrl;
    if LServerUrl <> '' then begin
      // 简单检查是不是先绑定
      if DoSimpleCheckIsNeedBind then begin
        if FLoginMainUI.ShowLoginBindUI = mrOk then begin
          // 先绑定
          Result := FServiceBase.GilUserBind(LServerUrl,
                                   FConfig.GetUserInfo.GetUserName,
                                   FConfig.GetUserInfo.GetAssetUserName,
                                   FConfig.GetUserInfo.GetOrgNo,
                                   FConfig.GetUserInfo.GetAssetNo,
                                   LBindLicense,
                                   LBindOrgSign,
                                   LErrorMsg,
                                   LErrorCode);
          // 绑定成功
          if Result then begin
            FConfig.GetUserInfo.SetBindLicense(LBindLicense);
            FConfig.GetUserInfo.SetBindOrgSign(LBindOrgSign);
            // 登录
            Result := FServiceBase.GilUserLogin(ltUFX,
                                         LServerUrl,
                                         FConfig.GetUserInfo.GetBindLicense,
                                         FConfig.GetUserInfo.GetAssetUserName,
                                         FConfig.GetUserInfo.GetOrgNo,
                                         FConfig.GetUserInfo.GetAssetNo,
                                         LErrorMsg,
                                         LErrorCode);
            if Result then begin
              // 登录成功
              Exit;
            end else begin
              case LErrorCode of
                ECODE_BIND_BASE_NEED_REPEAT:
                  begin
                    // 重新绑定账号
                    FConfig.GetUserInfo.ResetBindInfo;
                    FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                    continue;
                  end;
              else
                begin
                  FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                  FAppContext.AppLog(llERROR, DoGetErrorMsg(LErrorCode));
                end;
              end;
            end;
          end else begin
            case LErrorCode of
              ECODE_BIND_BASE_USER_EXIST, ECODE_BIND_BASE_USER_NOEXIST:
                begin
                  // 重新绑定账号
                  FConfig.GetUserInfo.ResetBindInfo;
                  FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                  continue;
                end;
            else
              begin
                FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                FAppContext.AppLog(llERROR, DoGetErrorMsg(LErrorCode));
              end;
            end;
          end;
        end else begin
          // 用户取消了绑定
          Exit;
        end;
      end else begin
        Result := FServiceBase.GilUserLogin(ltUFX,
                                         LServerUrl,
                                         FConfig.GetUserInfo.GetBindLicense,
                                         FConfig.GetUserInfo.GetAssetUserName,
                                         FConfig.GetUserInfo.GetOrgNo,
                                         FConfig.GetUserInfo.GetAssetNo,
                                         LErrorMsg,
                                         LErrorCode);
        if Result then begin
          // 登录成功
          Exit;
        end else begin
          case LErrorCode of
            ECODE_BIND_BASE_NEED_REPEAT:
              begin
                // 重新绑定账号
                FConfig.GetUserInfo.ResetBindInfo;
                FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                continue;
              end;
          else
            begin
              FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
              FAppContext.AppLog(llERROR, DoGetErrorMsg(LErrorCode));
            end;
          end;
        end;
      end;
    end;
    FConfig.GetBaseIndicatorServerInfo.NextServer;
  end;
end;

function TLogin.DoAssetLogin: Boolean;
begin
  Result := False;
end;

function TLogin.DoCallBackLoginFunc: Boolean;
begin
  Result := False;
  if FConfig.GetUserInfo <> nil then begin
    Result := DoAssetLogin;
    FIsAssetLogin := Result;
    if Result then begin
      Result := DoBaseLogin;
      FIsBaseLogin := Result;
      if not Result then begin
        FLoginMainUI.ShowLoginInfo('基础服务登录失败');
      end;
    end else begin
      FLoginMainUI.ShowLoginInfo('资产服务登录失败');
    end;
  end;
end;

function TLogin.ShowLoginMainUI: Integer;
begin
  Result := FLoginMainUI.ShowLogin;
end;

procedure TLogin.ShowLoginBindUI;
begin
  FLoginMainUI.ShowLoginBindUI;
end;

procedure TLogin.ShowLoginInfo(AMsg: WideString);
begin
  FLoginMainUI.ShowLoginInfo(AMsg);
end;

function TLogin.IsLoginGF(AGFType: TLoginGFType): Boolean;
begin
  case AGFType of
    lGFBase:
      begin
        Result := FIsBaseLogin;
      end;
    lGFAsset:
      begin
        Result := FIsAssetLogin;
      end;
    lGFAll:
      begin
        Result := FIsBaseLogin and FIsAssetLogin;
      end;
  end;
end;

procedure TLogin.BaseGFUserLogin(AErrorCode: Integer; AValue: WideString);
begin

end;

procedure TLogin.AssetGFUserLogin(AErrorCode: Integer; AValue: WideString);
begin

end;

end.
