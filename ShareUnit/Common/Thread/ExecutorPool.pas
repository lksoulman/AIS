unit ExecutorPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Pool Interface
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

  // Executor Pool Interface
  IExecutorPool = Interface(IExecutorService)
    ['{8629F89D-4A93-4857-9746-043A1FA3D61D}']
    // Set Pool Max and Min Size
    procedure SetPoolThread(AMaxPoolSize, AMinPoolSize: Integer); safecall;
  end;

implementation

end.
