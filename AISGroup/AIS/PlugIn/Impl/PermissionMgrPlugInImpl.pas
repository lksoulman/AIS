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
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 权限管理接口
    FPermissionMgr: IPermissionMgr;
  protected
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IPlugIn }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); override;
    // 释放不需要的资源
    procedure UnInitialize; override;
    // 是不是需要同步加载操作
    function IsNeedSync: WordBool; override;
    // 同步实现
    procedure SyncExecuteOperate; override;
    // 异步实现操作
    procedure AsyncExecuteOperate; override;
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

function TPermissionMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FPermissionMgr = nil then Exit;

  Result := (FPermissionMgr as ISyncAsync).IsNeedSync;
end;

procedure TPermissionMgrPlugInImpl.SyncExecuteOperate;
begin
  if FPermissionMgr = nil then Exit;

  (FPermissionMgr as ISyncAsync).SyncExecute;
end;

procedure TPermissionMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FPermissionMgr = nil then Exit;

  (FPermissionMgr as ISyncAsync).AsyncExecute;
end;

end.
