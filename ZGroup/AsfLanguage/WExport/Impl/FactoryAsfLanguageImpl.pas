unit FactoryAsfLanguageImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-29
// Comments��    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfLanguage project factory implementation.
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

  // AsfLanguage project factory implementation
  TFactoryAsfLanguageImpl = class(TWFactoryImpl)
  private
  protected
    // Register PlugIns
    procedure DoRegisterPlugIns; override;
  public
    // Constructor method
    constructor Create;
    // Destructor method
    destructor Destroy; override;
  end;

var
  // Global factory
  G_WFactory: IInterface;

implementation

uses
  PlugIn;

{ TFactoryAsfLanguageImpl }

constructor TFactoryAsfLanguageImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfLanguageImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfLanguageImpl.DoRegisterPlugIns;
begin

end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfLanguageImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.

