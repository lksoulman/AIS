unit FactoryMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Factory Manager Interface for multiple dynamic libraries
// Author��      lksoulman
// Date��        2017-8-29
// Comments��    Factory Manager interface for multiple dynamic libraries.
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
