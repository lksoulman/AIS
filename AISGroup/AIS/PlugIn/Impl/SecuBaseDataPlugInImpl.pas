unit SecuBaseDataPlugInImpl;

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
  SecuBaseData;

type

  // 实现主表基础数据插件
  TSecuBaseDataPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 证券数据接口
    FSecuBaseData: ISecuBaseData;
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

{ TSecuBaseDataPlugInImpl }

constructor TSecuBaseDataPlugInImpl.Create;
begin
  inherited;

end;

destructor TSecuBaseDataPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TSecuBaseDataPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FSecuBaseData := TSecuBaseDataImpl.Create as ISecuBaseData;
  (FSecuBaseData as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ISecuBaseData, FSecuBaseData);
end;

procedure TSecuBaseDataPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ISecuBaseData);
  (FSecuBaseData as ISyncAsync).UnInitialize;
  FSecuBaseData := nil;
  FAppContext := nil;
end;

function TSecuBaseDataPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
  if FSecuBaseData = nil then Exit;

  Result := (FSecuBaseData as ISyncAsync).IsNeedSync;
end;

procedure TSecuBaseDataPlugInImpl.SyncExecuteOperate;
begin
  if FSecuBaseData = nil then Exit;

  (FSecuBaseData as ISyncAsync).SyncExecute;
end;

procedure TSecuBaseDataPlugInImpl.AsyncExecuteOperate;
begin
  if FSecuBaseData = nil then Exit;

  (FSecuBaseData as ISyncAsync).AsyncExecute;
end;

end.
