unit ExecutorFixedImpl;

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
  Windows,
  Classes,
  SysUtils,
  Messages,
  CommonQueue,
  ExecutorTask,
  ExecutorFixed,
  ExecutorThread,
  CommonRefCounter,
  Generics.Collections;

type

  TExecutorFixedImpl = class(TAutoInterfacedObject, IExecutorFixed)
  private
    // 是不是启动
    FIsStart: Boolean;
    // 是不是关闭
    FIsShutDown: Boolean;
    // 是不是已经终止
    FIsTerminated: Boolean;
    // 工作线程个数
    FWorkerThreadCount: Integer;
    // 管理任务线程
    FMonitorThread: TExecutorThread;
    // 所有创建的线程
    FWorkerThreads: TList<TExecutorThread>;
    // 提交的任务队列
    FSubmitTaskQueue: TSafeSemaphoreQueue<IExecutorTask>;
  protected
    // 启动所有线程
    procedure DoStart; virtual;
    // 关闭
    procedure DoShutDown; virtual;
    // 返回是不是所有的线程都终止
    function DoIsTerminated: Boolean; virtual;
    // 提交任务
    function DoSubmitTask(ATask: IExecutorTask): Boolean; virtual;
    // 终止所有的线程
    procedure DoShutDownThread;
    // 启动 ACount 个线程
    procedure DoStartThread(ACount: Integer);
    // 执行线程
    procedure DoTaskExecute(AObject: TObject); virtual;
    // 监控任务执行方法
    procedure DoTaskMonitor(AObject: TObject); virtual;
  public
    // 构造函数
    constructor Create; virtual;
    // 析构函数
    destructor Destroy; override;

    { IExecuterService }

    // 启动
    procedure Start; safecall;
    // 关闭
    procedure ShutDown; safecall;
    // 是不是已经结束
    function IsTerminated: boolean; safecall;
    // 提交任务
    function SubmitTask(ATask: IExecutorTask): Boolean; safecall;

    { IExecutorFixed }

    // 设置启动线程的个数
    procedure SetFixedThread(ACount: Integer); safecall;
  end;

implementation

{ TExecutorFixedImpl }

constructor TExecutorFixedImpl.Create;
begin
  inherited Create;
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
    LWorker := TExecutorThread.Create;
    LWorker.Name := 'Worker_' + IntToStr(LWorker.ID);
    LWorker.ThreadMethod := DoTaskExecute;
    LWorker.StartEx;
    FWorkerThreads.Add(LWorker);
  end;
  FMonitorThread.StartEx;
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
