unit HqDataCenter;

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
  AppContext,
  HqRealData,
  HqTickData,
  HqKLineData,
  HqMinuteData;

type

  // ������������
  IHqDataCenter = Interface(IInterface)
    ['{D0388041-B623-46E0-8011-DEF35ABCC5AC}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��ȡʵʱ���ݽӿ�
    function GetRealData(ACode: string): IHqRealData; safecall;
    // ��ȡ�ֱ����ݽӿ�
    function GetTickData(ACode: string): IHqTickData; safecall;
    // ��ȡK�����ݽӿ�
    function GetKLineData(ACode: string): IHqKLineData; safecall;
    // ��ȡ��ʱ���ݽӿ�
    function GetMinuteData(ACode: string): IHqMinuteData; safecall;

    // ʵʱ����
    property RealData[Code: string]: IHqRealData read GetRealData;
    // �ֱ�����
    property TickData[Code: string]: IHqTickData read GetTickData;
    // K������
    property KLineData[Code: string]: IHqKLineData read GetKLineData;
    // ��ʱ����
    property MinuteData[Code: string]: IHqMinuteData read GetMinuteData;
  end;

implementation

end.
