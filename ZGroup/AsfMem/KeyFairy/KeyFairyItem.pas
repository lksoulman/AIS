unit KeyFairyItem;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Key Fairy Item
// Author��      lksoulman
// Date��        2017-9-3
// Comments��
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
