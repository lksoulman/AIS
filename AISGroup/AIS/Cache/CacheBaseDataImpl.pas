unit CacheBaseDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-11
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CacheMgr,
  GFDataSet,
  SyncAsync,
  CacheType,
  AppContext,
  CacheTable,
  CacheGFData,
  WNDataSetInf,
  CacheBaseData;

type

  // 基础数据缓存接口实现
  TCacheBaseDataImpl = class(TCacheMgr, ISyncAsync, ICacheBaseData)
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
    // 构造方法
    constructor Create;
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

    { IBaseCacheData }

    // 同步获取 Cache 数据
    function SyncCacheQueryData(ASql: WideString): IWNDataSet; safecall;
    // 异步获取 Cache 数据
    procedure AsyncCacheQueryData(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

uses
  Forms,
  Config,
  FastLogLevel;

{ TCacheBaseDataImpl }

constructor TCacheBaseDataImpl.Create;
begin
  inherited;
end;

destructor TCacheBaseDataImpl.Destroy;
begin

  inherited;
end;

procedure TCacheBaseDataImpl.Initialize(AContext: IAppContext);
var
  LDataBaseName: string;
begin
  FAppContext := AContext;
  if FAppContext.GetConfig <> nil then begin
    FCacheDataAdapter.DataBaseName := (FAppContext.GetConfig as IConfig).GetCachePath + 'BaseDB';
    FCfgFile := (FAppContext.GetConfig as IConfig).GetCfgPath + 'CacheBaseCfg.xml';
    LoadTables;
    InitConnCache;
    InitSysTable;
  end;
end;

procedure TCacheBaseDataImpl.UnInitialize;
begin
  UnInitConnCache;
  UnLoadTables;
  FAppContext := nil;
end;

function TCacheBaseDataImpl.IsNeedSync: WordBool;
begin
  Result := not IsExistCacheTable('ZQZB');
end;

procedure TCacheBaseDataImpl.SyncExecute;
begin
  InitDataTables;
  DoSyncUpdateData;
  DoSyncDeleteData;
end;

procedure TCacheBaseDataImpl.AsyncExecute;
begin
  DoASyncUpdateData;
  DoASyncDeleteData;
end;

function TCacheBaseDataImpl.SyncCacheQueryData(ASql: WideString): IWNDataSet;
begin
  Result := FCacheDataAdapter.QuerySql(ASql);
end;

procedure TCacheBaseDataImpl.AsyncCacheQueryData(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

procedure TCacheBaseDataImpl.DoAfterSyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TCacheBaseDataImpl.DoAfterSyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TCacheBaseDataImpl.DoAfterASyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

procedure TCacheBaseDataImpl.DoAfterASyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet);
begin

end;

end.
