unit MsgPool;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message Extend Pool
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgFunc,
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  CommonPool,
  Generics.Collections;

type

  // Msg Pool
  TMsgPool = class(TObjectPool)
  private
    // Create object
    FMsgFuncCreate: TMsgFuncCreate;
  protected
    // Create
    function DoCreate: TObject; override;
    // Destroy
    procedure DoDestroy(AObject: TObject); override;
  public
    // Constructor
    constructor Create(AMsgFuncCreate: TMsgFuncCreate); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Lock
    procedure Lock;
    // Un Lock
    procedure UnLock;
  end;

implementation

{ TMsgPool }

constructor TMsgPool.Create(AMsgFuncCreate: TMsgFuncCreate);
begin
  inherited Create;
  FPoolSize := 20;
  FMsgFuncCreate := AMsgFuncCreate;
end;

destructor TMsgPool.Destroy;
begin
  inherited;
end;

procedure TMsgPool.Lock;
begin
  FLock.Lock;
end;

procedure TMsgPool.UnLock;
begin
  FLock.UnLock;
end;

function TMsgPool.DoCreate: TObject;
begin
  if Assigned(FMsgFuncCreate) then begin
    Result := FMsgFuncCreate;
  end else begin
    Result := nil;
  end;
end;

procedure TMsgPool.DoDestroy(AObject: TObject);
begin
  if AObject <> nil then begin
    AObject.Free;
  end;
end;

end.
