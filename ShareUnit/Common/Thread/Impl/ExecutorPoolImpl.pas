unit ExecutorPoolImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-5-1
// Comments��    {Doug Lea thread}
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
  CommonRefCounter,
  Generics.Collections;

type

  // �Զ��仯ִ���̸߳������̳߳�
  TExecutorPoolImpl = class(TAutoInterfacedObject, IExecutorPool)
  private
    // ��ȫ��
    FLock: TCSLock;
    // �ǲ�������
    FIsStart: Boolean;
    // �ǲ��ǹر�
    FIsShutDown: Boolean;
    // ������С�̸߳���
    FMinPoolSize: Integer;
    // ��������̸߳���
    FMaxPoolSize: Integer;
    // ������ʱ��
    FMaxIdleTime: Integer;
    // �ǲ����Ѿ���ֹ
    FIsTerminated: Boolean;
    // �����̸߳���
    FWorkerThreadCount: Integer;
    // ���������߳�
    FMonitorThread: TExecutorThread;
    // �ύ���������
    FSubmitTaskQueue: TSafeSemaphoreQueue<IExecutorTask>;
    // ���д������߳�
    FWorkerThreadDic: TDictionary<Integer, TExecutorThread>;
  protected
    // ���������߳�
    procedure DoStart;
    // �ر�
    procedure DoShutDown;
    // �����ǲ������е��̶߳���ֹ
    function DoIsTerminated: Boolean;
    // �ύ����
    function DoSubmitTask(ATask: IExecutorTask): Boolean;
    // ���δ��ɵ�����
    procedure DoClearTaskQueue;
    // ��ֹ���е��߳�
    procedure DoShutDownThread;
    // ���� ACount ���߳�
    procedure DoStartThread(ACount: Integer);
    // ��ֹ�����߳�
    procedure DoTerminatedIdleThread(AThread: TExecutorThread);
    // �������̸߳���ֱ�����
    procedure DoAddUtilMaxSizeThread(AThread: TExecutorThread);
    // ִ���߳�
    procedure DoTaskExecute(AObject: TObject);
    // �������ִ�з���
    procedure DoTaskMonitor(AObject: TObject);
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

    { IExecutorPool }

    // ���ó����߳������С�̸߳���
    procedure SetPoolThread(AMaxPoolSize, AMinPoolSize: Integer); safecall;
  end;

implementation

uses
  FastLogLevel,
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
