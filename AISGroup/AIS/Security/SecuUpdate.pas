unit SecuUpdate;

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
  SysUtils;

type

  // ֤ȯ��Ϣ�޸Ľӿ�
  ISecuUpdate = Interface(IInterface)
    ['{EEBD75BE-39CF-4DBB-B3B3-4719A3E4B867}']
    // ��������
    procedure UpdateSecurityData; safecall;
    // ��������
    procedure SetInnerCode(AInnerCode: Integer); safecall;
    // ����֤ȯ����
    procedure SetSecuCode(ASecuCode: string); safecall;
    // ���ô���֤ȯ��׺
    procedure SetSuffic(ASuffix: string); safecall;
    // ����֤ȯ���
    procedure SetSecuAbbr(ASecuAbbr: string); safecall;
    // ����֤ȯƴ��
    procedure SetSecuSpell(ASecuSpell: string); safecall;
    // ����֤ȯ���������
    procedure SetFormerAbbr(AFormerAbbr: string); safecall;
    // ����֤ȯ������ƴ��
    procedure SetFormerSpell(AFormerSpell: string); safecall;
    // ����֤ȯ�г�
    procedure SetSecuMarket(ASecuMarket: Byte); safecall;
    // ��������״̬
    procedure SetListedState(AListedState: Byte); safecall;
    // ����֤ȯ����
    procedure SetSecuCategory(ASecuCategory: Byte); safecall;
    // ����������ȯ��ͨ����
    procedure SetSecuCategoryI(ASecuCategoryI: Byte); safecall;
  end;

implementation

end.
