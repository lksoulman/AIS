unit Login;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Login Interface
// Author£º      lksoulman
// Date£º        2017-9-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ServiceType;

type

  // Login Interface
  ILogin = interface(IInterface)
    ['{FBCEB4C9-C2BC-43D6-AD62-F5CBFCBAF990}']
    // Is Login Service
    function IsLoginService(AServiceType: TServiceType): Boolean; safecall;
  end;

implementation

end.
