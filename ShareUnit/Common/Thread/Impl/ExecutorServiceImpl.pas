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
    // �ǲ��ǹر�
    FIsStart: Boolean;
    // �ǲ����Ѿ���ֹ
    FIsTerminated: Boolean;
    // ִ���̸߳���
    FExecutorThreadCount: Integer;
    // ���������߳�
    FMonitorThread: TExecutorThread;
    // ���д������߳�
    FWorkerThreads: TList<TExecutorThread>;
    // �ύ���������
    FSubmitTaskQueue: TSafeSemaphoreQueue<IExecutorTask>;

    // ���������߳�
    procedure DoStart; virtual;
    // �ر�
    procedure DoShutDown; virtual;
    // �����ǲ������е��̶߳���ֹ
    function DoIsTerminated: Boolean; virtual;
    // �ύ����
    function DoSubmitTask(ATask: IExecutorTask): Boolean; virtual;
    // ��ʼ����ִ���߳�
    procedure DoInitExecutorThreads; virtual;
    // �ն�ִ���߳�
    procedure DoUnInitExecutorThreads; virtual;
    // ִ���߳�
    procedure DoTaskExcute(AObject: TObject); virtual;
    // �������ִ�з���
    procedure DoTaskMonitor(AObject: TObject); virtual;
  public
    // ���캯��
    constructor Create; virtual;
    // ��������
    destructor Destroy; override;

    { IExecuterService }

    // ����
    procedure Start; safecall;
    // �ر�
    procedure ShutDown; safecall;
    // �ǲ����Ѿ�����
    function IsTerminated: boolean; safecall;
    // �ύ����
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
