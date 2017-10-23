unit Update;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Update Interface
// Author��      lksoulman
// Date��        2017-10-12
// Comments��
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
