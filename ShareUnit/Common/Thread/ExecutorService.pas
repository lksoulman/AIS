unit ExecutorService;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Service Interface
// Author£º      lksoulman
// Date£º        2017-5-1
// Comments£º    {Doug Lea thread}
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ExecutorTask,
  ExecutorThread;

type

  // Create Executor Function
  TCreateExecutorFunc = function: TExecutorThread of Object;

  // Executor Service Interface
  IExecutorService = interface(IInterface)
    ['{31F8B49C-CB4A-434C-A7EE-D03486782ADC}']
    // Start
    procedure Start; safecall;
    // Shutdown
    procedure ShutDown; safecall;
    // Is Terminated
    function IsTerminated: boolean; safecall;
    // Submit Task
    function SubmitTask(ATask: IExecutorTask): Boolean; safecall;
    // Set Create Executor Function
    function SetCreateExecutorFunc(AFunc: TCreateExecutorFunc): Boolean; safecall;
  end;

implementation

end.
