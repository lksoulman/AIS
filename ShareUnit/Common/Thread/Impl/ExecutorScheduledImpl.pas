unit ExecutorScheduledImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Scheduled Interface implementation
// Author£º      lksoulman
// Date£º        2017-5-1
// Comments£º    {Doug Lea thread}
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Forms,
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  CommonQueue,
  ExecutorTask,
  ExecutorThread,
  ExecutorService,
  CommonRefCounter,
  ExecutorScheduled,
  Generics.Collections;

type

  // Executor Scheduled Interface implementation
  TExecutorScheduledImpl = class(TAutoInterfacedObject, IExecutorScheduled)
  private
    type
      // Scheduled Record
      PScheduledRecord = ^TScheduledRecord;
      TScheduledRecord = record
        FIsLock: Boolean;
        FPeriod: Cardinal;
        FExecuteTime: Cardinal;
        FExecutorTask: IExecutorTask;
      end;
  private
    // Lock
    FLock: TCSLock;
    // Is Start
    FIsStart: Boolean;
    // Is Shutdown
    FIsShutDown: Boolean;
    // Is Terminated
    FIsTerminated: Boolean;
    // Min Wait Period
    FMinWaitPeriod: Cardinal;
    // Worker Thread Count
    FWorkerThreadCount: Integer;
    // Create Executor Function
    FCreateExecutorFunc: TCreateExecutorFunc;
    // Worker Threads
    FWorkerThreads: TList<TExecutorThread>;
    // Task Queue
    FScheduledTaskQueue: TSafeSemaphoreCircularQueue;
  protected
    // Start
    procedure DoStart;
    // Shutdown
    procedure DoShutDown;
    // Is All Thread Terminated
    function DoIsTerminated: Boolean;
    // Clear Task
    procedure DoClearTaskQueue;
    // Shutdown Thread
    procedure DoShutDownThread;
    // Start ACount Thread
    procedure DoStartThread(ACount: Integer);
    // Create Executor
    function DoCreateExecutor: TExecutorThread;
    // Execute Task
    procedure DoTaskExecute(AObject: TObject);
    // Get Next ScheduledRecord
    function DoGetNextScheduledRecord: PScheduledRecord;
    // Set ScheduledRecord State
    procedure DoSetScheduledRecordState(AScheduledRecord: PScheduledRecord);
  public
    // Constructor
    constructor Create;
    // Destructor
    destructor Destroy; override;

    { IExecutorScheduled }

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

{ TExecutorScheduledImpl }

constructor TExecutorScheduledImpl.Create;
begin
  inherited Create;
  FIsStart := False;
  FIsShutDown := False;
  FWorkerThreadCount := 1;
  FLock := TCSLock.Create;
  FWorkerThreads := TList<TExecutorThread>.Create;
  FScheduledTaskQueue := TSafeSemaphoreCircularQueue.Create(10);
end;

destructor TExecutorScheduledImpl.Destroy;
begin
  FScheduledTaskQueue.Free;
  FWorkerThreads.Free;
  FLock.Free;
  inherited;
end;

procedure TExecutorScheduledImpl.Start;
begin
  if not FIsStart then begin
    DoStart;
    FIsStart := True;
  end;
end;

procedure TExecutorScheduledImpl.ShutDown;
begin
  if not FIsShutDown then begin
    DoShutDown;
    FIsShutDown := True;
  end;
end;

function TExecutorScheduledImpl.IsTerminated: boolean;
begin
  Result := DoIsTerminated;
end;

function TExecutorScheduledImpl.SetScheduledThread(ACount: Integer): Boolean;
begin
  if not FIsStart then begin
    FWorkerThreadCount := ACount;
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TExecutorScheduledImpl.SetCreateExecutorFunc(AFunc: TCreateExecutorFunc): Boolean;
begin
  if Assigned(AFunc) then begin
    FCreateExecutorFunc := AFunc;
    Result := True;
  end else begin
    FCreateExecutorFunc := nil;
  end;
end;

function TExecutorScheduledImpl.SubmitTaskAtFixedPeriod(ATask: IExecutorTask; APeriod: Cardinal): boolean;
var
  LScheduledRecord: PScheduledRecord;
begin
  if ATask = nil then Exit;
  
  New(LScheduledRecord);
  if LScheduledRecord <> nil then begin
    if APeriod < FMinWaitPeriod then begin
      FMinWaitPeriod := APeriod Div 2;
    end;
    LScheduledRecord^.FIsLock := False;
    LScheduledRecord^.FPeriod := APeriod;
    LScheduledRecord^.FExecuteTime := GetTickCount;
    LScheduledRecord^.FExecutorTask := ATask;
    FScheduledTaskQueue.AddAtElementIndex(LScheduledRecord);
    FScheduledTaskQueue.ReleaseSemaphore;
  end;
end;

procedure TExecutorScheduledImpl.DoStart;
begin
  DoStartThread(FWorkerThreadCount);
end;

procedure TExecutorScheduledImpl.DoShutDown;
begin
  DoShutDownThread;
end;

function TExecutorScheduledImpl.DoIsTerminated: Boolean;
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
end;

procedure TExecutorScheduledImpl.DoStartThread(ACount: Integer);
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

function TExecutorScheduledImpl.DoCreateExecutor: TExecutorThread;
begin
  if Assigned(FCreateExecutorFunc) then begin
    Result := FCreateExecutorFunc;
  end else begin
    Result := TExecutorThread.Create;
  end;
end;

procedure TExecutorScheduledImpl.DoClearTaskQueue;
var
  LScheduledRecord: PScheduledRecord;
begin
  FScheduledTaskQueue.First;
  while not FScheduledTaskQueue.IsEOF do begin
    LScheduledRecord := FScheduledTaskQueue.GetCurrentElement;
    if LScheduledRecord <> nil then begin
      LScheduledRecord^.FExecutorTask := nil;
      Dispose(LScheduledRecord);
    end;
    FScheduledTaskQueue.Next;
  end;
end;

procedure TExecutorScheduledImpl.DoShutDownThread;
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

procedure TExecutorScheduledImpl.DoTaskExecute(AObject: TObject);
var
  LName: string;
  LResult: Cardinal;
  LTask: IExecutorTask;
  LWorker: TExecutorThread;
  LScheduledRecord: PScheduledRecord;
begin
  LWorker := TExecutorThread(AObject);
  while not LWorker.IsTerminated do begin
    LResult := WaitForSingleObject(FScheduledTaskQueue.Semaphore, FMinWaitPeriod);
    case LResult of
      WAIT_OBJECT_0:
        begin
          LScheduledRecord := DoGetNextScheduledRecord;
          if LScheduledRecord <> nil then begin
            LWorker.SubmitTask(LScheduledRecord^.FExecutorTask);
            LScheduledRecord^.FExecuteTime := GetTickCount;
          end else begin
            // ÈÃ³öCPU
            Application.ProcessMessages;
          end;
        end;
    end;
  end;
end;

function TExecutorScheduledImpl.DoGetNextScheduledRecord: PScheduledRecord;
var
  LPeriod: Cardinal;
begin
  FLock.Lock;
  try
    Result := PScheduledRecord(FScheduledTaskQueue.GetNextElement);
    if Result = nil then Exit;
    LPeriod := GetTickCount - Result.FExecuteTime;
    if (not Result.FIsLock) and (LPeriod > Result.FPeriod) then begin
      Result.FIsLock := True;
    end else begin
      Result := nil;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TExecutorScheduledImpl.DoSetScheduledRecordState(AScheduledRecord: PScheduledRecord);
begin
  FLock.Lock;
  try
    if AScheduledRecord <> nil then begin
      AScheduledRecord.FIsLock := False;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
