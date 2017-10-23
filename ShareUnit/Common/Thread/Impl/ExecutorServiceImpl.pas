unit ExecutorServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Service Interface implementation
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
  ExecutorThread,
  ExecutorService,
  CommonRefCounter,
  Generics.Collections;

type

  // Executor Service Interface implementation
  TExecutorServiceImpl = class(TAutoInterfacedObject, IExecutorService)
  private
  protected
    // Is Start
    FIsStart: Boolean;
    // Is Terminated
    FIsTerminated: Boolean;
    // Thread Count
    FExecutorThreadCount: Integer;
    // Monitor Thread
    FMonitorThread: TExecutorThread;
    // Create Executor Function
    FCreateExecutorFunc: TCreateExecutorFunc;
    // Work Thread
    FWorkerThreads: TList<TExecutorThread>;
    // Submit Task Queue
    FSubmitTaskQueue: TSafeSemaphoreQueue<IExecutorTask>;

    // Start Service
    procedure DoStart;
    // Shutdown
    procedure DoShutDown;
    // Is all Thread Terminated
    function DoIsTerminated: Boolean;
    // Submit Task
    function DoSubmitTask(ATask: IExecutorTask): Boolean;
    // Shutdown Thread
    procedure DoShutDownThread;
    // Start ACount Thread
    procedure DoStartThread(ACount: Integer);
    // Create Executor
    function DoCreateExecutor: TExecutorThread;
    // Execute Task
    procedure DoTaskExecute(AObject: TObject);
    // Monitor Task
    procedure DoTaskMonitor(AObject: TObject);
  public
    // Constructor
    constructor Create; virtual;
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
  end;

implementation

{ TExecutorServiceImpl }

constructor TExecutorServiceImpl.Create;
begin
  inherited Create;
  FExecutorThreadCount := 1;
  FMonitorThread := TExecutorThread.Create;
  FMonitorThread.ThreadMethod := DoTaskMonitor;
  FWorkerThreads := TList<TExecutorThread>.Create;
  FSubmitTaskQueue := TSafeSemaphoreQueue<IExecutorTask>.Create;
end;

destructor TExecutorServiceImpl.Destroy;
begin
  FSubmitTaskQueue.Free;
  FWorkerThreads.Free;
  inherited;
end;

procedure TExecutorServiceImpl.Start;
begin
  if not FIsStart then begin
    DoStart;
    FIsStart := True;
  end;
end;

procedure TExecutorServiceImpl.ShutDown;
begin
  if FIsStart then begin
    DoShutDown;
  end;
end;

function TExecutorServiceImpl.IsTerminated: boolean;
begin
  Result := DoIsTerminated;
end;

function TExecutorServiceImpl.SubmitTask(ATask: IExecutorTask): boolean;
begin
  Result := DoSubmitTask(ATask);
end;

function TExecutorServiceImpl.SetCreateExecutorFunc(AFunc: TCreateExecutorFunc): Boolean;
begin
  if Assigned(AFunc) then begin
    FCreateExecutorFunc := AFunc;
    Result := True;
  end else begin
    FCreateExecutorFunc := nil;
  end;
end;

procedure TExecutorServiceImpl.DoStart;
begin
  DoStartThread(FExecutorThreadCount);
  FMonitorThread.StartEx;
end;

procedure TExecutorServiceImpl.DoShutDown;
begin
  FMonitorThread.ShutDown;
  DoShutDownThread;
end;

function TExecutorServiceImpl.DoIsTerminated: Boolean;
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  Result := True;
  for LIndex := 0 to FExecutorThreadCount - 1 do begin
    LWorker := FWorkerThreads.Items[LIndex];
    Result := LWorker.IsTerminated and Result;
    if not Result then Exit;
  end;
  Result := FMonitorThread.IsTerminated and Result;
end;

function TExecutorServiceImpl.DoSubmitTask(ATask: IExecutorTask): Boolean;
begin
  Result := True;
  FSubmitTaskQueue.Enqueue(ATask);
  FSubmitTaskQueue.ReleaseSemaphore;
end;

procedure TExecutorServiceImpl.DoShutDownThread;
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  FMonitorThread.ShutDown;
  for LIndex := 0 to FWorkerThreads.Count - 1 do begin
    LWorker := FWorkerThreads.Items[LIndex];
    LWorker.ShutDown;
  end;
  FWorkerThreads.Clear;
end;

procedure TExecutorServiceImpl.DoStartThread(ACount: Integer);
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  for LIndex := 0 to ACount - 1 do begin
    LWorker := DoCreateExecutor;
    if LWorker <> nil then begin
      LWorker.Name := 'Worker_' + IntToStr(LIndex);
      LWorker.ThreadMethod := DoTaskExecute;
      LWorker.StartEx;
      FWorkerThreads.Add(LWorker);
    end;
  end;
end;

function TExecutorServiceImpl.DoCreateExecutor: TExecutorThread;
begin
  if Assigned(FCreateExecutorFunc) then begin
    Result := FCreateExecutorFunc;
  end else begin
    Result := TExecutorThread.Create;
  end;
end;

procedure TExecutorServiceImpl.DoTaskExecute(AObject: TObject);
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

procedure TExecutorServiceImpl.DoTaskMonitor(AObject: TObject);
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
