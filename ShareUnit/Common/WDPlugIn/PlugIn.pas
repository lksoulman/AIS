unit PlugIn;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Plug-In interface
// Author£º      lksoulman
// Date£º        2017-8-16
// Comments£º    All functions must be encapsulated as a plug-in.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext;

type

  // Plug-In interface
  IPlugIn = Interface(IInterface)
    ['{F436FEEF-B7E4-4DBE-8615-F4A1CE553B94}']
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; safecall;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; safecall;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; safecall;
    // Obtain dependency
    function Dependences: WideString; safecall;
    // Get the plug-in interface implementation type name
    function GetClassName: WideString; safecall;
  end;

implementation

end.

