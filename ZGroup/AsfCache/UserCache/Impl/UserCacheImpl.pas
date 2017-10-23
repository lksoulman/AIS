unit UserCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º User Cache Interface Implementation
// Author£º      lksoulman
// Date£º        2017-8-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CacheImpl,
  UserCache,
  SyncAsync,
  CacheType,
  AppContext,
  WNDataSetInf;

type

  // User Cache Interface Implementation
  TUserCacheImpl = class(TCacheImpl, IUserCache)
  private
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
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

    { IUserCache }

    //  Synchronous query data
    function SyncQuery(ASql: WideString): IWNDataSet; safecall;
    // Asynchronous query data
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

uses
  Cfg;

{ TUserCacheImpl }

constructor TUserCacheImpl.Create;
begin
  inherited;

end;

destructor TUserCacheImpl.Destroy;
begin

  inherited;
end;

procedure TUserCacheImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure TUserCacheImpl.UnInitialize;
begin

  inherited UnInitialize;
end;

procedure TUserCacheImpl.SyncBlockExecute;
begin
  if FAppContext.GetCfg <> nil then begin
    FCacheDataAdapter.DataBaseName := (FAppContext.GetCfg as ICfg).GetUserCachePath + 'UserDB';
    FCfgFile := FAppContext.GetCfg.GetCfgPath + 'Cache/UserCfg.xml';
    LoadTables;
    InitConnCache;
    InitSysTable;
    InitDataTables;
    DoSyncUpdateData;
  end;
end;

procedure TUserCacheImpl.AsyncNoBlockExecute;
begin

end;

function TUserCacheImpl.Dependences: WideString;
begin

end;

function TUserCacheImpl.SyncQuery(ASql: WideString): IWNDataSet;
begin
  Result := FCacheDataAdapter.QuerySql(ASql);
end;

procedure TUserCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
