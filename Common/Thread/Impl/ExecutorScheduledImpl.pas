unit ExecutorScheduledImpl;

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
      // ��ʱ�洢�ṹ
      PScheduledRecord = ^TScheduledRecord;
      TScheduledRecord = record
        FIsLock: Boolean;
        FPeriod: Cardinal;
        FExecuteTime: Cardinal;
        FExecutorTask: IExecutorTask;
      end;
  private
    // �̰߳�ȫ��
    FLock: TCSLock;
    // �ǲ�������
    FIsStart: Boolean;
    // �ǲ��ǹر�
    FIsShutDown: Boolean;
    // �ǲ����Ѿ���ֹ
    FIsTerminated: Boolean;
    // ��С�ĵȴ���ʱ��Ƭ
    FMinWaitPeriod: Cardinal;
    // �����̸߳���
    FWorkerThreadCount: Integer;
    // ���д������߳�
    FWorkerThreads: TList<TExecutorThread>;
    // ��ʱ�ύִ������
    FScheduledTaskQueue: TSafeSemaphoreCircularQueue;
  protected
    // ���������߳�
    procedure DoStart; virtual;
    // �ر�
    procedure DoShutDown; virtual;
    // �����ǲ������е��̶߳���ֹ
    function DoIsTerminated: Boolean;
    // �������
    procedure DoClearTaskQueue;
    // ��ֹ���е��߳�
    procedure DoShutDownThread;
    // ���� ACount ���߳�
    procedure DoStartThread(ACount: Integer);
    // ִ���߳�
    procedure DoTaskExecute(AObject: TObject);
    // ��ȡ��һ�� ScheduledRecord
    function DoGetNextScheduledRecord: PScheduledRecord;
    // ���� ScheduledRecord ״̬
    procedure DoSetScheduledRecordState(AScheduledRecord: PScheduledRecord);
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { IExecutorScheduled }

    // ����
    procedure Start; safecall;
    // �ر�
    procedure ShutDown; safecall;
    // �ǲ����Ѿ�����
    function IsTerminated: boolean; safecall;
    // �����̸߳���
    procedure SetScheduledThread(ACount: Integer); safecall;
    // �̶�������ִ��
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
            // �ó�CPU
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
