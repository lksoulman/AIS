unit UserInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-22
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  // ��¼����
  TLoginType = (ltUFX,          // UFX ��¼����
                ltGIL,      // ��Դ��¼����
                ltPBOX);        // PBox ��¼����

  // �û���Ϣ�ӿ�
  IUserInfo = Interface(IInterface)
    ['{D1DB6423-8030-4125-9EFF-D63DF03957FC}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ���滺��
    procedure SaveCache; safecall;
    // ���ػ���
    procedure LoadCache; safecall;
    // ���ð���Ϣ
    procedure ResetBindInfo; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // �������
    function GetProNo: WideString; safecall;
    // �������
    procedure SetProNo(AProNo: WideString); safecall;
    // ��Ʒ���
    function GetOrgNo: WideString; safecall;
    // ��Ʒ���
    procedure SetOrgNo(AOrgNo: WideString); safecall;
    // �ʲ����
    function GetAssetNo: WideString; safecall;
    // �ʲ����
    procedure SetAssetNo(AAssetNo: WideString); safecall;
    // ��ȡ�ǲ��Ǳ�������
    function GetSavePassword: Boolean; safecall;
    // �����ǲ��Ǳ�������
    procedure SetSavePassword(ASavePassword: boolean); safecall;
    // ��Դ�û�����
    function GetUserName: WideString; safecall;
    // ��Դ�û�����
    procedure SetUserName(AUserName: WideString); safecall;
    // ��Դ�û�����
    function GetUserPassword: WideString; safecall;
    // ��ȡ���ĵ��û�����
    function GetCiperUserPassword: WideString; safecall;
    // ��Դ�û�����
    procedure SetUserPassword(APassword: WideString); safecall;
    // �ʲ��û�����
    function GetAssetUserName: WideString; safecall;
    // �ʲ��û�����
    procedure SetAssetUserName(AUserName: WideString); safecall;
    // �ʲ��û�����
    function GetAssetUserPassword: WideString; safecall;
    // ��ȡ���ĵ��ʲ��û�����
    function GetCiperAssetUserPassword: WideString; safecall;
    // �û�����
    procedure SetAssetUserPassword(APassword: WideString); safecall;
    // �󶨺�� License
    function GetBindLicense: WideString; safecall;
    // �󶨺�� License
    procedure SetBindLicense(ABindLicense: WideString); safecall;
    // �û����������������
    function GetBindOrgSign: WideString; safecall;
    // �û����������������
    procedure SetBindOrgSign(ABindOrgSign: WideString); safecall;
    // ��ȡ�ǲ�����Ҫ N ����޸�����
    function GetPasswordExpire: boolean; safecall;
    // ��ȡ�����ǲ�����Ҫ N ����޸�����
    procedure SetPasswordExpire(APasswordExpire: boolean); safecall;
    // ��ȡ�����������
    function GetPasswordExpireDays: Integer; safecall;
    // ���������������
    procedure SetPasswordExpireDays(ADay: Integer); safecall;
    // ���÷���˷��ص�������Ϣ Json �ַ���
    procedure SetPasswordInfo(APasswordInfo: string); safecall;
    // ��¼����
    function GetLoginType: TLoginType; safecall;
    // ��¼����
    procedure SetLoginType(ALoginType: TLoginType); safecall;
  end;

implementation

end.
