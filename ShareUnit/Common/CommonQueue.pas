unit CommonQueue;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,  
  CommonLock,
  CommonRefCounter,
  Generics.Collections;

type


  TSemaphoreQueue<T> = class(TAutoObject)
  protected
    // 队列管理对象
    FQueue: TQueue<T>;
    // Windows 信号句柄
    FSemaphore: Cardinal;

    // 初始化 Windows 信号句柄
    procedure InitSemaphore;
    // 卸载 Windows 信号句柄
    procedure UnInitSemaphore;
  public
    // 构造方法
    constructor Create; override;
    // 析构方法
    destructor Destroy; override;
    // 进队列
    function Dequeue: T; virtual;
    // 出队列
    procedure Enqueue(const AValue: T); virtual;
    // 释放信号
    procedure ReleaseSemaphore;

    property Semaphore: Cardinal read FSemaphore;
  end;

  TSafeQueue<T> = class(TAutoObject)
  protected
    // 队列管理对象
    FQueue: TQueue<T>;
    // 线程安全锁
    FLock: TCSLock;
  public
    // 构造方法
    constructor Create; override;
    // 析构方法
    destructor Destroy; override;
    // 进队列
    function Dequeue: T;
    // 出队列
    procedure Enqueue(const AValue: T);
    // 队列是不是为空
    function IsEmpty: boolean;
  end;

  TSafeSemaphoreQueue<T> = class(TSemaphoreQueue<T>)
  protected
    // 线程安全锁
    FLock: TCSLock;
  public
    // 构造方法
    constructor Create; override;
    // 析构方法
    destructor Destroy; override;
    // 进队列
    function Dequeue: T; override;
    // 出队列
    procedure Enqueue(const AValue: T); override;
    // 队列是不是为空
    function IsEmpty: boolean;
  end;

  TSafeSemaphoreCircularQueue = class
  private
    // 线程安全锁
    FLock: TCSLock;
    // 队列元素个数
    FCount: Integer;
    // 队列容量
    FCapacity: Integer;
    // Windows 信号句柄
    FSemaphore: Cardinal;
    // 元素指针
    FElements: Array of Pointer;
    // 元素下表
    FElementIndex: Integer;

    // 初始化 Windows 信号句柄
    procedure InitSemaphore;
    // 卸载 Windows 信号句柄
    procedure UnInitSemaphore;
  protected
    // 生成新的容量
    function NewCapacity: Integer;
    // 增长容量
    procedure GrowCapacity(ANewCapacity: Integer);
  public
    // 构造方法
    constructor Create(ACapacity: Integer); virtual;
    // 析构方法
    destructor Destroy; override;
    // 元素下表放到第一个
    procedure First;
    // 元素下表放到下一个
    procedure Next;
    // 清空
    procedure Clear;
    // 是不是结束
    function IsEOF: Boolean;
    // 增加一个元素在末尾
    procedure Add(AElement: Pointer);
    // 增加一个元素在当前的循环遍历下一个元素的下标
    procedure AddAtElementIndex(AElement: Pointer);
    // 获取下一个元素并且移动下标
    function GetNextElement: Pointer;
    // 获取当前元素
    function GetCurrentElement: Pointer;
    // 释放信号
    procedure ReleaseSemaphore;

    property Semaphore: Cardinal read FSemaphore;
  end;


implementation

{ TSemaphoreQueue<T> }

constructor TSemaphoreQueue<T>.Create;
begin
  inherited;
  FQueue := TQueue<T>.Create;
  InitSemaphore;
end;

destructor TSemaphoreQueue<T>.Destroy;
begin
  UnInitSemaphore;
  FQueue.Free;
  inherited;
end;

procedure TSemaphoreQueue<T>.InitSemaphore;
begin
  FSemaphore := CreateSemaphore(nil, 0, 100, nil);
end;

procedure TSemaphoreQueue<T>.UnInitSemaphore;
begin
  CloseHandle(FSemaphore);
end;

procedure TSemaphoreQueue<T>.Enqueue(const AValue: T);
begin
  FQueue.Enqueue(AValue);
end;

function TSemaphoreQueue<T>.Dequeue: T;
begin
  Result := FQueue.Dequeue;
end;

procedure TSemaphoreQueue<T>.ReleaseSemaphore;
var
  tmpCount: Integer;
begin
  Windows.ReleaseSemaphore(FSemaphore, 1, @tmpCount);
end;

{ TSafeQueue<T> }

constructor TSafeQueue<T>.Create;
begin
  inherited;
  FQueue := TQueue<T>.Create;
  FLock := TCSLock.Create;
end;

destructor TSafeQueue<T>.Destroy;
begin
  FLock.Free;
  FQueue.Free;
  inherited;
end;

function TSafeQueue<T>.Dequeue: T;
begin
  FLock.Lock;
  try
    Result := FQueue.Dequeue;
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeQueue<T>.Enqueue(const AValue: T);
begin
  FLock.Lock;
  try
    FQueue.Enqueue(AValue);
  finally
    FLock.UnLock;
  end;
end;

function TSafeQueue<T>.IsEmpty: boolean;
begin
  FLock.Lock;
  try
    Result := (FQueue.Count <= 0);
  finally
    FLock.UnLock;
  end;
end;

{ TSafeSemaphoreQueue<T> }

constructor TSafeSemaphoreQueue<T>.Create;
begin
  inherited;
  FLock := TCSLock.Create;
end;

destructor TSafeSemaphoreQueue<T>.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TSafeSemaphoreQueue<T>.Dequeue: T;
begin
  FLock.Lock;
  try
    Result := FQueue.Dequeue;
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeSemaphoreQueue<T>.Enqueue(const AValue: T);
begin
  FLock.Lock;
  try
    FQueue.Enqueue(AValue);
  finally
    FLock.UnLock;
  end;
end;

function TSafeSemaphoreQueue<T>.IsEmpty: boolean;
begin
  FLock.Lock;
  try
    Result := (FQueue.Count <= 0);
  finally
    FLock.UnLock;
  end;
end;

{ TSafeSemaphoreCircularQueue }

constructor TSafeSemaphoreCircularQueue.Create(ACapacity: Integer);
begin
  inherited Create;
  InitSemaphore;
  FLock := TCSLock.Create;
  FCount := 0;
  FElementIndex := 0;
  if ACapacity < 0 then begin
    ACapacity := 10;
  end;
  FCapacity := ACapacity;
  self.GrowCapacity(FCapacity);
end;

destructor TSafeSemaphoreCircularQueue.Destroy;
begin
  FLock.Free;
  UnInitSemaphore;
  inherited;
end;

function TSafeSemaphoreCircularQueue.NewCapacity: Integer;
begin
  Result := FCapacity * 2;
end;

procedure TSafeSemaphoreCircularQueue.GrowCapacity(ANewCapacity: Integer);
begin
  SetLength(FElements, ANewCapacity);
end;

procedure TSafeSemaphoreCircularQueue.InitSemaphore;
begin
  FSemaphore := CreateSemaphore(nil, 0, 100, nil);
end;

procedure TSafeSemaphoreCircularQueue.UnInitSemaphore;
begin
  CloseHandle(FSemaphore);
end;

procedure TSafeSemaphoreCircularQueue.First;
begin
  FElementIndex := 0;
end;

procedure TSafeSemaphoreCircularQueue.Next;
begin
  FLock.Lock;
  try
    if FCount = 0 then Exit;

    FElementIndex := (FElementIndex + 1) mod FCount;
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeSemaphoreCircularQueue.ReleaseSemaphore;
var
  tmpCount: Integer;
begin
  Windows.ReleaseSemaphore(FSemaphore, 1, @tmpCount);
end;

procedure TSafeSemaphoreCircularQueue.Clear;
begin
  FLock.Lock;
  try
    FCount := 0;
    SetLength(FElements, 0);
  finally
    FLock.UnLock;
  end;
end;

function TSafeSemaphoreCircularQueue.IsEOF: Boolean;
begin
  FLock.Lock;
  try
    if FElementIndex = FCount - 1 then begin
      Result := True;
    end else begin
      Result := False;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeSemaphoreCircularQueue.Add(AElement: Pointer);
begin
  FLock.Lock;
  try
    if FCount >= FCapacity then begin
      GrowCapacity(NewCapacity);
    end;
    FElements[FCount] := AElement;
    Inc(FCount);
  finally
    FLock.UnLock;
  end;
end;

procedure TSafeSemaphoreCircularQueue.AddAtElementIndex(AElement: Pointer);
var
  LIndex: Integer;
begin
  FLock.Lock;
  try
    if FCount >= FCapacity then begin
      GrowCapacity(NewCapacity);
    end;
    if (FCount > 0) or (FElementIndex < FCount - 1) then begin
      LIndex := (FElementIndex + 1) mod FCount;
      CopyMemory(@FElements[LIndex], @FElements[LIndex + 1], (FCount - LIndex));
    end else begin
      LIndex := FCount;
    end;
    FElements[LIndex] := AElement;
    Inc(FCount);
  finally
    FLock.UnLock;
  end;
end;

function TSafeSemaphoreCircularQueue.GetNextElement: Pointer;
begin
  FLock.Lock;
  try
    Result := nil;
    if FCount = 0 then Exit;
    Result := FElements[FElementIndex];
    FElementIndex := (FElementIndex + 1) mod FCount;
  finally
    FLock.UnLock;
  end;
end;

function TSafeSemaphoreCircularQueue.GetCurrentElement: Pointer;
begin
  Result := nil;
  FLock.Lock;
  try
    if (FCount = 0) or (FElementIndex >= FCount) then Exit;
    Result := FElements[FElementIndex];
  finally
    FLock.UnLock;
  end;
end;

end.
