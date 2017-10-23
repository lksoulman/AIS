unit ServiceExplorerImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Service Explorer Interface Implementation
// Author£º      lksoulman
// Date£º        2017-9-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  SyncAsyncImpl,
  ServiceExplorer,
  ServiceExplorerUI;

type

  // Service Explorer Interface Implementation
  TServiceExplorerImpl = class(TSyncAsyncImpl, IServiceExplorer)
  private
    // Service Explorer UI
    FServiceExplorerUI: TServiceExplorerUI;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize Resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing Resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Dependency Interface
    function Dependences: WideString; override;
  end;

implementation

{ TServiceExplorerImpl }

constructor TServiceExplorerImpl.Create;
begin
  inherited;
  FServiceExplorerUI := TServiceExplorerUI.Create(nil);
end;

destructor TServiceExplorerImpl.Destroy;
begin
  FServiceExplorerUI.Free;
  inherited;
end;

procedure TServiceExplorerImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  FServiceExplorerUI.Initialize(AContext);
end;

procedure TServiceExplorerImpl.UnInitialize;
begin
  FServiceExplorerUI.UnInitialize;
  inherited UnInitialize;
end;

procedure TServiceExplorerImpl.SyncBlockExecute;
begin
  FServiceExplorerUI.Show;
end;

procedure TServiceExplorerImpl.AsyncNoBlockExecute;
begin

end;

function TServiceExplorerImpl.Dependences: WideString;
begin

end;

end.
