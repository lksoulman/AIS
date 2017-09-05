unit PermissionMgrPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-20
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface
uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  PermissionMgr;

type

  TPermissionMgrPlugInImpl = class(TPlugInImpl)
  private
    // 权限管理接口
    FPermissionMgr: IPermissionMgr;
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
  PermissionMgrImpl;

{ TPermissionMgrPlugInImpl }

constructor TPermissionMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TPermissionMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TPermissionMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FPermissionMgr := TPermissionMgrImpl.Create as IPermissionMgr;
  (FPermissionMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IPermissionMgr, FPermissionMgr);
end;

procedure TPermissionMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IPermissionMgr);
  (FPermissionMgr as ISyncAsync).UnInitialize;
  FPermissionMgr := nil;
  FAppContext := nil;
end;

procedure TPermissionMgrPlugInImpl.SyncBlockExecute;
begin
  if FPermissionMgr = nil then Exit;

  (FPermissionMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TPermissionMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FPermissionMgr = nil then Exit;

  (FPermissionMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function TPermissionMgrPlugInImpl.Dependences: WideString;
begin
  Result := (FPermissionMgr as ISyncAsync).Dependences;
end;

end.
