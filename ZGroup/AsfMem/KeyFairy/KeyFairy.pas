unit KeyFairy;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Key Fairy Interface
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
  SecuMain,
  KeyFairyType,
  KeyFairyItem,
  CommonDynArray;

type

  // Key Fairy Interface
  IKeyFairy = Interface(IInterface)
    // Get Command Id
    function GetCommandId: Integer; safecall;
    // Get Key Fairy Type
    function GetKeyFairyType: TKeyFairyType; safecall;
    // Get Key Fairy Type Item (Id is InnerCode, shortcut key Id)
    function GetKeyFairyItem(AId: Integer): PKeyFairyItem; safecall;
    // Add Key Fairy Item
    function AddKeyFairyItem(APKeyFairyItem: PKeyFairyItem): Boolean; safecall;
    // Set Search Key Char Type
    function SetSearchKeyCharType(AKeyCharType: TKeyCharType): Boolean; safecall;
    // Fuzzy Search Updating
    function FuzzySearchUpdating(AKey: string; AKeyFairyItems: TDynArray<PKeyFairyItem>): Boolean; safecall;
    // Fuzzy Search No Updating
    function FuzzySearchNoUpdating(AKey: string; AKeyFairyItems: TDynArray<PKeyFairyItem>): Boolean; safecall;
  end;

implementation


end.
