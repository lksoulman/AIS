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
  public
    // Constructor
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;
  end;

implementation

{ TKeyFairyItemPool }

constructor TKeyFairyItemPool.Create;
begin
  inherited;
  FPoolSize := 500;
end;

destructor TKeyFairyItemPool.Destroy;
begin
  inherited;
end;

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

end.
