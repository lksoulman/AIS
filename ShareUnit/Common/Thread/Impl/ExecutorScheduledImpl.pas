unit ExecutorScheduledImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-5-1
// Comments：    {Doug Lea thread}
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
  CommonRefCounter,
  ExecutorScheduled,
  Generics.Collections;

type

  TExecutorScheduledImpl = class(TAutoInterfacedObject, IExecutorScheduled)
  private
    type
      // 定时存储结构
      PScheduledRecord = ^TScheduledRecord;
      TScheduledRecord = record
        FIsLock: Boolean;
        FPeriod: Cardinal;
        FExecuteTime: Cardinal;
        FExecutorTask: IExecutorTask;
      end;
  private
    // 线程安全锁
    FLock: TCSLock;
    // 是不是启动
    FIsStart: Boolean;
    // 是不是关闭
    FIsShutDown: Boolean;
    // 是不是已经终止
    FIsTerminated: Boolean;
    // 最小的等待的时间片
    FMinWaitPeriod: Cardinal;
    // 工作线程个数
    FWorkerThreadCount: Integer;
    // 所有创建的线程
    FWorkerThreads: TList<TExecutorThread>;
    // 定时提交执行任务
    FScheduledTaskQueue: TSafeSemaphoreCircularQueue;
  protected
    // 启动所有线程
    procedure DoStart; virtual;
    // 关闭
    procedure DoShutDown; virtual;
    // 返回是不是所有的线程都终止
    function DoIsTerminated: Boolean;
    // 清空任务
    procedure DoClearTaskQueue;
    // 终止所有的线程
    procedure DoShutDownThread;
    // 启动 ACount 个线程
    procedure DoStartThread(ACount: Integer);
    // 执行线程
    procedure DoTaskExecute(AObject: TObject);
    // 获取下一个 ScheduledRecord
    function DoGetNextScheduledRecord: PScheduledRecord;
    // 设置 ScheduledRecord 状态
    procedure DoSetScheduledRecordState(AScheduledRecord: PScheduledRecord);
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IExecutorScheduled }

    // 启动
    procedure Start; safecall;
    // 关闭
    procedure ShutDown; safecall;
    // 是不是已经结束
    function IsTerminated: boolean; safecall;
    // 设置线程个数
    procedure SetScheduledThread(ACount: Integer); safecall;
    // 固定的周期执行
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

procedure TExecutorScheduledImpl.SetScheduledThread(ACount: Integer);
begin
  if not FIsStart then begin
    FWorkerThreadCount := ACount;
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
    LWorker := TExecutorThread.Create;
    LWorker.Name := 'Worker_' + IntToStr(LWorker.ID);
    LWorker.ThreadMethod := DoTaskExecute;
    LWorker.StartEx;
    FWorkerThreads.Add(LWorker);
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
            // 让出CPU
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
