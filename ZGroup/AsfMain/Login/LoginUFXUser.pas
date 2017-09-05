unit LoginUFXUser;

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
  Forms,
  Login,
  Windows,
  Classes,
  SysUtils,
  Controls,
  LoginType,
  AppContext,
  ServiceBase;

type

  TLoginUFXUser = class(TLogin)
  private
  protected
    // 资产服务登录
    function DoAssetLogin: Boolean; override;
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); override;
    // 释放不需要的资源
    procedure UnInitialize; override;
    // 基础服务重新登录
    procedure BaseGFUserLogin(AErrorCode: Integer; AValue: WideString); override;
    // 资产服务重新登录
    procedure AssetGFUserLogin(AErrorCode: Integer; AValue: WideString); override;
  end;

implementation

uses
  Config,
  UserInfo,
  ServerInfo,
  FastLogLevel,
  ServiceConst;

{ TLoginUFXUser }

constructor TLoginUFXUser.Create;
begin
  inherited;

end;

destructor TLoginUFXUser.Destroy;
begin

  inherited;
end;

procedure TLoginUFXUser.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure TLoginUFXUser.UnInitialize;
begin

  inherited UnInitialize;
end;

function TLoginUFXUser.DoAssetLogin: Boolean;
var
  LErrorCode: Integer;
  LErrorMsg, LServerUrl: WideString;
begin
  Result := False;
  FConfig.GetAssetIndicatorServerInfo.FirstServer;
  while not FConfig.GetAssetIndicatorServerInfo.IsEOF do begin
    LServerUrl := FConfig.GetAssetIndicatorServerInfo.GetServerUrl;
    if LServerUrl <> '' then begin
      Result := FServiceAsset.UFXUserLogin(LServerUrl,
                                   FConfig.GetUserInfo.GetAssetUserName,
                                   FConfig.GetUserInfo.GetOrgNo,
                                   FConfig.GetUserInfo.GetAssetNo,
                                   FConfig.GetUserInfo.GetCiperAssetUserPassword,
                                   LErrorMsg,
                                   LErrorCode);
      if Result then begin
        Break;
      end else begin
        if LErrorCode = ECODE_OTHER then begin
          FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
        end else begin
          FLoginMainUI.ShowLoginInfo(LErrorMsg);
        end;
      end;
    end;
    FConfig.GetAssetIndicatorServerInfo.NextServer;
  end;
end;

procedure TLoginUFXUser.BaseGFUserLogin(AErrorCode: Integer; AValue: WideString);
begin

end;

procedure TLoginUFXUser.AssetGFUserLogin(AErrorCode: Integer; AValue: WideString);
begin

end;

end.
