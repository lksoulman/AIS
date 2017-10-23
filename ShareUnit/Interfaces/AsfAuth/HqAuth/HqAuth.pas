unit HqAuth;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Hq Authority Interface
// Author£º      lksoulman
// Date£º        2017-8-30
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Hq Authority Interface
  IHqAuth = Interface(IInterface)
    ['{AA8B2C32-CFFF-4FBC-A427-D61B27D821CA}']
    // Is Has HK Real Authority
    function GetIsHasHKReal: Boolean; safecall;
    // Is Has Level2 Authority
    function GetIsHasLevel2: Boolean; safecall;
    // Get Level2 UserName
    function GetLevel2UserName: WideString; safecall;
    // Get Level2 Password
    function GetLevel2Password: WideString; safecall;
  end;

implementation

end.
