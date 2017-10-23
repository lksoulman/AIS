unit KeyFairyMgrPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeyFairyMgr PlugIn Inteface Implementation
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
  PlugInImpl,
  AppContext,
  KeyFairyMgr;

type

  // KeyFairyMgr PlugIn Inteface Implementation
  TKeyFairyMgrPlugInImpl = class(TPlugInImpl)
  private
    // KeyFairyMgr
    FKeyFairyMgr: IKeyFairyMgr;
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
  KeyFairyMgrImpl;

{ TKeyFairyMgrPlugInImpl }

constructor TKeyFairyMgrPlugInImpl.Create;
begin
  inherited;
  FKeyFairyMgr := TKeyFairyMgrImpl.Create as IKeyFairyMgr;
end;

destructor TKeyFairyMgrPlugInImpl.Destroy;
begin
  FKeyFairyMgr := nil;
  inherited;
end;

procedure TKeyFairyMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FKeyFairyMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IKeyFairyMgr, FKeyFairyMgr);
end;

procedure TKeyFairyMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IKeyFairyMgr);
  (FKeyFairyMgr as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TKeyFairyMgrPlugInImpl.SyncBlockExecute;
begin
  if FKeyFairyMgr = nil then Exit;

  (FKeyFairyMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TKeyFairyMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FKeyFairyMgr = nil then Exit;

  (FKeyFairyMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function TKeyFairyMgrPlugInImpl.Dependences: WideString;
begin
  Result := (FKeyFairyMgr as ISyncAsync).Dependences;
end;

end.
