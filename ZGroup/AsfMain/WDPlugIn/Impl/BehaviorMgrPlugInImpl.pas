unit BehaviorMgrPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-20
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
  BehaviorMgr;

type

  TBehaviorMgrPlugInImpl = class(TPlugInImpl)
  private
    // Behavior management interface
    FBehaviorMgr: IBehaviorMgr;
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
  BehaviorMgrImpl;

{ TBehaviorMgrPlugInImpl }

constructor TBehaviorMgrPlugInImpl.Create;
begin
  inherited;
  FBehaviorMgr := TBehaviorMgrImpl.Create as IBehaviorMgr;
end;

destructor TBehaviorMgrPlugInImpl.Destroy;
begin
  FBehaviorMgr := nil;
  inherited;
end;

procedure TBehaviorMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FBehaviorMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IBehaviorMgr, FBehaviorMgr);
end;

procedure TBehaviorMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IBehaviorMgr);
  (FBehaviorMgr as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TBehaviorMgrPlugInImpl.SyncBlockExecute;
begin
  if FBehaviorMgr = nil then Exit;

  (FBehaviorMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TBehaviorMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FBehaviorMgr = nil then Exit;

  (FBehaviorMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function TBehaviorMgrPlugInImpl.Dependences: WideString;
begin

end;

end.
