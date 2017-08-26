unit UrlInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  NativeXml;

type


  // �û���Ϣ�ӿ�
  IUrlInfo = Interface(IInterface)
    ['{2BEFE464-BC6A-4C8A-A2F3-610EFBD3AE4B}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��ȡȥ url ��ַ
    function GetUrl: WideString; safecall;
    // ���� url
    procedure SetUrl(AUrl: WideString); safecall;
    // ��ȡ webID
    function GetWebID: Integer; safecall;
    // ���� webID
    procedure SetWebID(AWebID: Integer); safecall;
    // ��ȡ����������
    function GetServerName: WideString; safecall;
    // ���÷���������
    procedure SetServerName(AServerName: WideString); safecall;
    // ��ȡ����
    function GetDescription: WideString; safecall;
    // ��������
    procedure SetDescription(ADescription: WideString); safecall;
  end;

implementation

end.
