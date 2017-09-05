unit HqKLineDataImpl;

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
  HqKLineData,
  HqKLinePeriod,
  CommonRefCounter;

type

  // K������
  THqKLineDataImpl = class(TAutoInterfacedObject, IHqKLineData)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqKLineData }

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

{ THqKLineDataImpl }

constructor THqKLineDataImpl.Create;
begin
  inherited;

end;

destructor THqKLineDataImpl.Destroy;
begin

  inherited;
end;

function THqKLineDataImpl.GetCode: string;
begin

end;

function THqKLineDataImpl.GetPeriodKLine(APeriodType: THqKLinePeriodType): IHqKLinePeriod;
begin

end;

function THqKLineDataImpl.GetExerItemCount: Integer;
begin

end;

function THqKLineDataImpl.GetExerItem(AIndex: Integer): PHqKLineExerItem;
begin

end;

end.
