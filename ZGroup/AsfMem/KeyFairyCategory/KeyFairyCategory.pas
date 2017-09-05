unit KeyFairyCategory;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Key Fairy Category
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
  SecuMain;

type

  // Key Fairy Item
  TKeyFairyItem = packed record
    FKeyFairyType: T
    FPSecuMainItem: PSecuMainItem;
  end;

  PKeyFairyItem = ^TKeyFairyItem;

  IKeyFairy = Interface(IInterface)

  end;

implementation

end.
