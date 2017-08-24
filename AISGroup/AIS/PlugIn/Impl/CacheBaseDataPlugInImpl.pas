unit CacheBaseDataPlugInImpl;

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
  CacheBaseData;

type

  // 实现基础数据插件
  TCacheBaseDataPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 证券数据接口
    FCacheBaseData: ICacheBaseData;
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
  CacheBaseDataImpl;

{ TCacheBaseDataPlugInImpl }

constructor TCacheBaseDataPlugInImpl.Create;
begin
  inherited;

end;

destructor TCacheBaseDataPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TCacheBaseDataPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FCacheBaseData := TCacheBaseDataImpl.Create as ICacheBaseData;
  (FCacheBaseData as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICacheBaseData, FCacheBaseData);
end;

procedure TCacheBaseDataPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICacheBaseData);
  (FCacheBaseData as ISyncAsync).UnInitialize;
  FCacheBaseData := nil;
  FAppContext := nil;
end;

function TCacheBaseDataPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FCacheBaseData = nil then Exit;

  Result := (FCacheBaseData as ISyncAsync).IsNeedSync;
end;

procedure TCacheBaseDataPlugInImpl.SyncExecuteOperate;
begin
  if FCacheBaseData = nil then Exit;

  (FCacheBaseData as ISyncAsync).SyncExecute;
end;

procedure TCacheBaseDataPlugInImpl.AsyncExecuteOperate;
begin
  if FCacheBaseData = nil then Exit;

  (FCacheBaseData as ISyncAsync).AsyncExecute;
end;

end.
