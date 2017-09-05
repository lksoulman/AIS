unit FactoryAsfHqCoreImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-31
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

  // AsfHqCore project factory implementation
  TFactoryAsfHqCoreImpl = class(TWFactoryImpl)
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
  HqCoreMgr,
  HqCoreMgrPlugInImpl;

{ TFactoryAsfHqCoreImpl }

constructor TFactoryAsfHqCoreImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfHqCoreImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfHqCoreImpl.DoRegisterPlugIns;
begin
  DoRegisterPlugIn(PLUGIN_ID_HQCOREMGR, itSingleInstance, lmLazy, THqCoreMgrPlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfHqCoreImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
