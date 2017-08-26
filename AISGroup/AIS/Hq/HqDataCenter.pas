unit HqDataCenter;

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
  AppContext,
  HqRealData,
  HqTickData,
  HqKLineData,
  HqMinuteData;

type

  // 行情数据中心
  IHqDataCenter = Interface(IInterface)
    ['{D0388041-B623-46E0-8011-DEF35ABCC5AC}']
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 获取实时数据接口
    function GetRealData(ACode: string): IHqRealData; safecall;
    // 获取分笔数据接口
    function GetTickData(ACode: string): IHqTickData; safecall;
    // 获取K线数据接口
    function GetKLineData(ACode: string): IHqKLineData; safecall;
    // 获取分时数据接口
    function GetMinuteData(ACode: string): IHqMinuteData; safecall;

    // 实时数据
    property RealData[Code: string]: IHqRealData read GetRealData;
    // 分笔数据
    property TickData[Code: string]: IHqTickData read GetTickData;
    // K线数据
    property KLineData[Code: string]: IHqKLineData read GetKLineData;
    // 分时数据
    property MinuteData[Code: string]: IHqMinuteData read GetMinuteData;
  end;

implementation

end.
