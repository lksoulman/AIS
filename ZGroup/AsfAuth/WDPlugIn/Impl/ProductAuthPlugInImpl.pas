unit ProductAuthPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Product Authority PlugIn implementation
// Author£º      lksoulman
// Date£º        2017-8-30
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface
uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  ProductAuth;

type

  // Product Authority PlugIn implementation
  TProductAuthPlugInImpl = class(TPlugInImpl)
  private
    // Product Authority interface
    FProductAuth: IProductAuth;
  protected
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { IPlugIn }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Get dependency
    function Dependences: WideString; override;
  end;

implementation

uses
  SyncAsync,
  ProductAuthImpl;

{ TProductAuthPlugInImpl }

constructor TProductAuthPlugInImpl.Create;
begin
  inherited;
  FProductAuth := TProductAuthImpl.Create as IProductAuth;
end;

destructor TProductAuthPlugInImpl.Destroy;
begin
  FProductAuth := nil;
  inherited;
end;

procedure TProductAuthPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FProductAuth as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IProductAuth, FProductAuth);
end;

procedure TProductAuthPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IProductAuth);
  (FProductAuth as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TProductAuthPlugInImpl.SyncBlockExecute;
begin
  if FProductAuth = nil then Exit;

  (FProductAuth as ISyncAsync).SyncBlockExecute;
end;

procedure TProductAuthPlugInImpl.AsyncNoBlockExecute;
begin
  if FProductAuth = nil then Exit;

  (FProductAuth as ISyncAsync).AsyncNoBlockExecute;
end;

function TProductAuthPlugInImpl.Dependences: WideString;
begin
  Result := (FProductAuth as ISyncAsync).Dependences;
end;

end.
