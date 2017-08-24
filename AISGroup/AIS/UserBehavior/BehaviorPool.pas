unit BehaviorPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Behavior,
  CommonLock,
  Generics.Collections;

type

  // 行为对象池
  TBehaviorPool = class
  private
    // 线程锁
    FLock: TCSLock;
    // 池子大小
    FPoolSize: Integer;
    // 行为对象队列
    FBehaviorQueue: TQueue<TBehavior>;
  protected
    // 清空和释放队列中对象
    procedure DoClearQueue;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 分配一个行为对象
    function Allocate: TBehavior;
    // 回收一个行为对象
    procedure DeAllocate(ABehavior: TBehavior);
  end;

implementation

{ TBehaviorPool }

constructor TBehaviorPool.Create;
begin
  inherited;
  FPoolSize := 10;
  FLock := TCSLock.Create;
  FBehaviorQueue := TQueue<TBehavior>.Create;
end;

destructor TBehaviorPool.Destroy;
begin
  DoClearQueue;
  FBehaviorQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TBehaviorPool.DoClearQueue;
var
  LBehavior: TBehavior;
begin
  while self.FBehaviorQueue.Count > 0 do begin
    LBehavior := FBehaviorQueue.Dequeue;
    if LBehavior <> nil then begin
      LBehavior.Free;
    end;
  end;
end;

function TBehaviorPool.Allocate: TBehavior;
begin
  FLock.Lock;
  try
    if FBehaviorQueue.Count > 0 then begin
      Result := FBehaviorQueue.Dequeue;
    end else begin
      Result := TBehavior.Create;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TBehaviorPool.DeAllocate(ABehavior: TBehavior);
begin
  FLock.Lock;
  try
    if ABehavior = nil then Exit;
    if FBehaviorQueue.Count < self.FPoolSize then begin
      FBehaviorQueue.Enqueue(ABehavior);
    end else begin
      ABehavior.Free;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
