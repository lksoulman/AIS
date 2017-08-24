unit ConfigPlugInImpl;

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
  Config,
  PlugInImpl,
  AppContext;

type

  // 配置接口插件
  TConfigPlugInImpl = class(TPlugInImpl)
  private
    // 配置接口
    FConfig: IConfig;
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
  ConfigImpl;

{ TConfigPlugInImpl }

constructor TConfigPlugInImpl.Create;
begin
  inherited;

end;

destructor TConfigPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TConfigPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FConfig := TConfigImpl.Create as IConfig;
  (FConfig as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IConfig, FConfig);
end;

procedure TConfigPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IConfig);
  (FConfig as ISyncAsync).UnInitialize;
  FConfig := nil;
  FAppContext := nil;
end;

function TConfigPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TConfigPlugInImpl.SyncExecuteOperate;
begin
  if FConfig = nil then Exit;
  
  (FConfig as ISyncAsync).SyncExecute;
end;

procedure TConfigPlugInImpl.AsyncExecuteOperate;
begin
  if FConfig = nil then Exit;

  (FConfig as ISyncAsync).AsyncExecute;
end;

end.
