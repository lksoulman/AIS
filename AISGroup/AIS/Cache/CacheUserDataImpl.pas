unit CacheUserDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-12
// Comments��
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

  // �û����ݻ���
  TCacheUserDataImpl = class(TCacheMgr, ISyncAsync, ICacheUserData)
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
