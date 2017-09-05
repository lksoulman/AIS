unit FactoryAsfAuthImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               Authority project factory implementation.
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

  // Authority project factory implementation
  TFactoryAsfAuthImpl = class(TWFactoryImpl)
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
  PlugIn,
  HqAuth,
  ProductAuth,
  HqAuthPlugInImpl,
  ProductAuthPlugInImpl;

{ TFactoryAsfAuthImpl }

constructor TFactoryAsfAuthImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfAuthImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfAuthImpl.DoRegisterPlugIns;
begin
  DoRegisterPlugIn(PLUGIN_ID_HQAUTH, itSingleInstance, lmLazy, THqAuthPlugInImpl);
  DoRegisterPlugIn(PLUGIN_ID_PRODUCTAUTH, itSingleInstance, lmLazy, TProductAuthPlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfAuthImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
