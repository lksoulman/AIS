unit CacheBaseDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-11
// Comments��
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

  // �������ݻ���ӿ�ʵ��
  TCacheBaseDataImpl = class(TCacheMgr, ISyncAsync, ICacheBaseData)
  private
  protected
    // ͬ���ӱ�����������ݺ���
    procedure DoAfterSyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // ͬ���ӱ�����ɾ�����ݺ���
    procedure DoAfterSyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // �첽�ӱ�����������ݺ���
    procedure DoAfterASyncUpdateCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
    // �첽�ӱ�����ɾ�����ݺ���
    procedure DoAfterASyncDeleteCacheData(ATable: TCacheTable; ADataSet: IWNDataSet); override;
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

    { IBaseCacheData }

    // ͬ����ȡ Cache ����
    function SyncCacheQueryData(ASql: WideString): IWNDataSet; safecall;
    // �첽��ȡ Cache ����
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
