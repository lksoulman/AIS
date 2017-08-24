unit CacheAssetDataImpl;

interface

uses
  Windows,
  Classes,
  SysUtils,
  CacheMgr,
  SyncAsync,
  CacheType,
  AppContext,
  WNDataSetInf,
  CacheUserData;

type

  TCacheAssetDataImpl = class(TCacheMgr, ISyncAsync, ICacheUserData)
  private
  protected
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

    { IUserCacheData }

    // 同步获取 Cache 数据
    function SyncCacheQueryData(ASql: WideString): IWNDataSet; safecall;
    // 异步获取 Cache 数据
    procedure AsyncCacheQueryData(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;


implementation

uses
  Config;

{ TCacheAssetDataImpl }

constructor TCacheAssetDataImpl.Create;
begin

end;

destructor TCacheAssetDataImpl.Destroy;
begin

  inherited;
end;

procedure TCacheAssetDataImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  if FAppContext.GetConfig <> nil then begin
    FCacheDataAdapter.DataBaseName := (FAppContext.GetConfig as IConfig).GetUserCachePath + 'UserAssetDB';
    FCfgFile := (FAppContext.GetConfig as IConfig).GetCfgPath + 'CacheUserAssetCfg.xml';
    LoadTables;
    InitConnCache;
    InitSysTable;
  end;
end;

procedure TCacheAssetDataImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TCacheAssetDataImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TCacheAssetDataImpl.SyncExecute;
begin
  DoSyncUpdateData;
end;

procedure TCacheAssetDataImpl.AsyncExecute;
begin

end;

function TCacheAssetDataImpl.SyncCacheQueryData(ASql: WideString): IWNDataSet;
begin
  Result := FCacheDataAdapter.QuerySql(ASql);
end;

procedure TCacheAssetDataImpl.AsyncCacheQueryData(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
