unit WebInfo;

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
  UrlInfo,
  Windows,
  Classes,
  SysUtils;

type


  // �û���Ϣ�ӿ�
  IWebInfo = Interface(IInterface)
    ['{2BEFE464-BC6A-4C8A-A2F3-610EFBD3AE4B}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��������
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // ��ȡ url
    function GetUrl(AWebID: Integer): WideString; safecall;
    // ��ȡ UrlInfo
    function GetUrlInfo(AWebID: Integer): IUrlInfo; safecall;
  end;

implementation

end.
