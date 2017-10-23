unit CommonPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-31
// Comments£º
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

  // Object pool
  TObjectPool = class(TAutoObject)
  private
  protected
    // Thread lock
    FLock: TCSLock;
    // Pool size
    FPoolSize: Integer;
    // Queue
    FQueue: TQueue<TObject>;

    // Clear Queue
    procedure DoClearQueue;
    // Create
    function DoCreate: TObject; virtual; abstract;
    // Destroy
    procedure DoDestroy(AObject: TObject); virtual; abstract;
    // Allocate Before
    procedure DoAllocateBefore(AObject: TObject); virtual; abstract;
    // DeAllocate Before
    procedure DoDeAllocateBefore(AObject: TObject); virtual; abstract;
  public
    // Constructor
    constructor Create(APoolSize: Integer = 10); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Allocate
    function Allocate: TObject;
    // DeAllocate
    procedure DeAllocate(AObject: TObject);
  end;

  // Pointer Pool
  TPointerPool = class(TAutoObject)
  private
  protected
    // Thread lock
    FLock: TCSLock;
    // Pool size
    FPoolSize: Integer;
    // Queue
    FQueue: TQueue<Pointer>;

    // Clear Queue
    procedure DoClearQueue;
    // Create
    function DoCreate: Pointer; virtual; abstract;
    // Destroy
    procedure DoDestroy(APointer: Pointer); virtual; abstract;
    // Allocate Before
    procedure DoAllocateBefore(APointer: Pointer); virtual; abstract;
    // DeAllocate Before
    procedure DoDeAllocateBefore(APointer: Pointer); virtual; abstract;
  public
    // Constructor
    constructor Create(APoolSize: Integer = 10); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Allocate
    function Allocate: Pointer;
    // DeAllocate
    procedure DeAllocate(APointer: Pointer);
  end;

implementation

{ TObjectPool }

constructor TObjectPool.Create(APoolSize: Integer = 10);
begin
  inherited Create;
  FPoolSize := APoolSize;
  FLock := TCSLock.Create;
  FQueue := TQueue<TObject>.Create;
end;

destructor TObjectPool.Destroy;
begin
  DoClearQueue;
  FQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TObjectPool.DoClearQueue;
var
  LObject: TObject;
begin
  while FQueue.Count > 0 do begin
    LObject := FQueue.Dequeue;
    DoDestroy(LObject);
  end;
end;

function TObjectPool.Allocate: TObject;
begin
  FLock.Lock;
  try
    if FQueue.Count > 0 then begin
      Result := FQueue.Dequeue;
    end else begin
      Result := DoCreate;
    end;
    DoAllocateBefore(Result);
  finally
    FLock.UnLock;
  end;
end;

procedure TObjectPool.DeAllocate(AObject: TObject);
begin
  FLock.Lock;
  try
    DoDeAllocateBefore(AObject);
    if FQueue.Count < FPoolSize then begin
      FQueue.Enqueue(AObject);
    end else begin
      DoDestroy(AObject);
    end;
  finally
    FLock.UnLock;
  end;
end;

{ TPointerPool }

constructor TPointerPool.Create(APoolSize: Integer = 10);
begin
  inherited Create;
  FPoolSize := APoolSize;
  FLock := TCSLock.Create;
  FQueue := TQueue<Pointer>.Create;
end;

destructor TPointerPool.Destroy;
begin
  DoClearQueue;
  FQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TPointerPool.DoClearQueue;
var
  LPointer: Pointer;
begin
  while FQueue.Count > 0 do begin
    LPointer := FQueue.Dequeue;
    DoDestroy(LPointer);
  end;
end;

function TPointerPool.Allocate: Pointer;
begin
  FLock.Lock;
  try
    if FQueue.Count > 0 then begin
      Result := FQueue.Dequeue;
    end else begin
      Result := DoCreate;
    end;
    DoAllocateBefore(Result);
  finally
    FLock.UnLock;
  end;
end;

procedure TPointerPool.DeAllocate(APointer: Pointer);
begin
  FLock.Lock;
  try
    DoDeAllocateBefore(APointer);
    if FQueue.Count < FPoolSize then begin
      FQueue.Enqueue(APointer);
    end else begin
      DoDestroy(APointer);
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
