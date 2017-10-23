unit ExecutorFixed;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Fixed Interface
// Author£º      lksoulman
// Date£º        2017-5-1
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ExecutorService;

type

  // Executor Fixed Interface
  IExecutorFixed = Interface(IExecutorService)
    ['{8629F89D-4A93-4857-9746-043A1FA3D61D}']
    // Set Fixed Thread Count
    procedure SetFixedThread(ACount: Integer); safecall;
  end;

implementation

end.
