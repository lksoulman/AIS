unit HqKLinePeriod;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-26
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonObject,
  HqIndicatorDataMgr;

type

  // K����������
  THqKLinePeriodType = (ptMinute,       // 1��������
                        ptMinute5,      // 5��������
                        ptMinute15,     // 15��������
                        ptMinute30,     // 30��������
                        ptMinute60,     // 60��������
                        ptDay,          // ��������
                        ptWeek,         // ��������
                        ptMonth         // ��������
                        );

  // ��Ȩ����
  THqKLineExerType = (etOriginal,       // ԭʼ
                      etForward,        // ǰ��Ȩ
                      etBackward);      // ��Ȩ

  // ��Ȩ����
  THqKLineExerItem = record
    Date: Integer;
    ForwardFactor: Double;              // ǰ��Ȩ��ȷ��Ȩ����
    ForwardConst: Double;               // ǰ��Ȩ��ȷ��Ȩ����
    BackwardFactor: Double;             // ��Ȩ��ȷ��Ȩ����
    BackwardConst: Double;              // ��Ȩ��ȷ��Ȩ����
    Caption: string;
  end;

  // ��Ȩ����ָ��
  PHqKLineExerItem = ^THqKLineExerItem;

  TPHqKLineExerItemDynArray = Array Of PHqKLineExerItem;

  // K��������
  THqKLineItem = packed record
    DateTime: Int64;                    // ʱ�� (yyyymmddHHMM)
    PriceOpen: Double;                  // ���̼�
    PriceHigh: Double;                  // ��߼�
    PriceLow: Double;                   // ��ͼ�
    PriceClose: Double;                 // ���̼�
    PrevClose: Double;                  // ǰ�ռ�
    SettlePrice: Double;                // �����
    Position: Double;                   // �ֲ���
    Volume: Double;                     // �ɽ���
    Turnover: Double;                   // �ɽ���
    Change: Double;                     // �ǵ�
    ChangeRate: Double;                 // �ǵ���
    ChangeHand: Double;                 // ������
    Amplitude: Double;                  // ���
  end;

  // K��������ָ��
  PHqKLineItem = ^THqKLineItem;

  TPHqKLineItemDynArray = Array Of PHqKLineItem;

  // ����ͳ������
  THqKLineAreaData = packed record
    PeriodType: THqKLinePeriodType;     // ��������
    StartDate: TDateTime;               // ��ʼ����
    EndDate: TDateTime;                 // ��������
    TotalDays: Integer;                 // ��������
    PrevClose: Double;                  // ǰ�ռ�
    AveragePrice: Double;               // ����
    OpenPrice: Double;                  // ���̼�
    HighPrice: Double;                  // ��߼�
    LowPrice: Double;                   // ��ͼ�
    ClosePrice: Double;                 // ���̼�
    Turnover: Double;                   // �ɽ���
    Volume: Double;                     // �ɽ���
    Change: Double;                     // �ǵ�
    ChangeRate: Double;                 // �ǵ���
    Amplitude: Double;                  // ���
    ChangeHand: Double;                 // ������
    UpNum: Integer;                     // ���߸���
    DownNum: Integer;                   // ���߸���
  end;

  // ����ͳ������ָ��
  PHqKLineAreaData = ^THqKLineAreaData;

  // ��������
  THqKLineChipData = packed record
    MinPrice: Double;                   // ��ͼ�
    MaxPrice: Double;                   // ��߼�
    MaxValue: Double;                   // ��ĳ���
    Len: Integer;                       // ���볤��
    Data: TDoubleDynArray;              // ��������
  end;

  // ��������ָ��
  PHqKLineChipData = ^THqKLineChipData;

  // K���������ݽӿ�
  IHqKLinePeriod = Interface(IInterface)
    ['{7797324B-5204-447C-BF65-C992F0AD1BDE}']
    //��ȡ���ݵ���������
    function GetPeriodType: THqKLinePeriodType;
    //��ȡ��Ӧ��ָ�����ݹ�����
    function GetIndicatorDataMgr(AExerType: THqKLineExerType): IHqIndicatorDataMgr;
    //�����Ƿ��Ѿ���ȡ��ȫ��
    function GetIsAllData: Boolean;
    //��ȡ����������
    function GetItemCount: Integer;
    //������Ż�ȡ������
    function GetItem(AExerType: THqKLineExerType; AIndex: Integer): PHqKLineItem;
    //���ݸ�Ȩ���ͻ�ȡ��Ӧ������������
    function GetItemArray(AExerType: THqKLineExerType): TPHqKLineItemDynArray;

    //����ʱ����Ҷ�Ӧ���
    //ADateTime: ����+ʱ�䣬��ʽΪ(yyyymmddHHMM)
    //AFlag: ƥ���־ 0:���� 1:С�ڵ��ڲ�ѯֵ�������� 2:���ڵ��ڲ�ѯֵ����С���
    function DateTimeToIndex(ADateTime: Int64; AFlag: Integer = 0): Integer;
    //��ȡ��������
    function GetChipData(AStart, AEnd: Integer; AExerType: THqKLineExerType): PHqKLineChipData;
    //��ȡ����ͳ������
    function GetAreaData(AStart, AEnd: Integer; AExerType: THqKLineExerType): PHqKLineAreaData;

    //��������
    property PeriodType: THqKLinePeriodType read GetPeriodType;
    //��Ӧָ�����ݹ�����
    property IndicatorDataMgrs[AExerType: THqKLineExerType]: IHqIndicatorDataMgr read GetIndicatorDataMgr;
    //�����Ƿ��Ѿ���ȡ��ȫ��
    property IsAllData: Boolean read GetIsAllData;
    //����������
    property ItemCount: Integer read GetItemCount;
    //������������
    property Items[AExerType: THqKLineExerType; AIndex: Integer]: PHqKLineItem read GetItem;
    //����������������
    property ItemArrays[AExerType: THqKLineExerType]: TPHqKLineItemDynArray read GetItemArray;
  end;

implementation

end.
