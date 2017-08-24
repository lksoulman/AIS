unit MsgServicesPlugInImpl;

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
  MsgServices;

type

  // 消息服务接口插件
  TMsgServicesPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 证券数据接口
    FMsgServices: IMsgServices;
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
  MsgServicesImpl;

{ TMsgServicesPlugInImpl }

constructor TMsgServicesPlugInImpl.Create;
begin
  inherited;

end;

destructor TMsgServicesPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TMsgServicesPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FMsgServices := TMsgServicesImpl.Create as IMsgServices;
  (FMsgServices as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IMsgServices, FMsgServices);
end;

procedure TMsgServicesPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IMsgServices);
  (FMsgServices as ISyncAsync).UnInitialize;
  FMsgServices := nil;
  FAppContext := nil;
end;

function TMsgServicesPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
  if FMsgServices = nil then Exit;

  Result := (FMsgServices as ISyncAsync).IsNeedSync;
end;

procedure TMsgServicesPlugInImpl.SyncExecuteOperate;
begin
  if FMsgServices = nil then Exit;

  (FMsgServices as ISyncAsync).SyncExecute;
end;

procedure TMsgServicesPlugInImpl.AsyncExecuteOperate;
begin
  if FMsgServices = nil then Exit;

  (FMsgServices as ISyncAsync).AsyncExecute;
end;

end.
