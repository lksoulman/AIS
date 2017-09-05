unit AppContextImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Application Context Interface Implementation
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Vcl.Forms,
  Windows,
  Classes,
  SysUtils,
  Behavior,
  CacheType,
  BaseCache,
  UserCache,
  AppContext,
  ServiceType,
  ServiceBase,
  ServiceAsset,
  FastLogLevel,
  WNDataSetInf,
  GFDataMngr_TLB,
  CommonRefCounter,
  Generics.Collections;

type

  // Application Context Interface Implementation
  TAppContextImpl = class(TAutoInterfacedObject, IAppContext)
  private
    // Hq Authority Interface
    FHqAuth: IInterface;
    // Product Authority Interface
    FProductAuth: IInterface;
    // Config Interface
    FConfig: IInterface;
    // Behavior
    FBehavior: IBehavior;
    // SecuMain Memory Table Interface
    FSecuMain: IInterface;
    // LoginMgr Interface
    FLoginMgr: IInterface;
    // CipherMgr Interface
    FCipherMgr: IInterface;
    // Base Cache Interface
    FBaseCache: IBaseCache;
    // User Cache Interface
    FUserCache: IUserCache;
    // Message Service
    FMsgService: IInterface;
    // Base Service
    FServiceBase: IServiceBase;
    // Asset Service
    FServiceAsset: IServiceAsset;
    // Base GF Data Manager
    FBaseGFDataManager: IGFDataManager;
    // Asset GF Data Manager
    FAssetGFDataManager: IGFDataManager;
    // Interface Dictionary
    FInterfaceDic: TDictionary<string, IUnknown>;
  protected
    // Wait For Single Object
    function DoWaitForSingleObject(AGFData: IGFData; AWaitTime: DWORD; ALogSuffix: string): IWNDataSet;
    // GF Sync Query
    function DoGFSyncQuery(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
    // GF Async Query
    function DoGFASyncQuery(AGFDataManager: IGFDataManager; ASql: WideString; ADataArrive: Int64; ATag: Int64; LogSuffix: string): IGFData;
    // GF Sync High Query
    function DoGFSyncHighQuery(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IAppContext }

    // Exit Application
    procedure ExitApp; safecall;
    // Restart Application
    procedure ReStartApp; safecall;
    // Get Config
    function GetConfig: IInterface; safecall;
    // Get Hq Authority
    function GetHqAuth: IInterface; safecall;
    // Get Product Authority
    function GetProductAuth: IInterface; safecall;
    // Get LoginMgr
    function GetLoginMgr: IInterface; safecall;
    // Get SecuMain
    function GetSecuMain: IInterface; safecall;
    // Get CipherMgr
    function GetCipherMgr: IInterface; safecall;
    // Get MsgService
    function GetMsgService: IInterface; safecall;
    // Get Service Base
    function GetServiceBase: IInterface; safecall;
    // Get Service Asset
    function GetServiceAsset: IInterface; safecall;
    // Register Interface
    procedure RegisterInterface(AGuid: TGUID; AObj: IUnknown); safecall;
    // Un Register Interface
    procedure UnRegisterInterface(AGuid: TGUID); safecall;
    // Get Interfacec By Guid
    function GetInterfaceByGuid(AGuid: TGUID): IUnknown; safecall;
    // Add Behavior
    function AddBehavior(ABehavior: WideString): Boolean; safecall;
    // Cache Synchronous Query
    function CacheSyncQuery(ACacheType: TCacheType; ASql: WideString): IWNDataSet; safecall;
    // GF Synchronous Query
    function GFSyncQuery(AServiceType: TServiceType; ASQL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
    // GF ASynchronous Query
    function GFASyncQuery(AServiceType: TServiceType; ASql: WideString; ADataArrive: Int64; ATag: Int64): IGFData; safecall;
    // GF ASynchronous High Query
    function GFSyncHighQuery(AServiceType: TServiceType; ASQL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet; safecall;
  end;

implementation

uses
  Utils,
  HqAuth,
  Config,
  SecuMain,
  LoginMgr,
  CipherMgr,
  MsgService,
  ProductAuth,
  AsfSdkExport;

{ TAppContextImpl }

constructor TAppContextImpl.Create;
begin
  FInterfaceDic := TDictionary<string, IUnknown>.Create;
end;

destructor TAppContextImpl.Destroy;
begin
  FInterfaceDic.Free;
end;

procedure TAppContextImpl.ExitApp;
begin
  Application.Terminate;
end;

procedure TAppContextImpl.ReStartApp;
begin

end;

function TAppContextImpl.GetConfig: IInterface;
begin
  Result := FConfig;
end;

function TAppContextImpl.GetHqAuth;
begin
  Result := FHqAuth;
end;

function TAppContextImpl.GetProductAuth;
begin
  Result := FProductAuth;
end;

function TAppContextImpl.GetLoginMgr: IInterface;
begin
  Result := FLoginMgr;
end;

function TAppContextImpl.GetSecuMain: IInterface;
begin
  Result := FSecuMain;
end;

function TAppContextImpl.GetCipherMgr: IInterface;
begin
  Result := FCipherMgr;
end;

function TAppContextImpl.GetMsgService: IInterface;
begin
  Result := FMsgService;
end;

function TAppContextImpl.GetServiceBase: IInterface;
begin
  Result := FServiceBase;
end;

function TAppContextImpl.GetServiceAsset: IInterface;
begin
  Result := FServiceAsset;
end;

procedure TAppContextImpl.RegisterInterface(AGUID: TGUID; AObj: IUnknown);
var
  LGUID: string;
begin
  if AObj = nil then Exit;
  LGUID := GUIDToString(AGUID);
  FInterfaceDic.AddOrSetValue(LGUID, AObj);
  if LGUID = GUIDToString(IConfig) then begin
    FConfig := AObj as IInterface;
  end else if LGUID = GUIDToString(ILoginMgr) then begin
    FLoginMgr := AObj as IInterface;
  end else if LGUID = GUIDToString(ICipherMgr) then begin
    FCipherMgr := AObj as IInterface;
  end else if LGUID = GUIDToString(ISecuMain) then begin
    FSecuMain := AObj as IInterface;
  end else if LGUID = GUIDToString(IMsgService) then begin
    FMsgService := AObj as IInterface;
  end else if LGUID = GUIDToString(IBehavior) then begin
    FBehavior := AObj as IBehavior;
  end else if LGUID = GUIDToString(IBaseCache) then begin
    FBaseCache := AObj as IBaseCache;
  end else if LGUID = GUIDToString(IUserCache) then begin
    FUserCache := AObj as IUserCache;
  end else if LGUID = GUIDToString(IServiceBase) then begin
    FServiceBase := AObj as IServiceBase;
    FBaseGFDataManager := FServiceBase.GetGFDataManager;
  end else if LGUID = GUIDToString(IServiceAsset) then begin
    FServiceAsset := AObj as IServiceAsset;
    FAssetGFDataManager := FServiceAsset.GetGFDataManager;
  end else if LGUID = GUIDToString(IHqAuth) then begin
    FHqAuth := AObj as IInterface;
  end else if LGUID = GUIDToString(IProductAuth) then begin
    FProductAuth := AObj as IInterface;
  end;
end;

procedure TAppContextImpl.UnRegisterInterface(AGuid: TGUID);
begin
  FInterfaceDic.Remove(GUIDToString(AGuid));
end;

function TAppContextImpl.GetInterfacebyGuid(AGuid: TGUID): IUnknown;
begin
  if not FInterfaceDic.TryGetValue(GUIDToString(AGuid), Result) then begin
    Result := nil;
  end;
end;

function TAppContextImpl.AddBehavior(ABehavior: WideString): Boolean;
begin
  if FBehavior <> nil then begin
    FBehavior.Add(ABehavior);
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TAppContextImpl.CacheSyncQuery(ACacheType: TCacheType; ASql: WideString): IWNDataSet;
begin
  case ACacheType of
    ctBaseData:
      begin
        if FBaseCache <> nil then begin
          Result := (FBaseCache as IBaseCache).SyncQuery(ASql);
        end;
      end;
    ctUserDaata:
      begin
        if FUserCache <> nil then begin
          Result := (FUserCache as IUserCache).SyncQuery(ASql);
        end;
      end;
  end;
end;

function TAppContextImpl.GFSyncQuery(AServiceType: TServiceType; ASQL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBase:
        begin
          Result := DoGFSyncQuery(FBaseGFDataManager, ASql, ATag, AWaitTime, '[TAppContextImpl.GFSyncQueryData FBaseGFDataManager]');
        end;
      stAsset:
        begin
          Result := DoGFSyncQuery(FAssetGFDataManager, ASql, ATag, AWaitTime, '[TAppContextImpl.GFSyncQueryData FAssetGFDataManager]');
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBase:
        begin
          FastIndicatorLog(llSlow, Format('[FBaseGFDataManager.QueryDataSet DoGFSyncQueryDataSet] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
      stAsset:
        begin
          FastIndicatorLog(llSlow, Format('[FAssetGFDataManager.QueryDataSet DoGFSyncQueryDataSet] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFASyncQuery(AServiceType: TServiceType; ASql: WideString; ADataArrive: Int64; ATag: Int64): IGFData;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBase:
        begin
          Result := DoGFASyncQuery(FBaseGFDataManager, ASql, ADataArrive, ATag, '[TAppContextImpl.GFASyncQueryData FBaseGFDataManager]');
        end;
      stAsset:
        begin
          Result := DoGFASyncQuery(FAssetGFDataManager, ASql, ADataArrive, ATag, '[TAppContextImpl.GFASyncQueryData FAssetGFDataManager]');
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBase:
        begin
          FastIndicatorLog(llSlow, Format('[FBaseGFDataManager.QueryDataSet DoGFASyncQueryData] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
      stAsset:
        begin
          FastIndicatorLog(llSlow, Format('[FAssetGFDataManager.QueryDataSet DoGFASyncQueryData] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFSyncHighQuery(AServiceType: TServiceType; ASQL: WideString; ATag: Int64; AWaitTime: DWORD): IWNDataSet;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBase:
        begin
          Result := DoGFSyncHighQuery(FBaseGFDataManager, ASql, ATag, AWaitTime, '[TAppContextImpl.GFSyncQueryHighData FBaseGFDataManager]');
        end;
      stAsset:
        begin
          Result := DoGFSyncHighQuery(FAssetGFDataManager, ASql, ATag, AWaitTime, '[TAppContextImpl.GFSyncQueryHighData FAssetGFDataManager]');
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBase:
        begin
          FastIndicatorLog(llSlow, Format('[FBaseGFDataManager.QueryHighDataSet DoGFSyncQueryHighDataSet] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
      stAsset:
        begin
          FastIndicatorLog(llSlow, Format('[FAssetGFDataManager.QueryHighDataSet DoGFSyncQueryHighDataSet] Execute Indicator(%s) use time is %d ms.', [ASql, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.DoWaitForSingleObject(AGFData: IGFData; AWaitTime: DWORD; ALogSuffix: string): IWNDataSet;
var
  LResult: Cardinal;
begin
  LResult := WaitForSingleObject(AGFData.WaitEvent, AWaitTime);
  case LResult of
    WAIT_OBJECT_0:
      begin
        Result := Utils.GFData2WNDataSet(AGFData);
        if Result = nil then begin
          FastSysLog(llError, ALogSuffix + ' WaitForSingleObject return is nil.');
        end;
      end;
    WAIT_TIMEOUT:
      begin
        FastSysLog(llError, ALogSuffix + ' WaitForSingleObject is timeout.');
      end;
    WAIT_FAILED:
      begin
        FastSysLog(llError, ALogSuffix + ' WaitForSingleObject is Failed.');
      end;
  end;
end;

function TAppContextImpl.DoGFSyncQuery(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
var
  LEvent: Int64;
  LGFData: IGFData;
begin
  if AGFDataManager <> nil then begin
    if AGFDataManager.Login then begin
      LEvent := 0;
      try
        LGFData := AGFDataManager.QueryDataSet(0, ASql, wmBlocking, LEvent, ATag);
        if LGFData <> nil then begin
          Result := DoWaitForSingleObject(LGFData, AWaitTime, Format('[%s] GFDataManager.QueryDataSet Execute Indicator(%s),', [LogSuffix, ASql]));
        end else begin
          Result := nil;
        end;
      except
        on Ex: Exception do begin
          Result := nil;
          FastSysLog(llError, Format('[%s] GFDataManager.QueryDataSet is exception, exception is %s, Execute Indicator(%s).', [LogSuffix, Ex.Message, ASql]));
        end;
      end;
    end else begin
      Result := nil;
      FastSysLog(llError, Format('[%s] GFDataManager.Login is false, Execute Indicator(%s).', [LogSuffix, ASql]));
    end;
  end else begin
    Result := nil;
    FastSysLog(llError, Format('[%s] GFDataManager is nil, Execute Indicator(%s).', [LogSuffix, ASql]));
  end;
end;

function TAppContextImpl.DoGFASyncQuery(AGFDataManager: IGFDataManager; ASql: WideString; ADataArrive: Int64; ATag: Int64; LogSuffix: string): IGFData;
begin
  if (AGFDataManager <> nil) then begin
    if AGFDataManager.Login then begin
      try
        Result := FBaseGFDataManager.QueryDataSet(0, ASql, wmNonBlocking, ADataArrive, ATag);
      except
        on Ex: Exception do begin
          Result := nil;
          FastSysLog(llError, Format('[%s] GFDataManager.QueryDataSet is exception, exception is %s, Execute Indicator(%s).', [LogSuffix, Ex.Message, ASql]));
        end;
      end;
    end else begin
      Result := nil;
      FastSysLog(llError, Format('[%s] GFDataManager.Login is false, Execute Indicator(%s).', [LogSuffix, ASql]));
    end;
  end else begin
    Result := nil;
    FastSysLog(llError, Format('[%s] GFDataManager is nil, Execute Indicator(%s).', [LogSuffix, ASql]));
  end;
end;

function TAppContextImpl.DoGFSyncHighQuery(AGFDataManager: IGFDataManager; ASql: string; ATag: Int64; AWaitTime: DWORD; LogSuffix: string): IWNDataSet;
var
  LEvent: Int64;
  LGFData: IGFData;
begin
  if AGFDataManager <> nil then begin
    if AGFDataManager.Login then begin
      LEvent := 0;
      try
        LGFData := AGFDataManager.QueryHighDataSet(0, ASql, wmBlocking, LEvent, ATag);
        if LGFData <> nil then begin
          Result := DoWaitForSingleObject(LGFData, AWaitTime, Format('[%s] GFDataManager.QueryHighDataSet Execute Indicator(%s),', [LogSuffix, ASql]));
        end else begin
          Result := nil;
        end;
      except
        on Ex: Exception do begin
          Result := nil;
          FastSysLog(llError, Format('[%s] GFDataManager.QueryHighDataSet is exception, exception is %s, Execute Indicator(%s).', [LogSuffix, Ex.Message, ASql]));
        end;
      end;
    end else begin
      Result := nil;
      FastSysLog(llError, Format('[%s] GFDataManager.Login is false, Execute Indicator(%s).', [LogSuffix, ASql]));
    end;
  end else begin
    Result := nil;
    FastSysLog(llError, Format('[%s] GFDataManager is nil, Execute Indicator(%s).', [LogSuffix, ASql]));
  end;
end;

end.
