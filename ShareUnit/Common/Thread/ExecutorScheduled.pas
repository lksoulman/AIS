unit ExecutorScheduled;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Scheduled Interface
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
  ExecutorService;

type

  // Executor Scheduled Interface
  IExecutorScheduled = interface(IInterface)
    ['{31F8B49C-CB4A-434C-A7EE-D03486782ADC}']
    // Start
    procedure Start; safecall;
    // Shutdown
    procedure ShutDown; safecall;
    // Is Terminated
    function IsTerminated: boolean; safecall;
    // Set Scheduled Thread
    function SetScheduledThread(ACount: Integer): Boolean; safecall;
    // Set Create Executor Function
    function SetCreateExecutorFunc(AFunc: TCreateExecutorFunc): Boolean; safecall;
    // Submit Period Task
    function SubmitTaskAtFixedPeriod(ATask: IExecutorTask; APeriod: Cardinal): boolean; safecall;
  end;

implementation

end.
