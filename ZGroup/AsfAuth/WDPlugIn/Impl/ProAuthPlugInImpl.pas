unit ProAuthPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Product Authority PlugIn Implementation
// Author£º      lksoulman
// Date£º        2017-8-30
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface
uses
  ProAuth,
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext;

type

  // Product Authority PlugIn Implementation
  TProAuthPlugInImpl = class(TPlugInImpl)
  private
    // Product Authority
    FProAuth: IProAuth;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
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
  ProAuthImpl;

{ TProAuthPlugInImpl }

constructor TProAuthPlugInImpl.Create;
begin
  inherited;
  FProAuth := TProAuthImpl.Create as IProAuth;
end;

destructor TProAuthPlugInImpl.Destroy;
begin
  FProAuth := nil;
  inherited;
end;

procedure TProAuthPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FProAuth as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IProAuth, FProAuth);
end;

procedure TProAuthPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IProAuth);
  (FProAuth as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TProAuthPlugInImpl.SyncBlockExecute;
begin
  if FProAuth = nil then Exit;

  (FProAuth as ISyncAsync).SyncBlockExecute;
end;

procedure TProAuthPlugInImpl.AsyncNoBlockExecute;
begin
  if FProAuth = nil then Exit;

  (FProAuth as ISyncAsync).AsyncNoBlockExecute;
end;

function TProAuthPlugInImpl.Dependences: WideString;
begin
  Result := (FProAuth as ISyncAsync).Dependences;
end;

end.
