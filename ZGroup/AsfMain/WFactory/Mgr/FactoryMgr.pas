unit FactoryMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Factory Manager Interface for multiple dynamic libraries
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    Factory Manager interface for multiple dynamic libraries.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Factory Manager Interface for multiple dynamic libraries
  IFactoryMgr = Interface(IInterface)
    ['{7015654C-2B1D-46A0-8996-634D50454560}']
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface); safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; safecall;
    // Create interface
    function CreatePlugInById(APlugInId: Integer): IInterface; safecall;
  end;

implementation

end.
