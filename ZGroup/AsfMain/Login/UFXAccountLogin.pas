unit UFXAccountLogin;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UFX Account Login
// Author£º      lksoulman
// Date£º        2017-8-19
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  AppContext,
  AssetService,
  AbstractLogin;

type

  // UFX Account Login
  TUFXAccountLogin = class(TAbstractLogin)
  private
    // UFX Login
    FUFXLogin: TUFXLogin;
  protected
    // Login Asset
    function DoLoginAsset: Boolean; override;
    // Init Login Info
    function DoInitLoginInfos: Boolean; override;
  public
  end;

implementation

uses
  Cfg,
  UserInfo,
  LogLevel,
  ErrorCode,
  ServerInfo;

{ TUFXAccountLogin }

function TUFXAccountLogin.DoInitLoginInfos: Boolean;
begin
  Result := inherited;
  FUFXLogin.FOrgNo := FCfg.GetSysCfg.GetUserInfo.GetOrgNo;
  FUFXLogin.FAssetNo := FCfg.GetSysCfg.GetUserInfo.GetAssetNo;
  FUFXLogin.FMacAddress := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FMacAddress;
  FUFXLogin.FHardDiskId := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FHardDiskId;
  FUFXLogin.FHardDiskIdMD5 := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FHardDiskIdMD5;
end;

function TUFXAccountLogin.DoLoginAsset: Boolean;
var
  LServerUrl: string;
  LServerUrlIsNull: Boolean;
begin
  Result := False;
  LServerUrlIsNull := True;
  FCfg.GetServerCfg.GetAssetServerInfo.FirstServer;
  while not FCfg.GetServerCfg.GetAssetServerInfo.IsEOF do begin
    LServerUrl := FCfg.GetServerCfg.GetAssetServerInfo.GetServerUrl;
    if LServerUrl <> '' then begin
      if LServerUrlIsNull then begin
        LServerUrlIsNull := False;
      end;
      FUFXLogin.FServerUrl := LServerUrl;
      FUFXLogin.FUserName := FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName;
      FUFXLogin.FCipherPassword := FCfg.GetSysCfg.GetUserInfo.GetUFXCipherPassword;
      Result := FAssetService.UFXLogin(@FUFXLogin);
      if Result then begin
      // Login Success
        Exit;
      end else begin
      // Login Fail
        case FUFXLogin.FErrorCode of
          ErrorCode_Service_Wait_Timeout,
          ErrorCode_Service_Wait_Failed,
          ErrorCode_Service_Network_Except,
          ErrorCode_Service_Login_Failed:
            begin
              FLoginMainUI.ShowLoginInfo(GetErrorInfo(FUFXLogin.FErrorCode));
            end;
          ErrorCode_Service_Login_Password_CheckFailed,
          ErrorCode_Service_Login_ElseWhere_Logined:
            begin
              FLoginMainUI.ShowLoginInfo(GetErrorInfo(FUFXLogin.FErrorCode));
              Exit;
            end;
        else
          begin
            FLoginMainUI.ShowLoginInfo(GetErrorInfo(FUFXLogin.FErrorCode));
          end;
        end;
      end;
    end;
    FCfg.GetServerCfg.GetAssetServerInfo.NextServer;
  end;
  if LServerUrlIsNull then begin
    FLoginMainUI.ShowLoginInfo(GetErrorInfo(ErrorCode_Service_Request_UrlIsNull));
  end;
end;

end.
