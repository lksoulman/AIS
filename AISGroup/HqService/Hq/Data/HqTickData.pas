unit HqTickData;

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
  SysUtils;

type

  //�ֱ�������
  THqTickItem = packed record
    Time: Integer;                //ʱ��
    Price: Double;                //�۸�
    Volume: Double;               //�ɽ���
    Turnover: Double;             //�ɽ���
    Direction: Word;              //�ɽ�����(0�� 1��)
    Count: Integer;               //�ɽ�����
    DealProperty: Word;           //��ָ�ڻ��ɽ����� 1: �տ�; 2: ��ƽ; 3: �ջ�; 4: �࿪ 5: ��ƽ; 6: �໻; 7: ˫��; 8: ˫ƽ
    PositionChange: Integer;      //��ָ�ڻ��ֲ����仯
  end;

  // �ֱ�������ָ��
  PHqTickItem = ^THqTickItem;

  // �ֱ����ݽӿ�
  IHqTickData = Interface(IInterface)
    ['{4B38F694-EE2C-4C3B-8B49-76A6D1220CBC}']
    //��ȡ֤ȯ����
    function GetCode: string;
    //��ȡ�ֱ�������
    function GetItemCount: Integer;
    //������Ż�ȡ�ֱ���
    function GetItem(AIndex: Integer): PHqTickItem;

    //֤ȯ����
    property Code: string read GetCode;
    //�ֱ�������
    property ItemCount: Integer read GetItemCount;
    //�ֱ�������
    property Items[AIndex: Integer]: PHqTickItem read GetItem;
  end;

implementation

end.
