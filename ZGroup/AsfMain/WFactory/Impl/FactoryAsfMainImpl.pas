unit FactoryAsfMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfMain project factory implementation.
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

  // AsfMain project factory implementation
  TFactoryAsfMainImpl = class(TWFactoryImpl)
  private
  protected
    // Register PlugIns
    procedure DoRegisterPlugIns; override;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

var
  // Global factory
  G_WFactory: IInterface;

implementation

uses
  LoginPlugInImpl;

{ TFactoryAsfMainImpl }

constructor TFactoryAsfMainImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfMainImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfMainImpl.DoRegisterPlugIns;
begin
  DoRegisterPlugIn(LIB_PLUGIN_ID_LOGIN, itSingleInstance, lmLazy, TLoginPlugInImpl);
end;

initialization

  // Create global factory interface
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfMainImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
