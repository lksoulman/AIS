unit LoginMgrPlugInImpl;

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
  LoginMgr,
  PlugInImpl,
  AppContext;

type

  TLoginMgrPlugInImpl = class(TPlugInImpl)
  private
    // Login management interface
    FLoginMgr: ILoginMgr;
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
  end;

implementation

uses
  SyncAsync,
  LoginMgrImpl;

{ TLoginMgrPlugInImpl }

constructor TLoginMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TLoginMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TLoginMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  FLoginMgr := TLoginMgrImpl.Create as ILoginMgr;
  (FLoginMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ILoginMgr, FLoginMgr);
end;

procedure TLoginMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ILoginMgr);
  (FLoginMgr as ISyncAsync).UnInitialize;
  FLoginMgr := nil;
  inherited UnInitialize;
end;

procedure TLoginMgrPlugInImpl.SyncBlockExecute;
begin
  if FLoginMgr = nil then Exit;

  (FLoginMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TLoginMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FLoginMgr = nil then Exit;

  (FLoginMgr as ISyncAsync).SyncBlockExecute;
end;

end.
