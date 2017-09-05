unit SyncAsync;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Synchronous and asynchronous interface
// Author£º      lksoulman
// Date£º        2017-7-1
// Comments£º    This interface is implemented by all functional classes and
//               business classes.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext;

type

  // Synchronous and asynchronous interface
  ISyncAsync = Interface(IInterface)
    ['{2B68A2DA-6712-42F8-9DD4-D11C33FAB5A6}']
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
  end;

implementation

end.
