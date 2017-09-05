unit SectorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Sector Manager implementation
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
  TSectorMgrImpl = class(TSyncAsyncImpl)
  private
  protected
    // 用户根结点板块
    FRootSector: ISector;
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

{ TSectorMgrImpl }

constructor TSectorMgrImpl.Create;
begin
  inherited;
  FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FRootSector := TSectorImpl.Create as ISector;
end;

destructor TSectorMgrImpl.Destroy;
begin
  FRootSector := nil;
  FReadWriteLock.Free;
  inherited;
end;

procedure TSectorMgrImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
end;

procedure TSectorMgrImpl.UnInitialize;
begin
  inherited UnInitialize;
end;

procedure TSectorMgrImpl.SyncBlockExecute;
begin

end;

procedure TSectorMgrImpl.AsyncNoBlockExecute;
begin

end;

function TSectorMgrImpl.Dependences: WideString;
begin
  Result := '';
end;

end.
