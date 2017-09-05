unit LoginSettingUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-12
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Messages,
  SysUtils,
  Graphics,
  Variants,
  Controls,
  StdCtrls,
  ExtCtrls,
  Buttons,
  Dialogs,
  Forms,
  Mask,
  RzTabs,
  RzButton,
  RzRadChk,
  RzSpnEdt,
  RzEdit,
  RzCmboBx,
  Config,
  AppContext;

type

  // ��¼���ô���
  TLoginSettingUI = class(TForm)
    // ���� pagecontrol
    pagecontrolSetting: TRzPageControl;
    // ����������ҳǩ
    sheetServerSetting: TRzTabSheet;
    // ��������ҳǩ
    sheetProxySetting: TRzTabSheet;
    // �ײ�
    pnlBottom: TPanel;
    // ȷ�� ��ť
    btnOk: TRzButton;
    // ȡ����ť
    btnCancel: TRzButton;
    // �������б��ǩ
    lblServerList: TLabel;
    // ��ѡ�б�
    cmbServerList: TRzComboBox;
    // NTLM ����
    gpbxNTLM: TGroupBox;
    // �û���Ϣ����
    gpbxUserInfo: TGroupBox;
    // �������ͷ���
    gpbxProxyType: TGroupBox;
    // �ǲ������ô������
    gpbxIsUserProxy: TGroupBox;
    // �������IP��ǩ
    lblProxyIP: TLabel;
    // ����������˿ڱ�ǩ
    lblProxyPort: TLabel;
    // ������������ͱ�ǩ
    lblProxyType: TLabel;
    // ��������û���Ϣ��ǩ
    lblUserInfo: TLabel;
    // ���������û�����ǩ
    lblUserName: TLabel;
    // ���������û�����ǩ
    lblPassword: TLabel;
    // ��������������ǩ
    lblDomain: TLabel;
    // �����������������
    edtDomain: TRzEdit;
    // �������IP�����
    edtProxyIP: TRzEdit;
    // ���������û��������
    edtUserName: TRzEdit;
    // �����������������
    edtPassword: TRzEdit;
    // �������Ķ˿������
    sedtProxyPort: TRzSpinEdit;
    // NTLM ��ѡ��
    chkIsNTLM: TRzCheckBox;
    // �ǲ���ʹ�ô���
    chkIsUseProxy: TRzCheckBox;
    // sock5����ѡ��
    rdbtnSocks5: TRzRadioButton;
    // sock4����ѡ��
    rdbtnSocks4: TRzRadioButton;
    // Http����ѡ��
    rdbtnHttpProxy: TRzRadioButton;
    // ���ڴ���
    procedure FormCreate(Sender: TObject);
    // ���� Show
    procedure FormShow(Sender: TObject);
    // ���̰���
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    // ����ȷ��
    procedure btnOkClick(Sender: TObject);
    // ����ȡ��
    procedure btnCancelClick(Sender: TObject);
    // ���� NTLM
    procedure chkIsNTLMClick(Sender: TObject);
    // �����ǲ���ʹ�ô������
    procedure chkIsUseProxyClick(Sender: TObject);
  private
    // ���ýӿ�
    FConfig: IConfig;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
    // ��ʼ���û����������ݵ���¼���ô���
    procedure DoInitUserDataToSettingWindows;
  public
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext);
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize;
    // ���µ�¼�������ݵ��û�����
    procedure UpdateLoginSettingDataToUserData;
  end;

implementation

uses
  ProxyInfo;

{$R *.dfm}

procedure TLoginSettingUI.FormCreate(Sender: TObject);
begin
  pagecontrolSetting.ActivePageIndex := 0;
end;

procedure TLoginSettingUI.FormShow(Sender: TObject);
begin
  SelectNext(pagecontrolSetting, true, true);
end;

procedure TLoginSettingUI.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then begin
    ModalResult := mrCancel;
  end;
end;

procedure TLoginSettingUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FConfig := FAppContext.GetConfig as IConfig;
  DoInitUserDataToSettingWindows;
end;

procedure TLoginSettingUI.UnInitialize;
begin
  FConfig := nil;
  FAppContext := nil;
end;

procedure TLoginSettingUI.DoInitUserDataToSettingWindows;
var
  LProxyInfo: IProxyInfo;
begin
  if FConfig <> nil then begin
    LProxyInfo := FConfig.GetProxyInfo;
    chkIsUseProxy.Checked := LProxyInfo.GetUse;
    edtProxyIP.Text := LProxyInfo.GetIP;
    sedtProxyPort.IntValue := LProxyInfo.GetPort;
    edtUserName.Text := LProxyInfo.GetUserName;
    edtPassword.Text := LProxyInfo.GetPassword;
    chkIsNTLM.Checked := LProxyInfo.GetNTLM;
    edtDomain.Text := LProxyInfo.GetDomain;
    if LProxyInfo.GetProxyType = ptHTTPProxy then begin
      rdbtnHttpProxy.Checked := True;
    end else if LProxyInfo.GetProxyType = ptSocks4 then begin
      rdbtnSocks4.Checked := True;
    end else if LProxyInfo.GetProxyType = ptSocks5 then begin
      rdbtnSocks5.Checked := True;
    end;
    chkIsUseProxyClick(nil);
    chkIsNTLMClick(nil);
  end;
end;

procedure TLoginSettingUI.UpdateLoginSettingDataToUserData;
var
  LProxyInfo: IProxyInfo;
begin
  if FConfig <> nil then begin
    LProxyInfo := FConfig.GetProxyInfo;
    LProxyInfo.SetUse(chkIsUseProxy.Checked);
    LProxyInfo.SetIP(edtProxyIP.Text);
    LProxyInfo.SetPort(sedtProxyPort.IntValue);
    LProxyInfo.SetUserName(edtUserName.Text);
    LProxyInfo.SetPassword(edtPassword.Text);
    LProxyInfo.SetNTLM(chkIsNTLM.Checked);
    LProxyInfo.SetDomain(edtDomain.Text);
    if rdbtnHttpProxy.Checked then begin
      LProxyInfo.SetProxyType(ptHTTPProxy);
    end else if rdbtnSocks4.Checked then begin
      LProxyInfo.SetProxyType(ptSocks4);
    end else if rdbtnSocks4.Checked then begin
      LProxyInfo.SetProxyType(ptSocks5);
    end else begin
      LProxyInfo.SetProxyType(ptNoProxy);
    end;
    LProxyInfo.SaveCache;
  end;
end;

procedure TLoginSettingUI.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TLoginSettingUI.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TLoginSettingUI.chkIsNTLMClick(Sender: TObject);
begin
  lblDomain.Enabled := chkIsNTLM.Checked and chkIsUseProxy.Checked;
  edtDomain.Enabled := chkIsNTLM.Checked and chkIsUseProxy.Checked;
end;

procedure TLoginSettingUI.chkIsUseProxyClick(Sender: TObject);
begin
  lblProxyIP.Enabled := chkIsUseProxy.Checked;
  edtProxyIP.Enabled := chkIsUseProxy.Checked;

  lblProxyPort.Enabled := chkIsUseProxy.Checked;
  sedtProxyPort.Enabled := chkIsUseProxy.Checked;

  lblProxyType.Enabled := chkIsUseProxy.Checked;
  rdbtnHttpProxy.Enabled := chkIsUseProxy.Checked;
  rdbtnSocks5.Enabled := chkIsUseProxy.Checked;
  rdbtnSocks4.Enabled := chkIsUseProxy.Checked;

  lblUserInfo.Enabled := chkIsUseProxy.Checked;

  lblUserName.Enabled := chkIsUseProxy.Checked;
  edtUserName.Enabled := chkIsUseProxy.Checked;

  lblPassword.Enabled := chkIsUseProxy.Checked;
  edtPassword.Enabled := chkIsUseProxy.Checked;

  chkIsNTLM.Enabled := chkIsUseProxy.Checked;
  lblDomain.Enabled := chkIsNTLM.Checked and chkIsUseProxy.Checked;
  edtDomain.Enabled := chkIsNTLM.Checked and chkIsUseProxy.Checked;
end;

end.
