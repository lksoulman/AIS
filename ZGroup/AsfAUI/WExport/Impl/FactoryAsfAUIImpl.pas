unit FactoryAsfAUIImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� AsfAUI project factory implementation
// Author��      lksoulman
// Date��        2017-9-1
// Comments��    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfAUI project factory implementation.
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

  // AsfAUI project factory implementation
  TFactoryAsfAUIImpl = class(TWFactoryImpl)
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

{ TFactoryAsfAUIImpl }

constructor TFactoryAsfAUIImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfAUIImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfAUIImpl.DoRegisterPlugIns;
begin
//  DoRegisterPlugIn(PLUGIN_ID_MSGCORE, itSingleInstance, lmLazy, TMsgCorePlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfAUIImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
