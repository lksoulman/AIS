unit ExecutorThread;

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
  CommonLock,
  ExecutorTask;

type

  TExecutorMethod = procedure (AObject: TObject) of object;

  TExecutorThread = class(TThread)
  private
  protected
    // 线程 ID
    FID: Integer;
    // 名称
    FName: string;
    // 信号量
    FSemaphore: THandle;
    // 线程是不是正在执行
    FIsRunning: boolean;
    // 等待的开始时间
    FWaitStartTime: Cardinal;
    // 线程调用绑定的过程
    FThreadMethod: TExecutorMethod;
    // 提供携带的对象
    FObjectRef: TObject;
    // 提供携带的接口
    FInterfaceRef: IInterface;

    // 线程启动执行方法
    procedure Execute; override;
    // 关闭线程
    procedure DoShutDown; virtual;
    // 替换执行接口
    procedure DoSubmitTask(ATask: IExecutorTask); virtual;
  public
    // 构造方法
    constructor Create; overload; virtual;
    // 析构方法
    destructor Destroy; override;
    // 启动线程
    procedure StartEx;
    // 关闭线程
    function ShutDown: Boolean;
    // 空闲时间
    function IdleTime: Cardinal;
    // 启动
    function ResumeEx: LongBool;
    // 等待
    function WaitForEx: LongWord;
    // 线程是不是终止
    function IsTerminated: Boolean;
    // 提交执行接口
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
  // 自增所有
  G_Lock: TCSLock;
  // 自增 ID
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
