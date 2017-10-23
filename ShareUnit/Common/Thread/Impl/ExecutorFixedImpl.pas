unit ExecutorFixedImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Fixed Interface implementation
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
  Messages,
  CommonQueue,
  ExecutorTask,
  ExecutorFixed,
  ExecutorThread,
  ExecutorService,
  CommonRefCounter,
  Generics.Collections;

type

  // Executor Fixed Interface implementation
  TExecutorFixedImpl = class(TAutoInterfacedObject, IExecutorFixed)
  private
    // Is Start
    FIsStart: Boolean;
    // Is Shutdown
    FIsShutDown: Boolean;
    // Is All Thread Terminated
    FIsTerminated: Boolean;
    // Work Thread Count
    FWorkerThreadCount: Integer;
    // Moniter Thread
    FMonitorThread: TExecutorThread;
    // Create Executor Function
    FCreateExecutorFunc: TCreateExecutorFunc;
    // Work Threads
    FWorkerThreads: TList<TExecutorThread>;
    // Submit Task Queue
    FSubmitTaskQueue: TSafeSemaphoreQueue<IExecutorTask>;
  protected
    // Start
    procedure DoStart;
    // Shutdown
    procedure DoShutDown;
    // Is All Thread Terminated
    function DoIsTerminated: Boolean;
    // Submit Task
    function DoSubmitTask(ATask: IExecutorTask): Boolean;
    // Create Executor
    function DoCreateExecutor: TExecutorThread;
    // Shutdown Thread
    procedure DoShutDownThread;
    // Start ACount Thread
    procedure DoStartThread(ACount: Integer);
    // Task Execute
    procedure DoTaskExecute(AObject: TObject);
    // Task Moniter
    procedure DoTaskMonitor(AObject: TObject);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IExecutorService }

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

    { IExecutorFixed }

    // Set Fixed Thread Count
    procedure SetFixedThread(ACount: Integer); safecall;
  end;

implementation

{ TExecutorFixedImpl }

constructor TExecutorFixedImpl.Create;
begin
  inherited;
  FIsStart := False;
  FIsShutDown := False;
  FWorkerThreadCount := 1;
  FMonitorThread := TExecutorThread.Create;
  FMonitorThread.ThreadMethod := DoTaskMonitor;
  FWorkerThreads := TList<TExecutorThread>.Create;
  FSubmitTaskQueue := TSafeSemaphoreQueue<IExecutorTask>.Create;
end;

destructor TExecutorFixedImpl.Destroy;
begin
  FSubmitTaskQueue.Free;
  FWorkerThreads.Free;
  inherited;
end;

procedure TExecutorFixedImpl.Start;
begin
  if not FIsStart then begin
    DoStart;
    FIsStart := True;
  end;
end;

procedure TExecutorFixedImpl.ShutDown;
begin
  if not FIsShutDown then begin
    DoShutDown;
    FIsShutDown := True;
  end;
end;

function TExecutorFixedImpl.IsTerminated: boolean;
begin
  Result := DoIsTerminated;
end;

function TExecutorFixedImpl.SubmitTask(ATask: IExecutorTask): boolean;
begin
  Result := DoSubmitTask(ATask);
end;

function TExecutorFixedImpl.SetCreateExecutorFunc(AFunc: TCreateExecutorFunc): Boolean;
begin
  if Assigned(AFunc) then begin
    FCreateExecutorFunc := AFunc;
    Result := True;
  end else begin
    FCreateExecutorFunc := nil;
  end;
end;

procedure TExecutorFixedImpl.SetFixedThread(ACount: Integer);
begin
  if not FIsStart then begin
    FWorkerThreadCount := ACount;
  end;
end;

procedure TExecutorFixedImpl.DoStart;
begin
  DoStartThread(FWorkerThreadCount);
  FMonitorThread.StartEx;
end;

procedure TExecutorFixedImpl.DoShutDown;
begin
  FMonitorThread.ShutDown;
  DoShutDownThread;
end;

function TExecutorFixedImpl.DoIsTerminated: Boolean;
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  Result := True;
  for LIndex := 0 to FWorkerThreadCount - 1 do begin
    LWorker := FWorkerThreads.Items[LIndex];
    Result := LWorker.IsTerminated and Result;
    if not Result then Exit;
  end;
  Result := FMonitorThread.IsTerminated and Result;
end;

function TExecutorFixedImpl.DoSubmitTask(ATask: IExecutorTask): Boolean;
begin
  Result := True;
  FSubmitTaskQueue.Enqueue(ATask);
  FSubmitTaskQueue.ReleaseSemaphore;
end;

procedure TExecutorFixedImpl.DoStartThread(ACount: Integer);
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  for LIndex := 0 to ACount - 1 do begin
    LWorker := DoCreateExecutor;
    if LWorker <> nil then begin
      LWorker.Name := 'Worker_' + IntToStr(LWorker.ID);
      LWorker.ThreadMethod := DoTaskExecute;
      LWorker.StartEx;
      FWorkerThreads.Add(LWorker);
    end;
  end;
end;

function TExecutorFixedImpl.DoCreateExecutor: TExecutorThread;
begin
  if Assigned(FCreateExecutorFunc) then begin
    Result := FCreateExecutorFunc;
  end else begin
    Result := TExecutorThread.Create;
  end;
end;

procedure TExecutorFixedImpl.DoShutDownThread;
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  for LIndex := 0 to FWorkerThreads.Count - 1 do begin
    LWorker := FWorkerThreads.Items[LIndex];
    LWorker.ShutDown;
  end;
  FWorkerThreads.Clear;
end;

procedure TExecutorFixedImpl.DoTaskExecute(AObject: TObject);
var
  LName: string;
  LResult: Cardinal;
  LTask: IExecutorTask;
  LWorker: TExecutorThread;
begin
  LWorker := TExecutorThread(AObject);
  while not LWorker.IsTerminated do begin
    LResult := FMonitorThread.WaitForEx;
    case LResult of
      WAIT_OBJECT_0:
        begin
          while not FSubmitTaskQueue.IsEmpty do begin
            LTask := FSubmitTaskQueue.Dequeue;
            try
              LWorker.SubmitTask(LTask);
            finally
              LTask := nil;
            end;
          end;
        end;
    end;
  end;
end;

procedure TExecutorFixedImpl.DoTaskMonitor(AObject: TObject);
var
  LResult: Cardinal;
  LThread: TExecutorThread;
begin
  LThread := TExecutorThread(AObject);
  while not LThread.IsTerminated do begin
    LResult := WaitForSingleObject(FSubmitTaskQueue.Semaphore, INFINITE);
    case LResult of
      WAIT_OBJECT_0:
        begin
          FMonitorThread.ResumeEx;
        end;
    end;
  end;
end;

end.
