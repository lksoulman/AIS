unit UserAssetCacheImpl;

interface

uses
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  CacheImpl,
  CacheType,
  AppContext,
  WNDataSetInf,
  UserAssetCache;

type

  // User asset cache interface implementation
  TUserAssetCacheImpl = class(TCacheImpl, IUserAssetCache)
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

    { IUserAssetCache }

    //  Synchronous query data
    function SyncQuery(ASql: WideString): IWNDataSet; safecall;
    // Asynchronous query data
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;


implementation

uses
  Config;

{ TUserAssetCacheImpl }

constructor TUserAssetCacheImpl.Create;
begin

end;

destructor TUserAssetCacheImpl.Destroy;
begin

  inherited;
end;

procedure TUserAssetCacheImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure TUserAssetCacheImpl.UnInitialize;
begin

  inherited UnInitialize;
end;

procedure TUserAssetCacheImpl.SyncBlockExecute;
begin
  if FAppContext.GetConfig <> nil then begin
    FCacheDataAdapter.DataBaseName := (FAppContext.GetConfig as IConfig).GetUserCachePath + 'UserAssetDB';
    FCfgFile := (FAppContext.GetConfig as IConfig).GetCfgPath + 'Cache\UserAssetCfg.xml';
    LoadTables;
    InitConnCache;
    InitSysTable;
    DoSyncUpdateData;
  end;
end;

procedure TUserAssetCacheImpl.AsyncNoBlockExecute;
begin

end;

function TUserAssetCacheImpl.Dependences: WideString;
begin

end;

function TUserAssetCacheImpl.SyncQuery(ASql: WideString): IWNDataSet;
begin
  Result := FCacheDataAdapter.QuerySql(ASql);
end;

procedure TUserAssetCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
