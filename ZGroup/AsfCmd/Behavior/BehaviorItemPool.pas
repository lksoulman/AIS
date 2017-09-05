unit BehaviorItemPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Behavior Item Pool
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Behavior,
  CommonLock,
  CommonPool,
  BehaviorItem,
  Generics.Collections;

type

  // Behavior Item pool
  TBehaviorItemPool = class(TPointerPool)
  private
  protected
    // Create
    function DoCreate: Pointer; override;
    // Destroy
    procedure DoDestroy(APointer: Pointer); override;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{ TBehaviorItemPool }

constructor TBehaviorItemPool.Create;
begin
  inherited;
  FPoolSize := 10;
end;

destructor TBehaviorItemPool.Destroy;
begin
  inherited;
end;

function TBehaviorItemPool.DoCreate: Pointer;
var
  LPBehaviorItem: PBehaviorItem;
begin
  New(LPBehaviorItem);
  Result := LPBehaviorItem;
end;

procedure TBehaviorItemPool.DoDestroy(APointer: Pointer);
var
  LPBehaviorItem: PBehaviorItem;
begin
  if APointer <> nil then begin
    LPBehaviorItem := PBehaviorItem(APointer);
    Dispose(LPBehaviorItem);
  end;
end;

end.
