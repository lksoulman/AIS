unit HqAuth;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Hq authority interface
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

  // Hq authority interface
  IHqAuth = Interface(IInterface)
    ['{AA8B2C32-CFFF-4FBC-A427-D61B27D821CA}']
    // is not has HK Real authority
    function GetIsHasHKReal: Boolean; safecall;
    // is not has Level2 authority
    function GetIsHasLevel2: Boolean; safecall;
    // Get Level2 username
    function GetLevel2UserName: WideString; safecall;
    // Get Level2 password
    function GetLevel2Password: WideString; safecall;
  end;

implementation

end.
