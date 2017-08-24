unit SectorUserMgrPlugInImpl;

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
  SectorUserMgr;

type

  // 用户板块管理接口插件
  TSectorUserMgrPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 用户板块管理接口
    FSectorUserMgr: ISectorUserMgr;
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
  SectorUserMgrImpl;

{ TSectorUserMgrPlugInImpl }

constructor TSectorUserMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TSectorUserMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TSectorUserMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FSectorUserMgr := TSectorUserMgrImpl.Create as ISectorUserMgr;
  (FSectorUserMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ISectorUserMgr, FSectorUserMgr);
end;

procedure TSectorUserMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ISectorUserMgr);
  (FSectorUserMgr as ISyncAsync).UnInitialize;
  FSectorUserMgr := nil;
  FAppContext := nil;
end;

function TSectorUserMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TSectorUserMgrPlugInImpl.SyncExecuteOperate;
begin
  if FSectorUserMgr = nil then Exit;

  (FSectorUserMgr as ISyncAsync).SyncExecute;
end;

procedure TSectorUserMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FSectorUserMgr = nil then Exit;

  (FSectorUserMgr as ISyncAsync).AsyncExecute;
end;

end.
