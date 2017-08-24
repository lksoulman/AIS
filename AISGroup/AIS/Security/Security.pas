unit Security;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-23
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SecurityType;

type

  // ֤ȯ��Ϣ�ӿ�
  ISecurity = Interface(IInterface)
    ['{8008149C-3763-4996-A849-828A7DA5A043}']
    // ��ȡ֤ȯ�ڲ�����
    function GetInnerCode: Integer; safecall;
    // ��ȡ֤ȯ����
    function GetSecuCode: WideString; safecall;
    // ��ȡ֤ȯ��׺
    function GetSuffix: WideString; safecall;
    // ��ȡ֤ȯ�г�
    function GetSecuMarket: Integer; safecall;
    // ��ȡ֤ȯ֤ȯ���
    function GetSecuCategory: Integer; safecall;
    // ��ȡ֤ȯ���
    function GetSecuAbbr: WideString; safecall;
    // ��ȡ֤ȯƴ��
    function GetSecuSpell: WideString; safecall;
    // ��ȡ���������
    function GetFormerAbbr: WideString; safecall;
    // ��ȡ������ƴ��
    function GetFormerSpell: WideString; safecall;
    // ֤ȯ����
    function GetSecurityType: TSecurityType; safecall;
    // ����״̬
    function GetListedStateType: TListedStateType; safecall;
    // ������ȯ����
    function GetSecuMarginType: TMarginType; safecall;
    // ͨ����
    function GetSecuThroughType: TThroughType; safecall;
  end;

  TSecuritys = array of ISecurity;

implementation

end.
