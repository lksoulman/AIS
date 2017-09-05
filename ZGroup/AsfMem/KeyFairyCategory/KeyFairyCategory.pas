unit KeyFairyCategory;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Key Fairy Category
// Author��      lksoulman
// Date��        2017-8-24
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
    FKeyFairyType: T
    FPSecuMainItem: PSecuMainItem;
  end;

  PKeyFairyItem = ^TKeyFairyItem;

  IKeyFairy = Interface(IInterface)

  end;

implementation

end.
