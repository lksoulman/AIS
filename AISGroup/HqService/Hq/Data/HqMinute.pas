unit HqMinute;

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

  //����������
  THqMinuteItem = packed record
    Time: Integer;                //ʱ��
    Price: Double;                //�۸�
    AveragePrice: Double;         //����
    Volume: Double;               //�ɽ���
    Turnover: Double;             //�ɽ���
    change: Double;               //�ǵ�
    ChangeRate: Double;           //�ǵ���
    TotalVolume: Double;          //�ܳɽ���
    TotalTurnover: Double;        //�ܳɽ���
  end;

  // ����������ָ��
  PHqMinuteItem = ^THqMinuteItem;

  // ���շ�ʱ���ݽӿ�
  IHqMinute = Interface(IInterface)
    ['{F67C1F58-BC7A-4771-8282-06EF5DFF5444}']
    // ��ȡ����
    function GetDate: Integer;
    // ��ȡǰ�ռ�
    function GetPrevClose: Double;
    // ��ȡ������߼�
    function GetPriceHigh: Double;
    // ��ȡ������ͼ�
    function GetPriceLow: Double;
    // ��ȡ���ɽ���(ÿ����)
    function GetMaxVolume: Double;
    // ��ȡ���ɽ����(ÿ����)
    function GetMaxTurnover: Double;
    // ��ȡ����������
    function GetItemCount: Integer;
    // �����±��ȡ������
    function GetItem(AIndex: Integer): PHqMinuteItem;
  end;

implementation

end.
