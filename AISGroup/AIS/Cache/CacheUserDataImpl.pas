unit CacheUserDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-12
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

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

  // 用户数据缓存
  TCacheUserDataImpl = class(TCacheMgr, ISyncAsync, ICacheUserData)
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

{ TCacheUserDataImpl }

constructor TCacheUserDataImpl.Create;
begin
  inherited;

end;

destructor TCacheUserDataImpl.Destroy;
begin

  inherited;
end;

procedure TCacheUserDataImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TCacheUserDataImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TCacheUserDataImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TCacheUserDataImpl.SyncExecute;
begin
  if FAppContext.GetConfig <> nil then begin
    FCacheDataAdapter.DataBaseName := (FAppContext.GetConfig as IConfig).GetUserCachePath + 'UserBaseDB';
    FCfgFile := (FAppContext.GetConfig as IConfig).GetCfgPath + 'CacheUserBaseCfg.xml';
    LoadTables;
    InitConnCache;
    InitSysTable;
    InitDataTables;
    DoSyncUpdateData;
  end;
end;

procedure TCacheUserDataImpl.AsyncExecute;
begin

end;

function TCacheUserDataImpl.SyncCacheQueryData(ASql: WideString): IWNDataSet;
begin
  Result := FCacheDataAdapter.QuerySql(ASql);
end;

procedure TCacheUserDataImpl.AsyncCacheQueryData(ASql: WideString; ADataArrive: Int64; ATag: Int64);
begin

end;

end.
