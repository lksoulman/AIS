unit UpdateExplorerPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Explorer PlugIn Implementation
// Author£º      lksoulman
// Date£º        2017-10-14
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
  UpdateExplorer;

type

  // Update Explorer PlugIn Implementation
  TUpdateExplorerPlugInImpl = class(TPlugInImpl)
  private
    // UpdateExplorer
    FUpdateExplorer: IUpdateExplorer;
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
  UpdateExplorerImpl;

{ TUpdateExplorerPlugInImpl }

constructor TUpdateExplorerPlugInImpl.Create;
begin
  inherited;
  FUpdateExplorer := TUpdateExplorerImpl.Create as IUpdateExplorer;
end;

destructor TUpdateExplorerPlugInImpl.Destroy;
begin
  FUpdateExplorer := nil;
  inherited;
end;

procedure TUpdateExplorerPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FUpdateExplorer as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IUpdateExplorer, FUpdateExplorer);
end;

procedure TUpdateExplorerPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IUpdateExplorer);
  (FUpdateExplorer as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TUpdateExplorerPlugInImpl.SyncBlockExecute;
begin
  if FUpdateExplorer = nil then Exit;

  (FUpdateExplorer as ISyncAsync).SyncBlockExecute;
end;

procedure TUpdateExplorerPlugInImpl.AsyncNoBlockExecute;
begin
  if FUpdateExplorer = nil then Exit;

  (FUpdateExplorer as ISyncAsync).AsyncNoBlockExecute;
end;

function TUpdateExplorerPlugInImpl.Dependences: WideString;
begin
  Result := (FUpdateExplorer as ISyncAsync).Dependences;
end;

end.
