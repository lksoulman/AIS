unit HqKLineData;

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
  HqKLinePeriod;

type

  // K�����ݽӿ�
  IHqKLineData = Interface(IInterface)
    ['{86B284B5-3F28-40F2-AAB5-B9C05FB91DEE}']
    // ��ȡ֤ȯ����
    function GetCode: string;
    // �����������ͻ�ȡK������
    function GetPeriodKLine(APeriodType: THqKLinePeriodType): IHqKLinePeriod;
    // ��ȡ��Ȩ��Ϣ����
    function GetExerItemCount: Integer;
    // ������Ż�ȡ��Ȩ��Ϣ
    function GetExerItem(AIndex: Integer): PHqKLineExerItem;

    // ֤ȯ����
    property Code: string read GetCode;
    // ����K��������
    property PeriodKlines[APeroidType: THqKLinePeriodType]: IHqKLinePeriod read GetPeriodKLine;
    // ��Ȩ��Ϣ����
    property ExerInfoCount: Integer read GetExerItemCount;
    // ��Ȩ��Ϣ����
    property ExerInfos[AIndex: Integer]: PHqKLineExerItem read GetExerItem;
  end;

implementation

end.

