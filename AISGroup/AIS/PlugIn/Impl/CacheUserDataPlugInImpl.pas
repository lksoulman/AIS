unit CacheUserDataPlugInImpl;

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
  CacheUserData;

type

  // 用户缓存数据插件
  TCacheUserDataPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 用户缓冲数据接口
    FCacheUserData: ICacheUserData;
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
  CacheUserDataImpl;

{ TCacheUserDataPlugInImpl }

constructor TCacheUserDataPlugInImpl.Create;
begin
  inherited;

end;

destructor TCacheUserDataPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TCacheUserDataPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FCacheUserData := TCacheUserDataImpl.Create as ICacheUserData;
  (FCacheUserData as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICacheUserData, FCacheUserData);
end;

procedure TCacheUserDataPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICacheUserData);
  (FCacheUserData as ISyncAsync).UnInitialize;
  FCacheUserData := nil;
  FAppContext := nil;
end;

function TCacheUserDataPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
  if FCacheUserData = nil then Exit;

  Result := (FCacheUserData as ISyncAsync).IsNeedSync;
end;

procedure TCacheUserDataPlugInImpl.SyncExecuteOperate;
begin
  if FCacheUserData = nil then Exit;

  (FCacheUserData as ISyncAsync).SyncExecute;
end;

procedure TCacheUserDataPlugInImpl.AsyncExecuteOperate;
begin
  if FCacheUserData = nil then Exit;

  (FCacheUserData as ISyncAsync).AsyncExecute;
end;

end.
