unit HqKLinePeriod;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-26
// Comments：
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

  // K线周期类型
  THqKLinePeriodType = (ptMinute,       // 1分钟类型
                        ptMinute5,      // 5分钟类型
                        ptMinute15,     // 15分钟类型
                        ptMinute30,     // 30分钟类型
                        ptMinute60,     // 60分钟类型
                        ptDay,          // 日线类型
                        ptWeek,         // 周线类型
                        ptMonth         // 月线类型
                        );

  // 复权类型
  THqKLineExerType = (etOriginal,       // 原始
                      etForward,        // 前复权
                      etBackward);      // 后复权

  // 除权数据
  THqKLineExerItem = record
    Date: Integer;
    ForwardFactor: Double;              // 前复权精确复权因子
    ForwardConst: Double;               // 前复权精确复权常量
    BackwardFactor: Double;             // 后复权精确复权因子
    BackwardConst: Double;              // 后复权精确复权常量
    Caption: string;
  end;

  // 除权数据指针
  PHqKLineExerItem = ^THqKLineExerItem;

  TPHqKLineExerItemDynArray = Array Of PHqKLineExerItem;

  // K线数据项
  THqKLineItem = packed record
    DateTime: Int64;                    // 时间 (yyyymmddHHMM)
    PriceOpen: Double;                  // 开盘价
    PriceHigh: Double;                  // 最高价
    PriceLow: Double;                   // 最低价
    PriceClose: Double;                 // 收盘价
    PrevClose: Double;                  // 前收价
    SettlePrice: Double;                // 结算价
    Position: Double;                   // 持仓量
    Volume: Double;                     // 成交量
    Turnover: Double;                   // 成交额
    Change: Double;                     // 涨跌
    ChangeRate: Double;                 // 涨跌幅
    ChangeHand: Double;                 // 换手率
    Amplitude: Double;                  // 振幅
  end;

  // K线数据项指针
  PHqKLineItem = ^THqKLineItem;

  TPHqKLineItemDynArray = Array Of PHqKLineItem;

  // 区间统计数据
  THqKLineAreaData = packed record
    PeriodType: THqKLinePeriodType;     // 周期类型
    StartDate: TDateTime;               // 开始日期
    EndDate: TDateTime;                 // 结束日期
    TotalDays: Integer;                 // 区间天数
    PrevClose: Double;                  // 前收价
    AveragePrice: Double;               // 均价
    OpenPrice: Double;                  // 开盘价
    HighPrice: Double;                  // 最高价
    LowPrice: Double;                   // 最低价
    ClosePrice: Double;                 // 收盘价
    Turnover: Double;                   // 成交额
    Volume: Double;                     // 成交量
    Change: Double;                     // 涨跌
    ChangeRate: Double;                 // 涨跌幅
    Amplitude: Double;                  // 振幅
    ChangeHand: Double;                 // 换手率
    UpNum: Integer;                     // 阳线个数
    DownNum: Integer;                   // 阴线个数
  end;

  // 区间统计数据指针
  PHqKLineAreaData = ^THqKLineAreaData;

  // 筹码数据
  THqKLineChipData = packed record
    MinPrice: Double;                   // 最低价
    MaxPrice: Double;                   // 最高价
    MaxValue: Double;                   // 最长的筹码
    Len: Integer;                       // 筹码长度
    Data: TDoubleDynArray;              // 筹码数组
  end;

  // 筹码数据指针
  PHqKLineChipData = ^THqKLineChipData;

  // K线周期数据接口
  IHqKLinePeriod = Interface(IInterface)
    ['{7797324B-5204-447C-BF65-C992F0AD1BDE}']
    //获取数据的周期类型
    function GetPeriodType: THqKLinePeriodType;
    //获取对应的指标数据管理器
    function GetIndicatorDataMgr(AExerType: THqKLineExerType): IHqIndicatorDataMgr;
    //数据是否已经获取到全部
    function GetIsAllData: Boolean;
    //获取数据项数量
    function GetItemCount: Integer;
    //根据序号获取数据项
    function GetItem(AExerType: THqKLineExerType; AIndex: Integer): PHqKLineItem;
    //根据复权类型获取对应的数据项数组
    function GetItemArray(AExerType: THqKLineExerType): TPHqKLineItemDynArray;

    //根据时间查找对应序号
    //ADateTime: 日期+时间，格式为(yyyymmddHHMM)
    //AFlag: 匹配标志 0:等于 1:小于等于查询值的最大序号 2:大于等于查询值的最小序号
    function DateTimeToIndex(ADateTime: Int64; AFlag: Integer = 0): Integer;
    //获取筹码数据
    function GetChipData(AStart, AEnd: Integer; AExerType: THqKLineExerType): PHqKLineChipData;
    //获取区间统计数据
    function GetAreaData(AStart, AEnd: Integer; AExerType: THqKLineExerType): PHqKLineAreaData;

    //周期类型
    property PeriodType: THqKLinePeriodType read GetPeriodType;
    //对应指标数据管理器
    property IndicatorDataMgrs[AExerType: THqKLineExerType]: IHqIndicatorDataMgr read GetIndicatorDataMgr;
    //数据是否已经获取到全部
    property IsAllData: Boolean read GetIsAllData;
    //数据项数量
    property ItemCount: Integer read GetItemCount;
    //数据项索引器
    property Items[AExerType: THqKLineExerType; AIndex: Integer]: PHqKLineItem read GetItem;
    //数据项数组索引器
    property ItemArrays[AExerType: THqKLineExerType]: TPHqKLineItemDynArray read GetItemArray;
  end;

implementation

end.
