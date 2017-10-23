unit BaseCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Base Cache Interface Implementation
// Author£º      lksoulman
// Date£º        2017-8-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  CacheGF,
  Windows,
  Classes,
  SysUtils,
  BaseCache,
  CacheImpl,
  GFDataSet,
  CacheType,
  AppContext,
  CacheTable,
  WNDataSetInf;

type

  // Base Cache Interface Implementation
  TBaseCacheImpl = class(TCacheImpl, IBaseCache)
  private
  protected
    // After Sync Update Cache Data
    procedure DoAfterSyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // After Sync Delete Cache Data
    procedure DoAfterSyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // After ASync Update Cache Data
    procedure DoAfterASyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // After ASync Delete Cache Data
    procedure DoAfterASyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
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

    { IBaseCache }

    //  Synchronous query data
    function SyncQuery(ASql: WideString): IWNDataSet; safecall;
    // Asynchronous query data
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

uses
  Cfg,
  LogLevel;

{ TBaseCacheImpl }

constructor TBaseCacheImpl.Create;
begin
  inherited;

end;

destructor TBaseCacheImpl.Destroy;
begin

  inherited;
end;

procedure TBaseCacheImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  if FAppContext <> nil then begin
    FCacheDataAdapter.DataBaseName := FAppContext.GetCfg.GetCachePath + 'Base/BaseDB';
    FCfgFile := FAppContext.GetCfg.GetCfgPath + 'Cache/BaseCfg.xml';
    LoadTables;
    InitConnCache;
    InitSysTable;
  end;
end;

procedure TBaseCacheImpl.UnInitialize;
begin
  UnInitConnCache;
  UnLoadTables;
  inherited UnInitialize;
end;

procedure TBaseCacheImpl.SyncBlockExecute;
begin
  InitDataTables;
  DoSyncUpdateData;
  DoSyncDeleteData;
end;

procedure TBaseCacheImpl.AsyncNoBlockExecute;
begin
  DoASyncUpdateData;
  DoASyncDeleteData;
end;

function TBaseCacheImpl.Dependences: WideString;
begin
  Result := '';
end;

function TBaseCacheImpl.SyncQuery(ASql: WideString): IWNDataSet;
begin
  Result := FCacheDataAdapter.QuerySql(ASql);
end;

procedure TBaseCacheImpl.AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

procedure TBaseCacheImpl.DoAfterSyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TBaseCacheImpl.DoAfterSyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TBaseCacheImpl.DoAfterASyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TBaseCacheImpl.DoAfterASyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

end.
