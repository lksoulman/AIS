unit KeyFairyPool;

interface

uses
  Windows,
  Classes,
  SysUtils,
  KeyFairy,
  CommonLock,
  CommonRefCounter,
  Generics.Collections;

type

  // 行为对象池
  TKeyFairyPool = class
  private
    // 线程锁
    FLock: TCSLock;
    // 池子大小
    FPoolSize: Integer;
    // 行为对象队列
    FObjectQueue: TQueue<TKeyFairy>;
  protected
    // 清空和释放队列中对象
    procedure DoClearQueue;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 分配一个行为对象
    function Allocate: TKeyFairy;
    // 回收一个行为对象
    procedure DeAllocate(AObject: TKeyFairy);
  end;

implementation

{ TKeyFairyPool }

constructor TKeyFairyPool.Create;
begin
  inherited;
  FPoolSize := 100;
  FLock := TCSLock.Create;
  FObjectQueue := TQueue<TKeyFairy>.Create;
end;

destructor TKeyFairyPool.Destroy;
begin
  DoClearQueue;
  FObjectQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TKeyFairyPool.DoClearQueue;
var
  LObject: TKeyFairy;
begin
  while self.FObjectQueue.Count > 0 do begin
    LObject := FObjectQueue.Dequeue;
    if LObject <> nil then begin
      LObject.Free;
    end;
  end;
end;

function TKeyFairyPool.Allocate: TKeyFairy;
begin
  FLock.Lock;
  try
    if FObjectQueue.Count > 0 then begin
      Result := FObjectQueue.Dequeue;
    end else begin
      Result := TKeyFairy.Create;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TKeyFairyPool.DeAllocate(AObject: TKeyFairy);
begin
  FLock.Lock;
  try
    if AObject = nil then Exit;
    if FObjectQueue.Count < self.FPoolSize then begin
      FObjectQueue.Enqueue(AObject);
    end else begin
      AObject.Free;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
