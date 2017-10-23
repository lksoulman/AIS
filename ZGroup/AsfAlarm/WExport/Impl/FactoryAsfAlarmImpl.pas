unit FactoryAsfAlarmImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� AsfAlarm project factory implementation
// Author��      lksoulman
// Date��        2017-9-8
// Comments��    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfAlarm project factory implementation.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WFactoryImpl;

type

  // AsfAlarm project factory implementation
  TFactoryAsfAlarmImpl = class(TWFactoryImpl)
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

{ TFactoryAsfAlarmImpl }

constructor TFactoryAsfAlarmImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfAlarmImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfAlarmImpl.DoRegisterPlugIns;
begin


end;

initialization

  // Create global factory interface
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfAlarmImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
