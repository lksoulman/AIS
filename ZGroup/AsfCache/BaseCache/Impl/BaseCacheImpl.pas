unit BaseCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Base Cache interface implementation
// Author：      lksoulman
// Date：        2017-8-11
// Comments：
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

  // Base Cache interface implementation
  TBaseCacheImpl = class(TCacheImpl, IBaseCache)
  private
  protected
    // 同步从表里面更新数据后处理
    procedure DoAfterSyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // 同步从表里面删除数据后处理
    procedure DoAfterSyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // 异步从表里面更新数据后处理
    procedure DoAfterASyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // 异步从表里面删除数据后处理
    procedure DoAfterASyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
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

    { IBaseCache }

    //  Synchronous query data
    function SyncQuery(ASql: WideString): IWNDataSet; safecall;
    // Asynchronous query data
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

uses
  Config,
  FastLogLevel;

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
  FAppContext := AContext;
  if FAppContext.GetConfig <> nil then begin
    FCacheDataAdapter.DataBaseName := (FAppContext.GetConfig as IConfig).GetCachePath + 'BaseDB';
    FCfgFile := (FAppContext.GetConfig as IConfig).GetCfgPath + 'Cache/BaseCfg.xml';
    LoadTables;
    InitConnCache;
    InitSysTable;
  end;
end;

procedure TBaseCacheImpl.UnInitialize;
begin
  UnInitConnCache;
  UnLoadTables;
  FAppContext := nil;
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
