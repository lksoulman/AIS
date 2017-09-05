unit Behavior;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Behavior Interface
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Behavior Interface
  IBehavior = Interface(IInterface)
    ['{45E8FE12-B9DA-4370-BFBD-FB91CDC3E407}']
    // Add Behavior
    procedure Add(ABehavior: WideString); safecall;
  end;

implementation

end.
