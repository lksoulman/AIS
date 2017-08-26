unit HqKLineData;

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
  HqKLinePeriod;

type

  // K线数据接口
  IHqKLineData = Interface(IInterface)
    ['{86B284B5-3F28-40F2-AAB5-B9C05FB91DEE}']
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

end.

