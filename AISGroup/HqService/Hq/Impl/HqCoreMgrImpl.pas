unit HqCoreMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HqCoreMgr,
  SyncAsync,
  AppContext,
  HqDataCenter,
  HqIndicatorMgr,
  CommonRefCounter,
  HqSubcribeAdapter;

type

  // 行情核心管理器
  THqCoreMgrImpl = class(TAutoInterfacedObject, ISyncAsync, IHqCoreMgr)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 数据中心接口
    FHqDataCenter: IHqDataCenter;
    // 指标管理接口
    FHqIndicatorMgr: IHqIndicatorMgr;
    // 订阅适配器接口
    FHqSubcribeAdapter: IHqSubcribeAdapter;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { ISyncAsync }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; safecall;
    // 同步执行方法
    procedure SyncExecute; safecall;
    // 异步执行方法
    procedure AsyncExecute; safecall;

    { IHqCoreMgr }

    // 获取数据中心接口
    function GetHqDataCenter: IHqDataCenter; safecall;
    // 获取指标管理接口
    function GetHqIndicatorMgr: IHqIndicatorMgr; safecall;
    // 获取订阅适配器接口
    function GetHqSubcribeAdapter: IHqSubcribeAdapter; safecall;
  end;

implementation

{ THqCoreMgrImpl }

constructor THqCoreMgrImpl.Create;
begin
  inherited;

end;

destructor THqCoreMgrImpl.Destroy;
begin

  inherited;
end;

procedure THqCoreMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqCoreMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function THqCoreMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure THqCoreMgrImpl.SyncExecute;
begin

end;

procedure THqCoreMgrImpl.AsyncExecute;
begin

end;

function THqCoreMgrImpl.GetHqDataCenter: IHqDataCenter;
begin
  Result := FHqDataCenter;
end;

function THqCoreMgrImpl.GetHqIndicatorMgr: IHqIndicatorMgr;
begin
  Result := FHqIndicatorMgr;
end;

function THqCoreMgrImpl.GetHqSubcribeAdapter: IHqSubcribeAdapter;
begin
  Result := FHqSubcribeAdapter;
end;

end.
