unit Login;

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
    // ���ýӿ�
    FConfig: IConfig;
    // �ǲ��ǻ��������¼�ɹ�
    FIsBaseLogin: Boolean;
    // �ǲ����ʲ������¼�ɹ�
    FIsAssetLogin: Boolean;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ��¼������
    FLoginMainUI: TLoginMainUI;
    // GF ��������
    FServiceBase: IServiceBase;
    // GF �ʲ�����
    FServiceAsset: IServiceAsset;


    // �ͻ��˼򵥼���ǲ�����Ҫ��
    function DoSimpleCheckIsNeedBind: boolean;
    // ��ȡ�������Ӧ����Ϣ
    function DoGetErrorMsg(AErrorCode: Integer): string;
    // ��������󶨺͵�¼
    function DoBaseLogin: boolean; virtual;
    // �ʲ������¼
    function DoAssetLogin: Boolean; virtual;
    // ���ص�����
    function DoCallBackLoginFunc: Boolean; virtual;
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); virtual;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; virtual;


    // չʾ�󶨴���
    procedure ShowLoginBindUI;
    // չʾ��¼������
    function ShowLoginMainUI: Integer;
    // չʾ��¼��Ϣ
    procedure ShowLoginInfo(AMsg: WideString);
    // �ǲ��ǵ�¼ GF ����
    function IsLoginGF(AGFType: TLoginGFType): Boolean; virtual;
    // �����������µ�¼
    procedure BaseGFUserLogin(AErrorCode: Integer; AValue: WideString); virtual;
    // �ʲ��������µ�¼
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
      // �򵥼���ǲ����Ȱ�
      if DoSimpleCheckIsNeedBind then begin
        if FLoginMainUI.ShowLoginBindUI = mrOk then begin
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
            Result := FServiceBase.GilUserLogin(ltUFX,
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
                  FAppContext.AppLog(llERROR, DoGetErrorMsg(LErrorCode));
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
                FAppContext.AppLog(llERROR, DoGetErrorMsg(LErrorCode));
              end;
            end;
          end;
        end else begin
          // �û�ȡ���˰�
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
        FLoginMainUI.ShowLoginInfo('���������¼ʧ��');
      end;
    end else begin
      FLoginMainUI.ShowLoginInfo('�ʲ������¼ʧ��');
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
