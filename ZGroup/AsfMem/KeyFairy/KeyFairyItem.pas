unit KeyFairyItem;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Key Fairy Item
// Author£º      lksoulman
// Date£º        2017-9-3
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
    FId: Integer;
    FKeyFairy: IInterface;
    FPSecuMainItem: PSecuMainItem;
  end;

  // Key Fairy Item Pointer
  PKeyFairyItem = ^TKeyFairyItem;

implementation

end.
