unit UserSectorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： User Sector Manager Interface implementation
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
  UserSectorMgr,
  SectorMgrImpl;

type

  // User Sector Manager Interface implementation
  TUserSectorMgrImpl = class(TSectorMgrImpl, IUserSectorMgr)
  private
  protected
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;

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

{ TUserSectorMgrImpl }

constructor TUserSectorMgrImpl.Create;
begin
  inherited;

end;

destructor TUserSectorMgrImpl.Destroy;
begin

  inherited;
end;

procedure TUserSectorMgrImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
end;

procedure TUserSectorMgrImpl.UnInitialize;
begin
  inherited UnInitialize;
end;

procedure TUserSectorMgrImpl.SyncBlockExecute;
begin

end;

procedure TUserSectorMgrImpl.AsyncNoBlockExecute;
begin

end;

function TUserSectorMgrImpl.Dependences: WideString;
begin

end;

procedure TUserSectorMgrImpl.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

procedure TUserSectorMgrImpl.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TUserSectorMgrImpl.BeginWrite;
begin
  FReadWriteLock.BeginWrite;
end;

procedure TUserSectorMgrImpl.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

function TUserSectorMgrImpl.GetRootSector: ISector;
begin
  Result := FRootSector;
end;

end.
