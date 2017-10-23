unit ProAuth;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Product Authority interface
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

  // Product Authority interface
  IProAuth = Interface(IInterface)
    ['{AC942CE8-E759-4DEF-8841-765FC692A7F9}']
    // Get Is Has The Product Function Permission
    function GetIsHasAuth(AFuncNo: Integer): Boolean; safecall;
  end;

implementation

end.
