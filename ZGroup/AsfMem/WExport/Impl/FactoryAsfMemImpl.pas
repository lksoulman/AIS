unit FactoryAsfMemImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfMem project factory implementation
// Author£º      lksoulman
// Date£º        2017-9-1
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfMem project factory implementation.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInConst,
  WFactoryImpl;

type

  // AsfMem project factory implementation
  TFactoryAsfMemImpl = class(TWFactoryImpl)
  private
  protected
    // Register PlugIns
    procedure DoRegisterPlugIns; override;
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;
  end;

var
  // Global factory
  G_WFactory: IInterface;

implementation

uses
  PlugIn;

{ TFactoryAsfMemImpl }

constructor TFactoryAsfMemImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfMemImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfMemImpl.DoRegisterPlugIns;
begin
//  DoRegisterPlugIn(PLUGIN_ID_MSGCORE, itSingleInstance, lmLazy, TMsgCorePlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfMemImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
