unit IOCPMemory;

interface

uses Windows, Classes, SysUtils, ZLib;

const

  M_SIZE_2K = 2048;
  M_SIZE_4K = 4096;
  M_SIZE_8K = 8192;
  M_SIZE_16K = 16384;
  M_SIZE_32K = 32768;
  M_SIZE_64K = 65536;
  M_SIZE_128K = 131072;
  M_SIZE_256K = 262144;
  M_SIZE_512K = 524288;
  M_SIZE_1M = 1048576;
  M_SIZE_2M = 2097152;

  C_QueueSize: array [0 .. 10] of integer = (M_SIZE_2K, M_SIZE_4K, M_SIZE_8K, M_SIZE_16K, M_SIZE_32K, M_SIZE_64K,
    M_SIZE_128K, M_SIZE_256K, M_SIZE_512K, M_SIZE_1M, M_SIZE_2M);
  C_InitCount = 1;

type

  // 下面的队列是比较成熟的支持FIFO和LIFO的队列，进出队的元素是指针和大小
  // 整个队列使用过程中不用申请和释放内存（这个是以前版本的重大弊端），
  // 因此操作比较安全和快速

  PQueueItem = ^TQueueItem;

  TQueueItem = packed record
    DataSize: integer; // 当前数据的大小
    QueueValue: Pointer; // 一块内存的指针，可以指向任何数据
    Next: PQueueItem;
    Prior: PQueueItem;
  end;

  TIOCPQueue = class
  private
    FQueueHeads: TList;

    FHeadPtr: PQueueItem; // 当前操作的头和尾  出取的是FHeadPtr，进操作的是FTailPtr
    FTailPtr: PQueueItem;

    FCapacity: integer; // 队列容量   用于初始化内存映射区
    FCount: integer; // 队列个数

    FNeedSema: boolean;
    FRCSQueueProtect: TRTLCriticalSection;
    FQueueSemaphore: THandle;

    function GetIsBlank: boolean;
  protected

    function DeltaCount(Value: integer): integer;
    function GrowQuete(Value: integer): boolean;

    function GetFIFOItem(var Size: integer; pRemainCount: PInteger = nil): Pointer;
    function GetLIFOItem(var Size: integer; pRemainCount: PInteger = nil): Pointer;
  public
    constructor Create(Capacity: integer; NeedSema: boolean = true);
    destructor Destroy; override;

    property IsBlank: boolean read GetIsBlank; // 头等于尾就是空
    property QueueSize: integer read FCapacity;
    property Count: integer read FCount;
    property QueueSemaphore: THandle read FQueueSemaphore;
    procedure ClearItem; // 头＝尾就清空了

    function AddItem(Data: Pointer; Size: integer): bool;
    function GetItem(var Size: integer; pRemainCount: PInteger = nil): Pointer; virtual; abstract;
    function Pop: Pointer;
    procedure LockQueue;
    procedure UnLockQueue;
    function ReleaseSemaphore(lReleaseCount: Longint; lpPreviousCount: Pointer): bool;
  end;

  // 先进先出
  TFIFOQueue = class(TIOCPQueue)
  public
    function GetItem(var Size: integer; pRemainCount: PInteger = nil): Pointer; override;
  end;

  // 先进后出
  TLIFOQueue = class(TIOCPQueue)
  public
    function GetItem(var Size: integer; pRemainCount: PInteger = nil): Pointer; override;
  end;

  PMemoryBlock = ^TMemoryBlock;
  TMemoryBlock = (mbBlock_2K = 0, // 2K块
    mbBlock_4K = 1, // 4K块
    mbBlock_8K = 2, // 8K块
    mbBlock_16K = 3, // 16K块
    mbBlock_32K = 4, // 32K块
    mbBlock_64K = 5, // 64K块
    mbBlock_128K = 6, // 128K块
    mbBlock_256K = 7, // 256K块
    mbBlock_512K = 8, // 512K块
    mbBlock_1M = 9, // 1M块
    mbBlock_2M = 10, // 2M块
    mbBlock_Free = 11);

function GetMemEx(var P: PAnsiChar; Size: integer): boolean; overload;
function GetMemEx(var P: Pointer; Size: integer): boolean; overload;
function FreeMemEx(P: Pointer): boolean;

implementation

// function GetMemEx(var P: PAnsiChar; Size: integer): boolean; overload;
// begin
// P := IOCPMemMngr.GetMemEx(Size);
// result := p <> nil;
// end;
//
// function GetMemEx(var P: Pointer; Size: integer): boolean; overload;
// begin
// P := IOCPMemMngr.GetMemEx(Size);
// result := p <> nil;
// end;
//
// function FreeMemEx(P: Pointer): boolean;
// begin
// IOCPMemMngr.FreeMemEx(P);
// result := true;
// end;
//
// function ReallocMemEx(var P: Pointer; Size: integer): boolean;
// begin
// p := IOCPMemMngr.ReallocMemEx(p, Size);
// result := true;
// end;
//
function GetMemEx(var P: PAnsiChar; Size: integer): boolean; overload;
begin

  GetMem(Pointer(P), Size);
  result := P <> nil;
  // result := _GetMemEx(p, Size);
end;

function GetMemEx(var P: Pointer; Size: integer): boolean; overload;
begin
  GetMem(P, Size);
  result := P <> nil;
  // result := _GetMemEx(p, Size);
end;

function FreeMemEx(P: Pointer): boolean;
begin
  FreeMem(P);
  result := true;
  // result := _FreeMemEx(P);
end;

function zlibAllocMem(AppData: Pointer; Items, Size: integer): Pointer;
begin
  GetMemEx(result, Items * Size);
  FillMemory(result, Items * Size, 0);
End;

procedure zlibFreeMem(AppData, Block: Pointer);
begin
  FreeMemEx(Block);
End;

function DeflateInit(var stream: TZStreamRec; level: integer): integer;
begin
  result := DeflateInit_(stream, level, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function InflateInit(var stream: TZStreamRec): integer;
begin
  result := InflateInit_(stream, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function ZCompressCheck(code: integer): integer;
begin
  result := code;

  if code < 0 then
  begin
    raise EZCompressionError.Create(string(_z_errmsg[2 - code]));
  end;
end;

function ZDecompressCheck(code: integer): integer;
begin
  result := code;

  if code < 0 then
  begin
    raise EZDecompressionError.Create(string(_z_errmsg[2 - code]));
  end;
end;

{ TIOCPQueue }

function TIOCPQueue.AddItem(Data: Pointer; Size: integer): bool;
var
  Value: integer;
begin
  EnterCriticalSection(FRCSQueueProtect);
  try
    if FCount >= FCapacity then
    begin
      Value := DeltaCount(FCapacity);
      GrowQuete(Value - FCapacity);
      FCapacity := Value;
    end;

    FTailPtr^.QueueValue := Data;
    FTailPtr^.DataSize := Size;

    FTailPtr := FTailPtr^.Next;

    FCount := FCount + 1;
    result := true;
  finally
    LeaveCriticalSection(FRCSQueueProtect);
  end;
end;

procedure TIOCPQueue.ClearItem;
begin
  EnterCriticalSection(FRCSQueueProtect);
  try
    if FQueueHeads.Count > 0 then
    begin
      FHeadPtr := FQueueHeads[0];
      FTailPtr := FHeadPtr;
    end;
    FCount := 0;
  finally
    LeaveCriticalSection(FRCSQueueProtect);
  end;
end;

constructor TIOCPQueue.Create(Capacity: integer; NeedSema: boolean);
begin
  FCount := 0;

  FNeedSema := NeedSema;

  FQueueHeads := TList.Create;

  // 初始化临界资源
  InitializeCriticalSection(FRCSQueueProtect);

  if FNeedSema then
    FQueueSemaphore := CreateSemaphore(nil, 0, High(integer), nil);

  if Capacity <= 1 then
    FCapacity := 2
  else
    FCapacity := Capacity;

  GrowQuete(FCapacity);
end;

function TIOCPQueue.DeltaCount(Value: integer): integer;
begin
  if Value > 255 then
    result := Value + Value div 4
  else
    result := Value + 64
end;

destructor TIOCPQueue.Destroy;
var
  i: integer;
begin
  DeleteCriticalSection(FRCSQueueProtect);

  if FQueueHeads <> nil then
  begin
    for i := 0 to FQueueHeads.Count - 1 do
      FreeMemEx(FQueueHeads[i]);
    FQueueHeads.Free;
  end;

  if FNeedSema and (FQueueSemaphore <> 0) then
  begin
    CloseHandle(FQueueSemaphore);
    FQueueSemaphore := 0;
  end;

  inherited Destroy;
end;

function TIOCPQueue.GetFIFOItem(var Size: integer; pRemainCount: PInteger): Pointer;
begin
  EnterCriticalSection(FRCSQueueProtect);
  try
    result := FHeadPtr^.QueueValue;
    Size := FHeadPtr^.DataSize;
    FHeadPtr := FHeadPtr^.Next;
    FCount := FCount - 1;
    if pRemainCount <> nil then
      pRemainCount^ := FCount;
  finally
    LeaveCriticalSection(FRCSQueueProtect);
  end;
end;

function TIOCPQueue.GetIsBlank: boolean;
begin
  result := FHeadPtr = FTailPtr;
end;

function TIOCPQueue.GetLIFOItem(var Size: integer; pRemainCount: PInteger): Pointer;
var
  LIFOItem: PQueueItem;
begin
  EnterCriticalSection(FRCSQueueProtect);
  try
    LIFOItem := FTailPtr^.Prior;
    result := LIFOItem^.QueueValue;
    Size := LIFOItem^.DataSize;

    FTailPtr := FTailPtr^.Prior;
    FCount := FCount - 1;
    if pRemainCount <> nil then
      pRemainCount^ := FCount;
  finally
    LeaveCriticalSection(FRCSQueueProtect);
  end;
end;

function TIOCPQueue.GrowQuete(Value: integer): boolean;
var
  i: integer;
  pItem: PQueueItem;
  QueueHead: Pointer;
begin
  result := false;
  GetMemEx(QueueHead, Value * SizeOf(TQueueItem));

  if QueueHead <> nil then
  begin

    // 下面开始生成链表
    result := true;

    pItem := QueueHead;
    for i := 1 to Value - 1 do
    begin
      pItem.Next := Pointer(integer(pItem) + SizeOf(TQueueItem));
      if pItem <> QueueHead then
        pItem.Prior := Pointer(integer(pItem) - SizeOf(TQueueItem));
      inc(pItem);
    end;
    // 最后一个
    pItem.Prior := Pointer(integer(pItem) - SizeOf(TQueueItem));

    if FQueueHeads.Count = 0 then
    begin
      // 又回到从前
      pItem.Next := QueueHead;
      PQueueItem(QueueHead).Prior := pItem;
      FHeadPtr := QueueHead;
      FTailPtr := QueueHead;
    end
    else
    begin
      // 断开链接
      PQueueItem(QueueHead)^.Prior := FTailPtr^.Prior;
      FTailPtr^.Prior^.Next := PQueueItem(QueueHead);
      pItem^.Next := FHeadPtr;
      FHeadPtr^.Prior := pItem;
      FTailPtr := QueueHead;
    end;

    FQueueHeads.Add(QueueHead);
  end;
end;

procedure TIOCPQueue.LockQueue;
begin
  EnterCriticalSection(FRCSQueueProtect);
end;

function TIOCPQueue.Pop: Pointer;
var
  Size: integer;
begin
  result := GetItem(Size, nil);
end;

function TIOCPQueue.ReleaseSemaphore(lReleaseCount: integer; lpPreviousCount: Pointer): bool;
begin
  result := Windows.ReleaseSemaphore(FQueueSemaphore, lReleaseCount, lpPreviousCount);
end;

procedure TIOCPQueue.UnLockQueue;
begin
  LeaveCriticalSection(FRCSQueueProtect);
end;

{ TFIFOQueue }
function TFIFOQueue.GetItem(var Size: integer; pRemainCount: PInteger): Pointer;
begin
  result := nil;
  if (FCount > 0) then
  begin
    result := GetFIFOItem(Size, pRemainCount);
  end;
end;

{ TLIFOQueue }
function TLIFOQueue.GetItem(var Size: integer; pRemainCount: PInteger): Pointer;
begin
  result := nil;
  if (FCount > 0) then
  begin
    result := GetLIFOItem(Size, pRemainCount);
  end;
end;

//
// initialization
// IOCPMemMngr := TIOCPMemory.Create;
//
//
// finalization
// IOCPMemMngr.Free;
end.
