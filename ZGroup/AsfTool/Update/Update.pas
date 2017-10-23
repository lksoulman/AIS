unit Update;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Interface
// Author£º      lksoulman
// Date£º        2017-10-12
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Update Interface
  IUpdate = interface(IInterface)
    ['{72ABCA73-EEDF-446A-97CE-BB41B7FB485E}']
    // Generate Server Update List
    procedure GenerateServerUpdateList; safecall;
  end;

implementation

end.
