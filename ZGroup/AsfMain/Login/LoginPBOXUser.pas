unit LoginPBOXUser;

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
  AppContext,
  ServiceBase;

type

  TLoginPBOXUser = class(TLogin)
  private
  protected
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
  Config,
  ServiceConst;

{ TLoginPBOXUser }

constructor TLoginPBOXUser.Create;
begin
  inherited;
end;

destructor TLoginPBOXUser.Destroy;
begin

  inherited;
end;

procedure TLoginPBOXUser.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure TLoginPBOXUser.UnInitialize;
begin

  inherited UnInitialize;
end;

function TLoginPBOXUser.DoAssetLogin: boolean;
var
  LErrorCode: Integer;
  LErrorMsg, LServerUrl: WideString;
begin
  Result := False;
  FConfig.GetAssetIndicatorServerInfo.FirstServer;
  while not FConfig.GetAssetIndicatorServerInfo.IsEOF do begin
    LServerUrl := FConfig.GetAssetIndicatorServerInfo.GetServerUrl;
    if LServerUrl <> '' then begin
      Result := FServiceAsset.PBoxUserLogin(LServerUrl,
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

procedure TLoginPBOXUser.BaseGFUserLogin(AErrorCode: Integer; AValue: WideString);
begin

end;

procedure TLoginPBOXUser.AssetGFUserLogin(AErrorCode: Integer; AValue: WideString);
begin

end;

end.
