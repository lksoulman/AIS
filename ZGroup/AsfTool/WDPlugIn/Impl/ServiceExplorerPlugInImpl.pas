unit ServiceExplorerPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Service Explorer PlugIn Implementation
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
  ServiceExplorer;

type

  // Service Explorer PlugIn Implementation
  TServiceExplorerPlugInImpl = class(TPlugInImpl)
  private
    // ServiceExplorer
    FServiceExplorer: IServiceExplorer;
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
  ServiceExplorerImpl;

{ TServiceExplorerPlugInImpl }

constructor TServiceExplorerPlugInImpl.Create;
begin
  inherited;
  FServiceExplorer := TServiceExplorerImpl.Create as IServiceExplorer;
end;

destructor TServiceExplorerPlugInImpl.Destroy;
begin
  FServiceExplorer := nil;
  inherited;
end;

procedure TServiceExplorerPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FServiceExplorer as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IServiceExplorer, FServiceExplorer);
end;

procedure TServiceExplorerPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IServiceExplorer);
  (FServiceExplorer as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TServiceExplorerPlugInImpl.SyncBlockExecute;
begin
  if FServiceExplorer = nil then Exit;

  (FServiceExplorer as ISyncAsync).SyncBlockExecute;
end;

procedure TServiceExplorerPlugInImpl.AsyncNoBlockExecute;
begin
  if FServiceExplorer = nil then Exit;

  (FServiceExplorer as ISyncAsync).AsyncNoBlockExecute;
end;

function TServiceExplorerPlugInImpl.Dependences: WideString;
begin
  Result := (FServiceExplorer as ISyncAsync).Dependences;
end;

end.
