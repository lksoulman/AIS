unit ServiceAssetPlugInImpl;

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
  ServiceAsset;

type

  // 资产GF数据服务插件
  TServiceAssetPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 资产服务接口
    FServiceAsset: IServiceAsset;
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
  ServiceAssetImpl;

{ TServiceAssetPlugInImpl }

constructor TServiceAssetPlugInImpl.Create;
begin
  inherited;

end;

destructor TServiceAssetPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TServiceAssetPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FServiceAsset := TServiceAssetImpl.Create as IServiceAsset;
  (FServiceAsset as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IServiceAsset, FServiceAsset);
end;

procedure TServiceAssetPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IServiceAsset);
  (FServiceAsset as ISyncAsync).UnInitialize;
  FServiceAsset := nil;
  FAppContext := nil;
end;

function TServiceAssetPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TServiceAssetPlugInImpl.SyncExecuteOperate;
begin

end;

procedure TServiceAssetPlugInImpl.AsyncExecuteOperate;
begin

end;

end.

