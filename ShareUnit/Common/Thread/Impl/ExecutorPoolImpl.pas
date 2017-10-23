unit ExecutorPoolImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Pool Interface implementation
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
  CommonLock,
  CommonQueue,
  ExecutorTask,
  ExecutorPool,
  ExecutorThread,
  ExecutorService,
  CommonRefCounter,
  Generics.Collections;

type

  // Executor Pool Interface implementation
  TExecutorPoolImpl = class(TAutoInterfacedObject, IExecutorPool)
  private
    // Lock
    FLock: TCSLock;
    // Is Start
    FIsStart: Boolean;
    // Is Shutdown
    FIsShutDown: Boolean;
    // Min Pool Size
    FMinPoolSize: Integer;
    // Max Pool Size
    FMaxPoolSize: Integer;
    // Max Idle Time
    FMaxIdleTime: Integer;
    // Is All Executor Terminated
    FIsTerminated: Boolean;
    // Work Thread Count
    FWorkerThreadCount: Integer;
    // Monitor Thread
    FMonitorThread: TExecutorThread;
    // Create Executor Function
    FCreateExecutorFunc: TCreateExecutorFunc;
    // Submit Task Queue
    FSubmitTaskQueue: TSafeSemaphoreQueue<IExecutorTask>;
    // Work Thread Dictionary
    FWorkerThreadDic: TDictionary<Integer, TExecutorThread>;
  protected
    // Start
    procedure DoStart;
    // Shutdown
    procedure DoShutDown;
    // Is All Thread Terminated
    function DoIsTerminated: Boolean;
    // Submit Task
    function DoSubmitTask(ATask: IExecutorTask): Boolean;
    // Clear Task Queue
    procedure DoClearTaskQueue;
    // ShutDown Thread
    procedure DoShutDownThread;
    // Start ACount Thread
    procedure DoStartThread(ACount: Integer);
    // Create Executor
    function DoCreateExecutor: TExecutorThread;
    // Terminated Idle Thread
    procedure DoTerminatedIdleThread(AThread: TExecutorThread);
    // Add Util Max Size Thread
    procedure DoAddUtilMaxSizeThread(AThread: TExecutorThread);
    // Execute Task
    procedure DoTaskExecute(AObject: TObject);
    // Monitor Task
    procedure DoTaskMonitor(AObject: TObject);
  public
    // Constructor
    constructor Create; virtual;
    // Destructor
    destructor Destroy; override;

    { IExecuterService }

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

    { IExecutorPool }

    // Set Pool Max and Min Size
    procedure SetPoolThread(AMaxPoolSize, AMinPoolSize: Integer); safecall;
  end;

implementation

uses
  FastLogLevel,
  AsfSdkExport,
  CommonObject;

{ TExecutorPoolImpl }

constructor TExecutorPoolImpl.Create;
begin
  inherited Create;
  FIsStart := False;
  FIsShutDown := False;
  FMinPoolSize := 1;
  FMaxPoolSize := 1;
  FMaxIdleTime := 1 * 60 * 1000;
  FWorkerThreadCount := 1;
  FLock := TCSLock.Create;
  FMonitorThread := TExecutorThread.Create;
  FMonitorThread.ThreadMethod := DoTaskMonitor;
  FSubmitTaskQueue := TSafeSemaphoreQueue<IExecutorTask>.Create;
  FWorkerThreadDic := TDictionary<Integer, TExecutorThread>.Create(10);
end;

destructor TExecutorPoolImpl.Destroy;
begin
  FSubmitTaskQueue.Free;
  FWorkerThreadDic.Free;
  FLock.Free;
  inherited;
end;

procedure TExecutorPoolImpl.Start;
begin
  if not FIsStart then begin
    DoStart;
    FIsStart := True;
  end;
end;

procedure TExecutorPoolImpl.ShutDown;
begin
  if not FIsShutDown then begin
    DoShutDown;
    FIsShutDown := True;
  end;
end;

function TExecutorPoolImpl.IsTerminated: boolean;
begin
  Result := DoIsTerminated;
end;

function TExecutorPoolImpl.SubmitTask(ATask: IExecutorTask): boolean;
begin
  Result := DoSubmitTask(ATask);
end;

function TExecutorPoolImpl.SetCreateExecutorFunc(AFunc: TCreateExecutorFunc): Boolean;
begin
  if Assigned(AFunc) then begin
    FCreateExecutorFunc := AFunc;
    Result := True;
  end else begin
    FCreateExecutorFunc := nil;
  end;
end;

procedure TExecutorPoolImpl.SetPoolThread(AMaxPoolSize, AMinPoolSize: Integer);
var
  LMinPoolSize, LMaxPoolSize: Integer;
begin
  if (AMaxPoolSize <= 0) or (AMinPoolSize <= 0) then Exit;

  if AMinPoolSize >= AMaxPoolSize then begin
    LMinPoolSize := AMinPoolSize;
    LMaxPoolSize := LMinPoolSize;
  end else begin
    LMinPoolSize := AMinPoolSize;
    LMaxPoolSize := AMaxPoolSize;
  end;

  if not FIsStart then begin
    FMinPoolSize := LMinPoolSize;
    FMaxPoolSize := LMaxPoolSize;
    FWorkerThreadCount := FMinPoolSize;
  end else begin
    FMinPoolSize := LMinPoolSize;
    FMaxPoolSize := LMaxPoolSize;
  end;
end;

procedure TExecutorPoolImpl.DoStart;
begin
  DoStartThread(FWorkerThreadCount);
  FMonitorThread.StartEx;
end;

procedure TExecutorPoolImpl.DoShutDown;
begin
  FMonitorThread.ShutDown;
  DoShutDownThread;
end;

function TExecutorPoolImpl.DoIsTerminated: Boolean;
var
  LWorker: TExecutorThread;
  LEnum: TDictionary<Integer, TExecutorThread>.TPairEnumerator;
begin
  Result := True;
  LEnum := FWorkerThreadDic.GetEnumerator;
  while LEnum.MoveNext do begin
    if LEnum.Current.Value <> nil then begin
      Result := LEnum.Current.Value.IsTerminated and Result;
      if not Result then Exit;
    end;
  end;
  Result := FMonitorThread.IsTerminated and Result;
end;

function TExecutorPoolImpl.DoSubmitTask(ATask: IExecutorTask): Boolean;
begin
  Result := True;
  FSubmitTaskQueue.Enqueue(ATask);
  FSubmitTaskQueue.ReleaseSemaphore;
end;

procedure TExecutorPoolImpl.DoClearTaskQueue;
begin

end;

procedure TExecutorPoolImpl.DoStartThread(ACount: Integer);
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  for LIndex := 0 to ACount - 1 do begin
    LWorker := DoCreateExecutor;
    if LWorker <> nil then begin
      LWorker.Name := 'Worker_' + IntToStr(LWorker.ID);
      if not FWorkerThreadDic.ContainsKey(LWorker.ID) then begin
        FWorkerThreadDic.AddOrSetValue(LWorker.ID, LWorker);
        LWorker.ThreadMethod := DoTaskExecute;
        LWorker.StartEx;
      end else begin
        FastSysLog(llERROR, Format('[TExecutorPoolImpl.DoStartThread] LWorker.ID = %d  is Repeat in FWorkerThreadDic', [LWorker.ID]));
        LWorker.Free;
      end;
    end;
  end;
end;

function TExecutorPoolImpl.DoCreateExecutor: TExecutorThread;
begin
  if Assigned(FCreateExecutorFunc) then begin
    Result := FCreateExecutorFunc;
  end else begin
    Result := TExecutorThread.Create;
  end;
end;

procedure TExecutorPoolImpl.DoShutDownThread;
var
  LWorker: TExecutorThread;
  LEnum: TDictionary<Integer, TExecutorThread>.TPairEnumerator;
begin
  LEnum := FWorkerThreadDic.GetEnumerator;
  while LEnum.MoveNext do begin
    if LEnum.Current.Value <> nil then begin
      LEnum.Current.Value.ShutDown;
    end;
  end;
  FWorkerThreadDic.Clear;
end;

procedure TExecutorPoolImpl.DoTerminatedIdleThread(AThread: TExecutorThread);
var
  LCount, LIndex: Integer;
  LThreads: Array of TExecutorThread;
  LEnum: TDictionary<Integer, TExecutorThread>.TPairEnumerator;
begin
  LEnum := FWorkerThreadDic.GetEnumerator;
  if FWorkerThreadCount <= FMinPoolSize then Exit;

  FLock.Lock;
  try
    LCount := 0;
    SetLength(LThreads, FMaxPoolSize);
    LEnum := FWorkerThreadDic.GetEnumerator;
    while LEnum.MoveNext do begin
      if AThread.IsTerminated then Exit;

      if (LEnum.Current.Value <> nil)
        and (LEnum.Current.Value.IdleTime > FMaxIdleTime) then begin
        LEnum.Current.Value.ShutDown;
        LThreads[LCount] := LEnum.Current.Value;
        Inc(LCount);
      end;
    end;

    for LIndex := 0 to LCount - 1 do begin
      if AThread.IsTerminated then Exit;

      FWorkerThreadDic.Remove(LThreads[LCount].ID);
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TExecutorPoolImpl.DoAddUtilMaxSizeThread(AThread: TExecutorThread);
var
  LCount, LIndex: Integer;
  LWorker: TExecutorThread;
begin
  if FWorkerThreadCount >= FMaxPoolSize then Exit;

  FLock.Lock;
  try
    LCount := FMaxPoolSize - FWorkerThreadCount;
    for LIndex := 0 to LCount - 1 do begin
      if AThread.IsTerminated then Exit;

      LWorker := TExecutorThread.Create;
      LWorker.Name := 'Worker_' + IntToStr(LWorker.ID);
      if not FWorkerThreadDic.ContainsKey(LWorker.ID) then begin
        FWorkerThreadDic.AddOrSetValue(LWorker.ID, LWorker);
        LWorker.ThreadMethod := DoTaskExecute;
        LWorker.StartEx;
      end else begin
        FastAppLog(llERROR, Format('[TExecutorPoolImpl.DoStartThread] LWorker.ID = %d  is Repeat in FWorkerThreadDic', [LWorker.ID]));
        LWorker.Free;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TExecutorPoolImpl.DoTaskExecute(AObject: TObject);
var
  LName: string;
  LTask: IExecutorTask;
  LResult: Cardinal;
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
              LTask.Run(LWorker);
              LTask.CallBack;
            finally
              LTask := nil;
            end;
          end;
        end;
    end;
  end;
end;

procedure TExecutorPoolImpl.DoTaskMonitor(AObject: TObject);
var
  LResult: Cardinal;
  LThread: TExecutorThread;
begin
  LThread := TExecutorThread(AObject);
  while not LThread.IsTerminated do begin
    LResult := WaitForSingleObject(FSubmitTaskQueue.Semaphore, 60000);
    case LResult of
      WAIT_OBJECT_0:
        begin
          DoAddUtilMaxSizeThread(LThread);
          FMonitorThread.ResumeEx;
        end;
      WAIT_TIMEOUT:
        begin
          DoTerminatedIdleThread(LThread);
        end;
    end;
  end;
end;

end.
