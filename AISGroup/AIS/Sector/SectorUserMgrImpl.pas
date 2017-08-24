unit SectorUserMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils,
  SectorMgr,
  SyncAsync,
  AppContext,
  SectorUserMgr;

type

  TSectorUserMgrImpl = class(TSectorMgr, ISyncAsync, ISectorUserMgr)
  private
  protected
    // 同步加载用户板块数据
    procedure DoSyncLoadUserSectorData;
  public
    // 构造方法
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

    { ISectorUserMgr }

    // 读加锁
    procedure BeginRead; safecall;
    // 读解锁
    procedure EndRead; safecall;
    // 写加锁
    procedure BeginWrite; safecall;
    // 写解锁
    procedure EndWrite; safecall;
    // 获取根结点板块
    function GetRootSector: ISector; safecall;
  end;

implementation

{ TSectorUserMgrImpl }

constructor TSectorUserMgrImpl.Create;
begin
  inherited;

end;

destructor TSectorUserMgrImpl.Destroy;
begin

  inherited;
end;

procedure TSectorUserMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TSectorUserMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TSectorUserMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TSectorUserMgrImpl.SyncExecute;
begin
  DoSyncLoadUserSectorData;
end;

procedure TSectorUserMgrImpl.AsyncExecute;
begin

end;

procedure TSectorUserMgrImpl.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

procedure TSectorUserMgrImpl.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TSectorUserMgrImpl.BeginWrite;
begin
  FReadWriteLock.BeginWrite;
end;

procedure TSectorUserMgrImpl.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

function TSectorUserMgrImpl.GetRootSector: ISector;
begin
  Result := FRootSector;
end;

procedure TSectorUserMgrImpl.DoSyncLoadUserSectorData;
begin

end;

end.
