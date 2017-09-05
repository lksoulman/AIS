unit FactoryAsfMsgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfMsg project factory implementation
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfMsg project factory implementation.
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

  // AsfMsg project factory implementation
  TFactoryAsfMsgImpl = class(TWFactoryImpl)
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
  MsgService,
  MsgServicePlugInImpl;

{ TFactoryAsfMsgImpl }

constructor TFactoryAsfMsgImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfMsgImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfMsgImpl.DoRegisterPlugIns;
begin
  DoRegisterPlugIn(PLUGIN_ID_MSGSERVICE, itSingleInstance, lmLazy, TMsgServicePlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfMsgImpl.Create as IInterface;
  end;

finalization

  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
