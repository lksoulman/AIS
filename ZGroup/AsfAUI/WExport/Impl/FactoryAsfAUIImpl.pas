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
  RenderGDI,
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

    { IWFactory }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
  end;

var
  // Global factory
  G_WFactory: IInterface;
  // Global
  G_RenderGDI: TRenderGDI;

implementation

uses
  PlugIn,
  AppContext,
  MainFrameUIPlugInImpl;

{ TFactoryAsfAUIImpl }

constructor TFactoryAsfAUIImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfAUIImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfAUIImpl.Initialize(AContext: IInterface);
begin
  G_RenderGDI.Initialize(AContext as IAppContext);
  inherited Initialize(AContext);
end;

procedure TFactoryAsfAUIImpl.UnInitialize;
begin
  inherited UnInitialize;
  G_RenderGDI.UnInitialize;
end;

procedure TFactoryAsfAUIImpl.DoRegisterPlugIns;
begin
  DoRegisterPlugIn(PLUGIN_ID_MAINFRAMEUI, itSingleInstance, lmLazy, TMainFrameUIPlugInImpl);
end;

initialization

  // Create global factory
  if G_WFactory = nil then begin
    G_WFactory := TFactoryAsfAUIImpl.Create as IInterface;
  end;

  if G_RenderGDI = nil then begin
    G_RenderGDI := TRenderGDI.Create;
  end;

finalization

  if G_RenderGDI <> nil then begin
    G_RenderGDI.Free;
    G_RenderGDI := nil;
  end;
  // Free global factory interface
  if G_WFactory <> nil then begin
    G_WFactory := nil;
  end;

end.
