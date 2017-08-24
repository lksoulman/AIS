unit UserBehaviorPlugInImpl;

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
  UserBehavior;

type

  TUserBehaviorPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 用户行为接口上传接口
    FUserBehavior: IUserBehavior;
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
  UserBehaviorImpl;

{ TUserBehaviorPlugInImpl }

constructor TUserBehaviorPlugInImpl.Create;
begin
  inherited;

end;

destructor TUserBehaviorPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TUserBehaviorPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FUserBehavior := TUserBehaviorImpl.Create as IUserBehavior;
  (FUserBehavior as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IUserBehavior, FUserBehavior);
end;

procedure TUserBehaviorPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IUserBehavior);
  (FUserBehavior as ISyncAsync).UnInitialize;
  FUserBehavior := nil;
  FAppContext := nil;
end;

function TUserBehaviorPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FUserBehavior = nil then Exit;

  Result := (FUserBehavior as ISyncAsync).IsNeedSync;
end;

procedure TUserBehaviorPlugInImpl.SyncExecuteOperate;
begin
  if FUserBehavior = nil then Exit;

  (FUserBehavior as ISyncAsync).SyncExecute;
end;

procedure TUserBehaviorPlugInImpl.AsyncExecuteOperate;
begin
  if FUserBehavior = nil then Exit;

  (FUserBehavior as ISyncAsync).AsyncExecute;
end;

end.
