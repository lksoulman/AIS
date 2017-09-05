unit FactoryAsfServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfService project factory implementation
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfService project factory implementation.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WFactoryImpl;

type

  // AsfService project factory implementation
  TFactoryAsfServiceImpl = class(TWFactoryImpl)
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

{ TFactoryAsfServiceImpl }

constructor TFactoryAsfServiceImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfServiceImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfServiceImpl.DoRegisterPlugIns;
begin


end;

initialization

  // Create global factory interface
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfServiceImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
