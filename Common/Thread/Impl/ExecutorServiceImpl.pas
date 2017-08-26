unit ExecutorServiceImpl;

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

  TExecutorServiceImpl = class(TAutoInterfacedObject, IExecutorService)
  private
  protected
    // 是不是关闭
    FIsStart: Boolean;
    // 是不是已经终止
    FIsTerminated: Boolean;
    // 执行线程个数
    FExecutorThreadCount: Integer;
    // 管理任务线程
    FMonitorThread: TExecutorThread;
    // 所有创建的线程
    FWorkerThreads: TList<TExecutorThread>;
    // 提交的任务队列
    FSubmitTaskQueue: TSafeSemaphoreQueue<IExecutorTask>;

    // 启动所有线程
    procedure DoStart; virtual;
    // 关闭
    procedure DoShutDown; virtual;
    // 返回是不是所有的线程都终止
    function DoIsTerminated: Boolean; virtual;
    // 提交任务
    function DoSubmitTask(ATask: IExecutorTask): Boolean; virtual;
    // 初始化换执行线程
    procedure DoInitExecutorThreads; virtual;
    // 终端执行线程
    procedure DoUnInitExecutorThreads; virtual;
    // 执行线程
    procedure DoTaskExcute(AObject: TObject); virtual;
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

procedure TExecutorServiceImpl.DoStart;
begin
  DoInitExecutorThreads;
end;

procedure TExecutorServiceImpl.DoShutDown;
begin
  DoUnInitExecutorThreads;
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

procedure TExecutorServiceImpl.DoInitExecutorThreads;
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  for LIndex := 0 to FExecutorThreadCount - 1 do begin
    LWorker := TExecutorThread.Create;
    LWorker.Name := 'Worker_' + IntToStr(LIndex);
    LWorker.ThreadMethod := DoTaskExcute;
    LWorker.StartEx;
    FWorkerThreads.Add(LWorker);
  end;
  FMonitorThread.StartEx;
end;

procedure TExecutorServiceImpl.DoUnInitExecutorThreads;
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

procedure TExecutorServiceImpl.DoTaskExcute(AObject: TObject);
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
