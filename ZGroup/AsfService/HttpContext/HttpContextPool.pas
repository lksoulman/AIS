unit HttpContextPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Http Context Pool
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonPool,
  HttpContext;

type

  // Http Context Pool
  THttpContextPool = class(TObjectPool)
  private
  protected
    // Create
    function DoCreate: TObject; override;
    // Destroy
    procedure DoDestroy(AObject: TObject); override;
    // Allocate Before
    procedure DoAllocateBefore(AObject: TObject); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(AObject: TObject); override;
  public
  end;

implementation

{ THttpContextPool }

function THttpContextPool.DoCreate: TObject;
begin
  Result := THttpContext.Create;
end;

procedure THttpContextPool.DoDestroy(AObject: TObject);
begin
  if AObject <> nil then begin
    AObject.Free;
  end;
end;

procedure THttpContextPool.DoAllocateBefore(AObject: TObject);
begin

end;

procedure THttpContextPool.DoDeAllocateBefore(AObject: TObject);
begin
  if AObject <> nil then begin
    THttpContext(AObject).ResetInit;
  end;
end;

end.
