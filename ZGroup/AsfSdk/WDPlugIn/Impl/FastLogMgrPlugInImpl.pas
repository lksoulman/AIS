unit FastLogMgrPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
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
  FastLogMgr;

type

  // FastLogMgr PlugIn implementation
  TFastLogMgrPlugInImpl = class(TPlugInImpl)
  private
    // log managenent interface
    FFastLogMgr: IFastLogMgr;
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

    property FastLogMgr: IFastLogMgr read FFastLogMgr;
  end;

implementation

uses
  SyncAsync,
  FastLogMgrImpl;

{ TFastLogMgrPlugInImpl }

constructor TFastLogMgrPlugInImpl.Create;
begin
  inherited Create;
  FFastLogMgr := TFastLogMgrImpl.Create as IFastLogMgr;

end;

destructor TFastLogMgrPlugInImpl.Destroy;
begin

  FFastLogMgr := nil;
  inherited;
end;

procedure TFastLogMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FFastLogMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IFastLogMgr, FFastLogMgr);
end;

procedure TFastLogMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IFastLogMgr);
  (FFastLogMgr as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TFastLogMgrPlugInImpl.SyncBlockExecute;
begin
  if FFastLogMgr = nil then Exit;

  (FFastLogMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TFastLogMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FFastLogMgr = nil then Exit;

  (FFastLogMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function TFastLogMgrPlugInImpl.Dependences: WideString;
begin
  Result := '';
  if FFastLogMgr = nil then Exit;

  Result := (FFastLogMgr as ISyncAsync).Dependences;
end;

end.
