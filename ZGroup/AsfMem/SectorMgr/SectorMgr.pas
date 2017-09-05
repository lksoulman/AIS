unit SectorMgr;

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
  AppContext,
  CommonLock,
  SyncAsyncImpl;

type

  // 板块管理
  TSectorMgr = class(TSyncAsyncImpl)
  private
  protected
    // 用户根结点板块
    FUserRootSector: ISector;
    // 读写锁
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize Resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing Resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Dependency Interface
    function Dependences: WideString; override;
  end;

implementation

uses
  SectorImpl;

{ TSectorMgr }

constructor TSectorMgr.Create;
begin
  inherited;
  FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FUserRootSector := TSectorImpl.Create as ISector;
end;

destructor TSectorMgr.Destroy;
begin
  FUserRootSector := nil;
  FReadWriteLock.Free;
  inherited;
end;

procedure TSectorMgr.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
end;

procedure TSectorMgr.UnInitialize;
begin
  inherited UnInitialize;
end;

procedure TSectorMgr.SyncBlockExecute;
begin

end;

procedure TSectorMgr.AsyncNoBlockExecute;
begin

end;

function TSectorMgr.Dependences: WideString;
begin
  Result := '';
end;

end.
