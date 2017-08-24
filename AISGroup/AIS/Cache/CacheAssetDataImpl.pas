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
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

     { ISyncAsync }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; safecall;
    // ͬ��ִ�з���
    procedure SyncExecute; safecall;
    // �첽ִ�з���
    procedure AsyncExecute; safecall;

    { IUserCacheData }

    // ͬ����ȡ Cache ����
    function SyncCacheQueryData(ASql: WideString): IWNDataSet; safecall;
    // �첽��ȡ Cache ����
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
