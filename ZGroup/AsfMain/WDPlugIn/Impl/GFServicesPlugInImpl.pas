unit GFServicesPlugInImpl;

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  GFDataMngr_TLB;

type

  // GF 数据服务接口实现
  TGFServicesPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // GF 服务接口
    FGFDataManager: IGFDataManager;
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
  SecuBaseDataImpl;

{ TGFServicesPlugInImpl }

constructor TGFServicesPlugInImpl.Create;
begin
  inherited;

end;

destructor TGFServicesPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TGFServicesPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
//  FGFDataManager := IGFDataManager;
  FAppContext.RegisterInterface(IGFDataManager, FGFDataManager);
end;

procedure TGFServicesPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IGFDataManager);
  FGFDataManager := nil;
  FAppContext := nil;
end;

function TGFServicesPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TGFServicesPlugInImpl.SyncExecuteOperate;
begin
  if FGFDataManager = nil then Exit;

  FGFDataManager.StartService;
end;

procedure TGFServicesPlugInImpl.AsyncExecuteOperate;
begin

end;

end.
