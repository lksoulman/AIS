unit CacheGFDataPool;

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  CommonQueue,
  CacheGFData,
  Generics.Collections;


type

  TCacheGFDataPool = class
  private
    // 多线程锁
    FLock: TCSLock;
    // 池子最大的个数
    FMaxPoolSize: Integer;
    // 数据队列
    FQueue: TQueue<TCacheGFdata>;
  protected
    // 清空队列
    procedure ClearQueue;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 分配数据
    function Allocate: TCacheGFdata;
    // 回收数据
    procedure DeAllocate(AData: TCacheGFdata);
  end;

implementation

{ TCacheGFDataPool }

constructor TCacheGFDataPool.Create;
begin
  inherited;
  FMaxPoolSize := 10;
  FLock := TCSLock.Create;
  FQueue := TQueue<TCacheGFdata>.Create;
end;

destructor TCacheGFDataPool.Destroy;
begin
  FQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TCacheGFDataPool.ClearQueue;
var
  LData: TCacheGFData;
begin
  while FQueue.Count > 0 do begin
    LData := FQueue.Dequeue;
    if LData <> nil then begin
      LData.Free;
    end;
  end;
end;

function TCacheGFDataPool.Allocate: TCacheGFdata;
begin
  FLock.Lock;
  try
    if FQueue.Count > 0 then begin
      Result := FQueue.Dequeue;
    end else begin
      Result := TCacheGFdata.Create;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TCacheGFDataPool.DeAllocate(AData: TCacheGFdata);
begin
  if AData = nil then Exit;
  
  FLock.Lock;
  try
    if FQueue.Count < FMaxPoolSize then begin
      FQueue.Enqueue(AData);
    end else begin
      AData.Free;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
