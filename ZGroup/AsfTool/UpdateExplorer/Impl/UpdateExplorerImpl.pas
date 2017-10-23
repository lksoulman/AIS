unit UpdateExplorerImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Service Explorer Interface Implementation
// Author£º      lksoulman
// Date£º        2017-10-12
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
  UpdateExplorer,
  UpdateExplorerUI;

type

  // Service Explorer Interface Implementation
  TUpdateExplorerImpl = class(TSyncAsyncImpl, IUpdateExplorer)
  private
    // Update Explorer UI
    FUpdateExplorerUI: TUpdateExplorerUI;
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

{ TUpdateExplorerImpl }

constructor TUpdateExplorerImpl.Create;
begin
  inherited;
  FUpdateExplorerUI := TUpdateExplorerUI.Create(nil);
end;

destructor TUpdateExplorerImpl.Destroy;
begin
  FUpdateExplorerUI.Free;
  inherited;
end;

procedure TUpdateExplorerImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
//  FUpdateExplorerUI.Initialize(AContext);
end;

procedure TUpdateExplorerImpl.UnInitialize;
begin
//  FUpdateExplorerUI.UnInitialize;
  inherited UnInitialize;
end;

procedure TUpdateExplorerImpl.SyncBlockExecute;
begin
  FUpdateExplorerUI.Show;
end;

procedure TUpdateExplorerImpl.AsyncNoBlockExecute;
begin

end;

function TUpdateExplorerImpl.Dependences: WideString;
begin

end;

end.
