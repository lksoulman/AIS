unit ServiceBasePlugInImpl;

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
  ServiceBase;

type

  // 资产GF数据服务插件
  TServiceBasePlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 资产服务接口
    FServiceBase: IServiceBase;
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
  ServiceBaseImpl;

{ TServiceBasePlugInImpl }

constructor TServiceBasePlugInImpl.Create;
begin
  inherited;

end;

destructor TServiceBasePlugInImpl.Destroy;
begin

  inherited;
end;

procedure TServiceBasePlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FServiceBase := TServiceBaseImpl.Create as IServiceBase;
  (FServiceBase as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IServiceBase, FServiceBase);
end;

procedure TServiceBasePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IServiceBase);
  (FServiceBase as ISyncAsync).UnInitialize;
  FServiceBase := nil;
  FAppContext := nil;
end;

function TServiceBasePlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TServiceBasePlugInImpl.SyncExecuteOperate;
begin

end;

procedure TServiceBasePlugInImpl.AsyncExecuteOperate;
begin

end;

end.
