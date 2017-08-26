unit HqMinute;

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
  SysUtils;

type

  //分钟数据项
  THqMinuteItem = packed record
    Time: Integer;                //时间
    Price: Double;                //价格
    AveragePrice: Double;         //均价
    Volume: Double;               //成交量
    Turnover: Double;             //成交额
    change: Double;               //涨跌
    ChangeRate: Double;           //涨跌幅
    TotalVolume: Double;          //总成交量
    TotalTurnover: Double;        //总成交额
  end;

  // 分钟数据项指针
  PHqMinuteItem = ^THqMinuteItem;

  // 单日分时数据接口
  IHqMinute = Interface(IInterface)
    ['{F67C1F58-BC7A-4771-8282-06EF5DFF5444}']
    // 获取日期
    function GetDate: Integer;
    // 获取前收价
    function GetPrevClose: Double;
    // 获取今日最高价
    function GetPriceHigh: Double;
    // 获取今日最低价
    function GetPriceLow: Double;
    // 获取最大成交量(每分钟)
    function GetMaxVolume: Double;
    // 获取最大成交金额(每分钟)
    function GetMaxTurnover: Double;
    // 获取数据项数量
    function GetItemCount: Integer;
    // 根据下标获取数据项
    function GetItem(AIndex: Integer): PHqMinuteItem;
  end;

implementation

end.
