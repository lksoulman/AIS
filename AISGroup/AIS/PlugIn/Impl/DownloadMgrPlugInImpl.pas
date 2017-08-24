unit DownloadMgrPlugInImpl;

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
  DownloadMgr;

type

  TDownloadMgrPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 登录窗口接口
    FDownloadMgr: IDownloadMgr;
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
  DownloadMgrImpl;

{ TDownloadMgrPlugInImpl }

constructor TDownloadMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TDownloadMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TDownloadMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FDownloadMgr := TDownloadMgrImpl.Create as IDownloadMgr;
  (FDownloadMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IDownloadMgr, FDownloadMgr);
end;

procedure TDownloadMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IDownloadMgr);
  (FDownloadMgr as ISyncAsync).UnInitialize;
  FDownloadMgr := nil;
  FAppContext := nil;
end;

function TDownloadMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FDownloadMgr = nil then Exit;

  Result := (FDownloadMgr as ISyncAsync).IsNeedSync;
end;

procedure TDownloadMgrPlugInImpl.SyncExecuteOperate;
begin
  if FDownloadMgr = nil then Exit;

  (FDownloadMgr as ISyncAsync).SyncExecute;
end;

procedure TDownloadMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FDownloadMgr = nil then Exit;

  (FDownloadMgr as ISyncAsync).AsyncExecute;
end;

end.
