unit CommonDynArray;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Dynamic Array
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonRefCounter,
  Generics.Collections;

type

  // Dynamic Array
  TDynArray<T> = class(TAutoObject)
  private
    // Element Count
    FCount: Integer;
    // Element Dynamic Array Capacity
    FCapacity: Integer;
    // Element Dynamic Array
    FElements: TArray<T>;
  protected
    // New Capacity
    procedure NewCapacity(ACapacity: Integer);
  public
    type
      TSortCompareFunc = function (AElement1, AElement2: T): Boolean of Object;
  private
    // Sort Compare function
    FSortCompareFunc: TSortCompareFunc;
    //
    procedure DoQuickSort;
  public
    // Constructor
    constructor Create(ACapacity: Integer = 0); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Quick Sort
    procedure QuickSort;
    // Clear Count, but not Clear Capacity
    procedure ClearCount;
    // Clear Count and Clear Capacity
    procedure ClearCapacity;
    // Add Element
    procedure Add(AElement: T);
    // Get Count
    function GetCount: Integer;
    // Get Element
    function GetElement(AIndex: Integer): T;
    // Set Compare Function
    procedure SetSortCompareFunc(ACompareFunc: TSortCompareFunc);
  end;


implementation

{ TDynArray<T> }

constructor TDynArray<T>.Create(ACapacity: Integer = 0);
begin
  inherited Create;
  FCount := 0;
  FCapacity := 0;
  if ACapacity > 0 then begin
    NewCapacity(ACapacity);
  end;
end;

destructor TDynArray<T>.Destroy;
begin
  ClearCapacity;
  inherited;
end;

procedure TDynArray<T>.DoQuickSort;
begin

end;

procedure TDynArray<T>.QuickSort;
begin
  if not Assigned(FSortCompareFunc) then Exit;
  DoQuickSort;
end;

procedure TDynArray<T>.ClearCount;
begin
  FCount := 0;
end;

procedure TDynArray<T>.ClearCapacity;
begin
  FCount := 0;
  FCapacity := 0;
  SetLength(FElements, FCapacity);
end;

procedure TDynArray<T>.Add(AElement: T);
begin
  if FCount > FCapacity then begin
    NewCapacity(FCapacity);
  end;
  FElements[FCount] := AElement;
  Inc(FCount);
end;

function TDynArray<T>.GetCount: Integer;
begin
  Result := FCount;
end;

function TDynArray<T>.GetElement(AIndex: Integer): T;
begin
  Result := FElements[AIndex];
end;

procedure TDynArray<T>.NewCapacity(ACapacity: Integer);
var
  LNewCapacity: Integer;
begin
  if ACapacity < 100 then begin
    LNewCapacity := ACapacity * 2;
  end else if ACapacity < 1000 then begin
    LNewCapacity := ACapacity + Trunc(FCapacity * 0.25);
  end else if ACapacity < 10000 then begin
    LNewCapacity := ACapacity + Trunc(FCapacity * 0.05);
  end else if ACapacity < 100000 then begin
    LNewCapacity := ACapacity + Trunc(FCapacity * 0.01);
  end else if ACapacity < 1000000 then begin
    LNewCapacity := ACapacity + Trunc(FCapacity * 0.001);
  end else if ACapacity < 10000000 then begin
    LNewCapacity := ACapacity + Trunc(FCapacity * 0.0001);
  end else begin
    LNewCapacity := ACapacity + Trunc(FCapacity * 0.00001);
  end;
  FCapacity := LNewCapacity;
  SetLength(FElements, FCapacity);
end;

procedure TDynArray<T>.SetSortCompareFunc(ACompareFunc: TSortCompareFunc);
begin
  FSortCompareFunc := ACompareFunc;
end;

end.
