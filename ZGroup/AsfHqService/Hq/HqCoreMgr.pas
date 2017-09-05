unit HqCoreMgr;

interface

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Hq core manager interface
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
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

  // Hq core manager interface
  IHqCoreMgr = Interface(IInterface)
    ['{C541F3C9-505D-4C1B-A742-9745434BAB2B}']
    // Get Hq data center interface
    function GetHqDataCenter: IHqDataCenter; safecall;
    // Get Hq indicator manager interface
    function GetHqIndicatorMgr: IHqIndicatorMgr; safecall;
    // Get Hq subcribe adapter interface
    function GetHqSubcribeAdapter: IHqSubcribeAdapter; safecall;
  end;

implementation

end.
