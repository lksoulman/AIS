unit ExecutorTask;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-5-1
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes;

type

  // Executor Task Interface
  IExecutorTask = interface(IInterface)
    ['{31F8B49C-CB4A-434C-A7EE-D03486782ADC}']
    // Call Back
    procedure CallBack;
    // Thread Execute Run, AObject is Call Thread
    procedure Run(AObject: TObject);
  end;

implementation

end.

