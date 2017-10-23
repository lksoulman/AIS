unit UpdateInfoPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Update Info Pool
// Author��      lksoulman
// Date��        2017-9-13
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonPool,
  UpdateInfo;

type

  // Update Info Pool
  TUpdateInfoPool = class(TObjectPool)
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

{ TUpdateInfoPool }

function TUpdateInfoPool.DoCreate: TObject;
begin
  Result := TUpdateInfo.Create;
end;

procedure TUpdateInfoPool.DoDestroy(AObject: TObject);
begin
  if AObject <> nil then begin
    AObject.Free;
  end;
end;

procedure TUpdateInfoPool.DoAllocateBefore(AObject: TObject);
begin

end;

procedure TUpdateInfoPool.DoDeAllocateBefore(AObject: TObject);
begin
  if AObject <> nil then begin
    TUpdateInfo(AObject).ResetValue;
  end;
end;
end.
