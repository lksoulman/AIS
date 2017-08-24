unit LoginMgrPlugInImpl;

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
  LoginMgr,
  PlugInImpl,
  AppContext;

type

  TLoginMgrPlugInImpl = class(TPlugInImpl)
  private
    // 登录窗口接口
    FLoginMgr: ILoginMgr;
    // 应用程序上下文接口
    FAppContext: IAppContext;
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
  FAppContext := AContext;
  FLoginMgr := TLoginMgrImpl.Create as ILoginMgr;
  (FLoginMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ILoginMgr, FLoginMgr);
end;

procedure TLoginMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ILoginMgr);
  (FLoginMgr as ISyncAsync).UnInitialize;
  FLoginMgr := nil;
  FAppContext := nil;
end;

function TLoginMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FLoginMgr = nil then Exit;

  Result := (FLoginMgr as ISyncAsync).IsNeedSync;
end;

procedure TLoginMgrPlugInImpl.SyncExecuteOperate;
begin
  if FLoginMgr = nil then Exit;

  (FLoginMgr as ISyncAsync).SyncExecute;
end;

procedure TLoginMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FLoginMgr = nil then Exit;

  (FLoginMgr as ISyncAsync).AsyncExecute;
end;

end.
