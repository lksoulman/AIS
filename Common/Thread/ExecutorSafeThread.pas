unit ExecutorSafeThread;

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  ExecutorThread;

type

  TExecutorSafeThread = class(TExecutorThread)
  private
  protected
    // 安全锁
    FLock: TCSLock;
    // 线程是不是正在执行
    FIsRunning: boolean;
    // 等待的结束时间
    FWaitEndTime: TDateTime;
    // 等待的开始时间
    FWaitStartTime: TDateTime;
  public
    // 构造方法
    constructor Create; override;
    // 析构方法
    destructor Destroy; override;

    // 加锁
    procedure Lock;
    // 解锁
    procedure UnLock;
    // 获取是不是正在运行
    function GetIsRunning: Boolean;
    // 设置运行状态
    procedure SetIsRunning(AIsRunning: Boolean);
  end;

implementation

{ TExecutorSafeThread }

constructor TExecutorSafeThread.Create;
begin
  inherited;
  FLock := TCSLock.Create;
end;

destructor TExecutorSafeThread.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TExecutorSafeThread.Lock;
begin
  FLock.Lock;
end;

procedure TExecutorSafeThread.UnLock;
begin
  FLock.UnLock;
end;

function TExecutorSafeThread.GetIsRunning: Boolean;
begin
  Result := FIsRunning;
end;

procedure TExecutorSafeThread.SetIsRunning(AIsRunning: Boolean);
begin
  FIsRunning := AIsRunning;
end;

end.
