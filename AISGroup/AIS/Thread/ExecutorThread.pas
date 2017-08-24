unit ExecutorThread;

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
  ExecutorTask;

type

  TExecutorMethod = procedure (AObject: TObject) of object;

  TExecutorThread = class(TThread)
  private
  protected
    // �߳� ID
    FID: Integer;
    // ����
    FName: string;
    // �ź���
    FSemaphore: THandle;
    // �߳��ǲ�������ִ��
    FIsRunning: boolean;
    // �ȴ��Ŀ�ʼʱ��
    FWaitStartTime: Cardinal;
    // �̵߳��ð󶨵Ĺ���
    FThreadMethod: TExecutorMethod;
    // �ṩЯ���Ķ���
    FObjectRef: TObject;
    // �ṩЯ���Ľӿ�
    FInterfaceRef: IInterface;

    // �߳�����ִ�з���
    procedure Execute; override;
    // �ر��߳�
    procedure DoShutDown; virtual;
    // �滻ִ�нӿ�
    procedure DoSubmitTask(ATask: IExecutorTask); virtual;
  public
    // ���췽��
    constructor Create; overload; virtual;
    // ��������
    destructor Destroy; override;
    // �����߳�
    procedure StartEx;
    // �ر��߳�
    function ShutDown: Boolean;
    // ����ʱ��
    function IdleTime: Cardinal;
    // ����
    function ResumeEx: LongBool;
    // �ȴ�
    function WaitForEx: LongWord;
    // �߳��ǲ�����ֹ
    function IsTerminated: Boolean;
    // �ύִ�нӿ�
    function SubmitTask(ATask: IExecutorTask): Boolean;

    property ID: Integer read FID;
    property Name: string read FName write FName;
    property ObjectRef: TObject read FObjectRef write FObjectRef;
    property InterfaceRef: IInterface read FInterfaceRef write FInterfaceRef;
    property ThreadMethod: TExecutorMethod read FThreadMethod write FThreadMethod;
  end;

  TExecutorThreadClass = class of TExecutorThread;

implementation

var
  // ��������
  G_Lock: TCSLock;
  // ���� ID
  G_IncrID: Integer;

  function GetIncrID: Integer;
  begin
    G_Lock.Lock;
    try
      Result := G_IncrID;
      Inc(G_IncrID);
    finally
      G_Lock.UnLock;
    end;
  end;


{ TExecutorThread }

constructor TExecutorThread.Create;
begin
  inherited Create(True);
  FID := GetIncrID;
  FIsRunning := False;
  FSemaphore := CreateSemaphore(nil, 0, 100, nil);
end;

destructor TExecutorThread.Destroy;
begin
  CloseHandle(FSemaphore);
  inherited;
end;

procedure TExecutorThread.Execute;
begin
  if Assigned(FThreadMethod) then begin
    FThreadMethod(Self);
  end;
end;

procedure TExecutorThread.StartEx;
begin
  Start;
end;

function TExecutorThread.ShutDown: Boolean;
begin
  if not Terminated then begin
    DoShutDown;
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TExecutorThread.IdleTime: Cardinal;
begin
  if FIsRunning then begin
    Result := 0;
  end else begin
    Result := GetTickCount - FWaitStartTime;
  end;
end;

function TExecutorThread.ResumeEx: LongBool;
var
  tmpCount: Integer;
begin
  Result := Windows.ReleaseSemaphore(FSemaphore, 1, @tmpCount);
end;

function TExecutorThread.WaitForEx: LongWord;
begin
  FWaitStartTime := GetTickCount;
  Result := WaitForSingleObject(FSemaphore, INFINITE);
end;

function TExecutorThread.IsTerminated: boolean;
begin
  Result := Terminated;
end;

function TExecutorThread.SubmitTask(ATask: IExecutorTask): Boolean;
begin
  DoSubmitTask(ATask);
  Result := True;
end;

procedure TExecutorThread.DoShutDown;
begin
  Terminate;
  WaitForSingleObject(Self.Handle, 100);
end;

procedure TExecutorThread.DoSubmitTask(ATask: IExecutorTask);
begin
  if IsTerminated then Exit;

  FIsRunning := True;
  try
    if ATask <> nil then begin
      ATask.Run(Self);
      ATask.CallBack;
    end;
  finally
    FIsRunning := False;
  end;
end;

initialization
  G_IncrID := 0;
  G_Lock := TCSLock.Create;

finalization
  G_Lock.Free;

end.
