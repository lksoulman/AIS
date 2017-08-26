unit KeyFairyMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-24
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  AppContext,
  CommonLock,
  KeyFairyMgr,
  KeyFairyPool,
  CommonRefCounter;

type

  TKeyFairyMgrImpl = class(TAutoInterfacedObject, ISyncAsync, IKeyFairyMgr)
  private
    // 线程锁
    FLock: TCSLock;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 对象池
    FKeyFairyPool: TKeyFairyPool;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IKeyFairyMgr }

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
  end;

implementation

{ TKeyFairyMgrImpl }

constructor TKeyFairyMgrImpl.Create;
begin
  inherited;
  FLock := TCSLock.Create;
  FKeyFairyPool := TKeyFairyPool.Create;
end;

destructor TKeyFairyMgrImpl.Destroy;
begin
  FKeyFairyPool.Free;
  FLock.Free;
  inherited;
end;

procedure TKeyFairyMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TKeyFairyMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TKeyFairyMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TKeyFairyMgrImpl.SyncExecute;
begin
  
end;

procedure TKeyFairyMgrImpl.AsyncExecute;
begin

end;

end.
