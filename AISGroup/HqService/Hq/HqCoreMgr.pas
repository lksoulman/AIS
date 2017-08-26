unit HqCoreMgr;

interface

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

uses
  Windows,
  Classes,
  SysUtils,
  HqDataCenter,
  HqIndicatorMgr,
  HqSubcribeAdapter;

type

  // 行情核心管理接口
  IHqCoreMgr = Interface(IInterface)
    ['{C541F3C9-505D-4C1B-A742-9745434BAB2B}']
    // 获取数据中心接口
    function GetHqDataCenter: IHqDataCenter; safecall;
    // 获取指标管理接口
    function GetHqIndicatorMgr: IHqIndicatorMgr; safecall;
    // 获取订阅适配器接口
    function GetHqSubcribeAdapter: IHqSubcribeAdapter; safecall;
  end;

implementation

end.
