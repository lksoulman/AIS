unit ProxyInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-21
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  GFDataMngr_TLB;

type

  TProxyType = (ptNoProxy =   $00000001,
                ptHTTPProxy = $00000002,
                ptSocks4 =    $00000003,
                ptSocks5 =    $00000004);

  IProxyInfo = Interface(IInterface)
    ['{32F1B998-39F2-4411-87B3-763A1EE39A9A}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ���滺��
    procedure SaveCache; safecall;
    // ���ػ���
    procedure LoadCache; safecall;
    // �ָ�Ĭ��
    procedure RestoreDefault; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // �ǲ�������
    function GetUse: boolean; safecall;
    // �����ǲ�������
    procedure SetUse(AUse: Boolean); safecall;
    // ���� IP
    function GetIP: WideString; safecall;
    // ���� IP
    procedure SetIP(AIP: WideString); safecall;
    // �˿ں�
    function GetPort: Integer; safecall;
    // �˿ں�
    procedure SetPort(APort: Integer); safecall;
    // �û���
    function GetUserName: WideString; safecall;
    // �û���
    procedure SetUserName(AUserName: WideString); safecall;
    // ����
    function GetPassword: WideString; safecall;
    // ����
    procedure SetPassword(APassword: WideString); safecall;
    // �ǲ�����������
    function GetNTLM: Boolean; safecall;
    // �ǲ�����������
    procedure SetNTLM(ANTLM: Boolean); safecall;
    // ����
    function GetDomain: WideString; safecall;
    // ����
    procedure SetDomain(ADomain: WideString); safecall;
    // ��������
    function GetProxyType: TProxyType; safecall;
    // ��������
    procedure SetProxyType(AProxyType: TProxyType); safecall;
    // ��ȡ ProxyKind
    function GetProxyKindEnum: ProxyKindEnum; safecall;
  end;

implementation

end.
