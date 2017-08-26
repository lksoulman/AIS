unit HqKLineDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
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

  // K线数据
  THqKLineDataImpl = class(TAutoInterfacedObject, IHqKLineData)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqKLineData }

    // 获取证券代码
    function GetCode: string;
    // 根据周期类型获取K线数据
    function GetPeriodKLine(APeriodType: THqKLinePeriodType): IHqKLinePeriod;
    // 获取复权信息数量
    function GetExerItemCount: Integer;
    // 根据序号获取复权信息
    function GetExerItem(AIndex: Integer): PHqKLineExerItem;

    // 证券代码
    property Code: string read GetCode;
    // 周期K线索引器
    property PeriodKlines[APeroidType: THqKLinePeriodType]: IHqKLinePeriod read GetPeriodKLine;
    // 复权信息数量
    property ExerInfoCount: Integer read GetExerItemCount;
    // 复权信息索引
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
