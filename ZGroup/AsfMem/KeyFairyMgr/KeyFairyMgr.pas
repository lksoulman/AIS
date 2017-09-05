unit KeyFairyMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Key Fairy Manager Interface
// Author£º      lksoulman
// Date£º        2017-8-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  KeyFairyItem,
  CommonDynArray;

type

  // Call Back
  TKeyFairyMgrCallBack = procedure (AKeyFairyItems: TDynArray<PKeyFairyItem>) of Object;

  // Key Fairy Manager Interface
  IKeyFairyMgr = Interface(IInterface)
    ['{D7D7DEB8-9D5D-4C2F-9995-3C761E938249}']
    // Fuzzy Search
    procedure FuzzySearch(AKey: string); safecall;
    // Set Call Back
    procedure SetSearchCallBack(ACallBack: TKeyFairyMgrCallBack); safecall;
  end;

implementation

end.
