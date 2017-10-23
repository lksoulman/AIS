unit FactoryAsfToolImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfTool project factory implementation
// Author£º      lksoulman
// Date£º        2017-9-1
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfTool project factory implementation.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WFactoryImpl;

type

  // AsfTool project factory implementation
  TFactoryAsfToolImpl = class(TWFactoryImpl)
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
  PlugInConst,
  ServiceExplorerPlugInImpl,
  UpdateExplorerPlugInImpl;

{ TFactoryAsfToolImpl }

constructor TFactoryAsfToolImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfToolImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfToolImpl.DoRegisterPlugIns;
begin
  DoRegisterPlugIn(LIB_PLUGIN_ID_SERVICEEXPLORER, itSingleInstance, lmLazy, TServiceExplorerPlugInImpl);
  DoRegisterPlugIn(LIB_PLUGIN_ID_UPDATEEXPLORER, itSingleInstance, lmLazy, TUpdateExplorerPlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfToolImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
