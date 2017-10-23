unit KeyFairyItemPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Key Fairy Pool
// Author£º      lksoulman
// Date£º        2017-7-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  CommonPool,
  KeyFairyItem,
  Generics.Collections;

type

  // Key Fairy Pool
  TKeyFairyItemPool = class(TPointerPool)
  private
  protected
    // Create
    function DoCreate: Pointer; override;
    // Destroy
    procedure DoDestroy(APointer: Pointer); override;
    // Allocate Before
    procedure DoAllocateBefore(APointer: Pointer); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(APointer: Pointer); override;
  public
  end;

implementation

{ TKeyFairyItemPool }

function TKeyFairyItemPool.DoCreate: Pointer;
var
  LPKeyFairyItem: PKeyFairyItem;
begin
  New(LPKeyFairyItem);
  Result := LPKeyFairyItem;
end;

procedure TKeyFairyItemPool.DoDestroy(APointer: Pointer);
var
  LPKeyFairyItem: PKeyFairyItem;
begin
  if APointer <> nil then begin
    LPKeyFairyItem := PKeyFairyItem(APointer);
    Dispose(LPKeyFairyItem);
  end;
end;

procedure TKeyFairyItemPool.DoAllocateBefore(APointer: Pointer);
begin

end;

procedure TKeyFairyItemPool.DoDeAllocateBefore(APointer: Pointer);
begin

end;

end.
