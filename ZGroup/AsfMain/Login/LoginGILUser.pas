unit LoginGILUser;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-19
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Login,
  Windows,
  Classes,
  SysUtils,
  LoginType,
  AppContext;

type

  TLoginGILUser = class(TLogin)
  private
    // ��������˷��ص�������Ϣ
    procedure PrasePasswordInfo(APasswordInfo: string; var AErrorCode, ADays: Integer);
  protected
    // ��������󶨺͵�¼
    function DoBaseLogin: boolean; override;
    // �ʲ������¼
    function DoAssetLogin: Boolean; override;
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); override;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; override;
    // �����������µ�¼
    procedure BaseGFUserLogin(AErrorCode: Integer; AValue: WideString); override;
    // �ʲ��������µ�¼
    procedure AssetGFUserLogin(AErrorCode: Integer; AValue: WideString); override;
  end;

implementation

uses
  Json,
  Utils,
  Config,
  UserInfo,
  ServiceConst,
  FastLogLevel,
  AsfSdkExport;

{ TLoginGILUser }

constructor TLoginGILUser.Create;
begin
  inherited;

end;

destructor TLoginGILUser.Destroy;
begin

  inherited;
end;

procedure TLoginGILUser.PrasePasswordInfo(APasswordInfo: string; var AErrorCode, ADays: Integer);
var
  LPasswordType, LDays: string;
  LJsonObject: TJsonObject;
begin
  //  APasswordInfo
  //  Json �ṹ   '{"updatePwd":1,
  //                "errorMessage":"��ʼ���룬���޸�����"
  //               }'
  ADays := 0;
  AErrorCode := ECODE_SUCCESS;
  if APasswordInfo = '' then Exit;
  LJsonObject := Utils.GetJsonObjectByString(Trim(APasswordInfo));
  if LJsonObject = nil then Exit;
  try
    LPasswordType := Utils.GetStringByJsonObject(LJsonObject, 'updatePwd');
    if LPasswordType = '1' then  begin
      AErrorCode := ECODE_PASSWORD_RESET;
    end else if LPasswordType = '2' then  begin
      AErrorCode := ECODE_PASSWORD_EXPIRE;
    end else if LPasswordType = '3' then  begin
      AErrorCode := ECODE_PASSWORD_NDAY_EXPIRE;
      LDays := Utils.GetStringByJsonObject(LJsonObject, 'expiryDay');
      ADays := StrToIntDef(LDays, 0);
    end;
  finally
    LJsonObject.Free;
  end;
end;

procedure TLoginGILUser.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure TLoginGILUser.UnInitialize;
begin

  inherited UnInitialize;
end;

function TLoginGILUser.DoBaseLogin: boolean;
var
  LErrorCode: Integer;
  LErrorMsg, LServerUrl, LBindLicense, LBindOrgSign: WideString;
begin
  Result := False;
  FConfig.GetBaseIndicatorServerInfo;
  FConfig.GetBaseIndicatorServerInfo.FirstServer;
  while not FConfig.GetBaseIndicatorServerInfo.IsEOF do begin
    LServerUrl := FConfig.GetBaseIndicatorServerInfo.GetServerUrl;
    if LServerUrl <> '' then begin
      // �򵥼���ǲ����Ȱ�
      if DoSimpleCheckIsNeedBind then begin
        // �Ȱ�
        Result := FServiceBase.GilUserBind(LServerUrl,
                                 FConfig.GetUserInfo.GetUserName,
                                 FConfig.GetUserInfo.GetAssetUserName,
                                 FConfig.GetUserInfo.GetOrgNo,
                                 FConfig.GetUserInfo.GetAssetNo,
                                 LBindLicense,
                                 LBindOrgSign,
                                 LErrorMsg,
                                 LErrorCode);
        // �󶨳ɹ�
        if Result then begin
          FConfig.GetUserInfo.SetBindLicense(LBindLicense);
          FConfig.GetUserInfo.SetBindOrgSign(LBindOrgSign);
          // ��¼
          Result := FServiceBase.GilUserLogin(atUFX,
                                       LServerUrl,
                                       FConfig.GetUserInfo.GetBindLicense,
                                       FConfig.GetUserInfo.GetAssetUserName,
                                       FConfig.GetUserInfo.GetOrgNo,
                                       FConfig.GetUserInfo.GetAssetNo,
                                       LErrorMsg,
                                       LErrorCode);
          if Result then begin
            // ��¼�ɹ�
            Exit;
          end else begin
            case LErrorCode of
              ECODE_BIND_BASE_NEED_REPEAT:
                begin
                  // ���°��˺�
                  FConfig.GetUserInfo.ResetBindInfo;
                  FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                  continue;
                end;
            else
              begin
                FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                FastSysLog(llERROR, DoGetErrorMsg(LErrorCode));
              end;
            end;
          end;
        end else begin
          case LErrorCode of
            ECODE_BIND_BASE_USER_EXIST, ECODE_BIND_BASE_USER_NOEXIST:
              begin
                // ���°��˺�
                FConfig.GetUserInfo.ResetBindInfo;
                FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                continue;
              end;
          else
            begin
              FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
              FastSysLog(llERROR, DoGetErrorMsg(LErrorCode));
            end;
          end;
        end;
      end else begin
        Result := FServiceBase.GilUserLogin(atGIL,
                                         LServerUrl,
                                         FConfig.GetUserInfo.GetBindLicense,
                                         FConfig.GetUserInfo.GetAssetUserName,
                                         FConfig.GetUserInfo.GetOrgNo,
                                         FConfig.GetUserInfo.GetAssetNo,
                                         LErrorMsg,
                                         LErrorCode);
        if Result then begin
          // ��¼�ɹ�
          Exit;
        end else begin
          case LErrorCode of
            ECODE_BIND_BASE_NEED_REPEAT:
              begin
                // ���°��˺�
                FConfig.GetUserInfo.ResetBindInfo;
                FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
                continue;
              end;
          else
            begin
              FLoginMainUI.ShowLoginInfo(DoGetErrorMsg(LErrorCode));
              FastSysLog(llERROR, DoGetErrorMsg(LErrorCode));
            end;
          end;
        end;
      end;
    end;
    FConfig.GetBaseIndicatorServerInfo.NextServer;
  end;
end;

function TLoginGILUser.DoAssetLogin: boolean;
var
  LErrorCode, LDays: Integer;
  LErrorMsg, LServerUrl, LPasswordInfo: WideString;
begin
  Result := False;
  FConfig.GetAssetIndicatorServerInfo.FirstServer;
  while not FConfig.GetAssetIndicatorServerInfo.IsEOF do begin
    LServerUrl := FConfig.GetAssetIndicatorServerInfo.GetServerUrl;
    if LServerUrl <> '' then begin
      Result := FServiceAsset.GilUserLogin(LServerUrl,
                                   FConfig.GetUserInfo.GetUserName,
                                   FConfig.GetUserInfo.GetCiperUserPassword,
                                   LPasswordInfo,
                                   LErrorMsg,
                                   LErrorCode);
      if Result then begin
        FConfig.GetUserInfo.SetAssetUserName(LErrorMsg);
        PrasePasswordInfo(LPasswordInfo, LErrorCode, LDays);
        if LErrorCode = ECODE_SUCCESS then begin
          FConfig.GetUserInfo.SetPasswordExpire(False);
          Exit;
        end else if LErrorCode = ECODE_PASSWORD_NDAY_EXPIRE then begin
          FConfig.GetUserInfo.SetPasswordExpire(True);
          FConfig.GetUserInfo.SetPasswordExpireDays(LDays);
          Exit;
        end else begin
          Result := False;

        end;
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

procedure TLoginGILUser.BaseGFUserLogin(AErrorCode: Integer; AValue: WideString);
begin

end;

procedure TLoginGILUser.AssetGFUserLogin(AErrorCode: Integer; AValue: WideString);
begin

end;

end.
