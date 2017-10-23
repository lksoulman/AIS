unit PBoxAccountLogin;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º PBox Account Login
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

  // PBox Account Login
  TPBoxAccountLogin = class(TAbstractLogin)
  private
    // UFX Login
    FPBOXLogin: TPBOXLogin;
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

{ TPBoxAccountLogin }

function TPBoxAccountLogin.DoInitLoginInfos: Boolean;
begin
  Result := inherited;
  FPBOXLogin.FOrgNo := FCfg.GetSysCfg.GetUserInfo.GetOrgNo;
  FPBOXLogin.FAssetNo := FCfg.GetSysCfg.GetUserInfo.GetAssetNo;
  FPBOXLogin.FMacAddress := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FMacAddress;
  FPBOXLogin.FHardDiskId := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FHardDiskId;
  FPBOXLogin.FHardDiskIdMD5 := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FHardDiskIdMD5;
end;

function TPBoxAccountLogin.DoLoginAsset: boolean;
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
      FPBOXLogin.FServerUrl := LServerUrl;
      FPBOXLogin.FUserName := FCfg.GetSysCfg.GetUserInfo.GetPBoxAccountInfo.FUserName;
      FPBOXLogin.FCipherPassword := FCfg.GetSysCfg.GetUserInfo.GetPBoxCipherPassword;
      Result := FAssetService.PBOXLogin(@FPBOXLogin);
      if Result then begin
      // Login Success
        Exit;
      end else begin
      // Login Fail
        case FPBOXLogin.FErrorCode of
          ErrorCode_Service_Wait_Timeout,
          ErrorCode_Service_Wait_Failed,
          ErrorCode_Service_Network_Except,
          ErrorCode_Service_Login_Failed:
            begin
              FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
            end;
          ErrorCode_Service_Login_Password_CheckFailed,
          ErrorCode_Service_Login_ElseWhere_Logined:
            begin
              FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
              Exit;
            end;
        else
          begin
            FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
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
