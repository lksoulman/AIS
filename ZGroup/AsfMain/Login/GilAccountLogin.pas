unit GilAccountLogin;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Gil Account Login
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

  // Gil Account Login
  TGilAccountLogin = class(TAbstractLogin)
  private
    // Gil Login
    FGILLogin: TGILLogin;
  protected
    // Login Basic
    function DoLoginBasic: boolean; override;
    // Login Asset
    function DoLoginAsset: Boolean; override;
    // Init Login Info
    function DoInitLoginInfos: Boolean; override;
  public
  end;

implementation

uses
  Cfg,
  Json,
  Utils,
  UserInfo,
  LogLevel,
  ErrorCode,
  BasicService;

{ TGilAccountLogin }

function TGilAccountLogin.DoInitLoginInfos: Boolean;
begin
  Result := inherited;
  FGILLogin.FOrgNo := FCfg.GetSysCfg.GetUserInfo.GetOrgNo;
  FGILLogin.FAssetNo := FCfg.GetSysCfg.GetUserInfo.GetAssetNo;
  FGILLogin.FMacAddress := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FMacAddress;
  FGILLogin.FHardDiskId := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FHardDiskId;
  FGILLogin.FHardDiskIdMD5 := FCfg.GetSysCfg.GetSystemInfo.GetSystemInfo.FHardDiskIdMD5;
end;

function TGilAccountLogin.DoLoginBasic: boolean;
var
  LServerUrl: string;
  LServerUrlIsNull: Boolean;
begin
  Result := False;
  LServerUrlIsNull := True;
  FCfg.GetServerCfg.GetBasicServerInfo.FirstServer;
  while not FCfg.GetServerCfg.GetBasicServerInfo.IsEOF do begin
    LServerUrl := FCfg.GetServerCfg.GetBasicServerInfo.GetServerUrl;
    if LServerUrl <> '' then begin
      if LServerUrlIsNull then begin
        LServerUrlIsNull := False;
      end;

      if DoCheckIsNeedBind then begin
        FGilBasicBind.FServerUrl := LServerUrl;
        FGilBasicBind.FUserName := FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName;
        FGilBasicBind.FGilUserName := FCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo.FUserName;
        Result := FBasicService.GilBind(@FGilBasicBind);
        if Result then begin
        // Bind Success
          FGilBasicLogin.FServerUrl := LServerUrl;
          FGilBasicLogin.FUserName := FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName;
          FGilBasicLogin.FLicense := FCfg.GetSysCfg.GetUserInfo.GetBindInfo.FLicense;
          Result := FBasicService.GilLogin(@FGilBasicLogin);
          if Result then begin
          // Login Success
            Exit;
          end else begin
            case FGilBasicLogin.FErrorCode of
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
              ErrorCode_Service_Login_MacCode_CheckFailed:
                begin
                  FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
                  Continue;
                end;
            end;
          end;
        end else begin
        // Bind Fail
          case FGilBasicBind.FErrorCode of
            ErrorCode_Service_Wait_Timeout,
            ErrorCode_Service_Wait_Failed,
            ErrorCode_Service_Network_Except:
              begin
                FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicBind.FErrorCode));
              end;
            ErrorCode_Service_Login_License_Binded,
            ErrorCode_Service_Login_License_Bind_Except,
            ErrorCode_Service_Login_License_Invalid:
              begin
                FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicBind.FErrorCode));
              end;
          else
            begin
              FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicBind.FErrorCode));
            end;
          end;
        end;
      end else begin
        FGilBasicLogin.FServerUrl := LServerUrl;
        FGilBasicLogin.FUserName := FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName;
        FGilBasicLogin.FLicense := FCfg.GetSysCfg.GetUserInfo.GetBindInfo.FLicense;
        Result := FBasicService.GilLogin(@FGilBasicLogin);
        if Result then begin
        // Login Success
          Exit;
        end else begin
        // Login Fail
          case FGilBasicLogin.FErrorCode of
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
            ErrorCode_Service_Login_MacCode_CheckFailed:
              begin
                FLoginMainUI.ShowLoginInfo(GetErrorInfo(FGilBasicLogin.FErrorCode));
                Continue;
              end;
          end;
        end;
      end;
    end;
    FCfg.GetServerCfg.GetBasicServerInfo.NextServer;
  end;
  if LServerUrlIsNull then begin
    FLoginMainUI.ShowLoginInfo(GetErrorInfo(ErrorCode_Service_Request_UrlIsNull));
  end;
end;

function TGilAccountLogin.DoLoginAsset: boolean;
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
      if LServerUrlIsNull  then begin
        LServerUrlIsNull := False;
      end;
      FGILLogin.FServerUrl := LServerUrl;
      FGILLogin.FGilUserName := FCfg.GetSysCfg.GetUserInfo.GetGilAccountInfo.FUserName;
      FGILLogin.FCipherPassword := FCfg.GetSysCfg.GetUserInfo.GetGilCipherPassword;
      if FGILLogin.FServerUrl <> '' then begin
        Result := FAssetService.GILLogin(@FGILLogin);
        if Result then begin
        // Login Success
          FCfg.GetSysCfg.GetUserInfo.GetUFXAccountInfo.FUserName := FGILLogin.FUserName;
//          FCfg.GetSysCfg.GetUserInfo.
          Exit;
        end else begin
        // Login Fail
          case FGILLogin.FErrorCode of
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
    end;
    FCfg.GetServerCfg.GetAssetServerInfo.NextServer;
  end;
  if LServerUrlIsNull then begin
    FLoginMainUI.ShowLoginInfo(GetErrorInfo(ErrorCode_Service_Request_UrlIsNull));
  end;
end;

end.
