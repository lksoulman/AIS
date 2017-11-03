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
  Log,
  Cfg,
  Login,
  GFData,
  Vcl.Forms,
  EDCrypt,
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  Behavior,
  CacheType,
  BaseCache,
  UserCache,
  AppContext,
  FactoryMgr,
  ServiceType,
  ResourceCfg,
  ResourceSkin,
  BasicService,
  AssetService,
  WNDataSetInf,
  CommonRefCounter,
  Generics.Collections;

type

  // Application Context Interface Implementation
  TAppContextImpl = class(TAutoInterfacedObject, IAppContext)
  private
    // Log
    FLog: ILog;
    // Cfg
    FCfg: ICfg;
    // Login
    FLogin: ILogin;
    // EDCrypt
    FEDCrypt: IEDCrypt;
    // Resource Cfg
    FResourceCfg: IResourceCfg;
    // Resource Skin
    FResourceSkin: IResourceSkin;
    // Factory Manager
    FFactoryMgr: IFactoryMgr;
    // Basic Service
    FBasicService: IBasicService;
    // Asset Service
    FAssetService: IAssetService;
    // Hq Authority
    FHqAuth: IInterface;
    // Product Authority
    FProAuth: IInterface;
    // Behavior
    FBehavior: IBehavior;
    // SecuMain Memory Table
    FSecuMain: IInterface;
    // Base Cache
    FBaseCache: IBaseCache;
    // User Cache
    FUserCache: IUserCache;
    // Message Service
    FMsgService: IInterface;
    // Interface Dictionary
    FInterfaceDic: TDictionary<string, IUnknown>;
  protected
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
    // Initialize
    procedure Initialize; safecall;
    // Un Initialize
    procedure UnInitialize; safecall;
    // Get Application
    function GetApp: TApplication; safecall;
    // Get Config
    function GetCfg: ICfg; safecall;
    // Get Login
    function GetLogin: ILogin; safecall;
    // Get EDCrypt
    function GetEDCrypt: IEDCrypt; safecall;
    // Get Resource Cfg
    function GetResourceCfg: IResourceCfg; safecall;
    // Get Resource Skin
    function GetResourceSkin: IResourceSkin; safecall;
    // Get Hq Authority
    function GetHqAuth: IInterface; safecall;
    // Get Product Authority
    function GetProAuth: IInterface; safecall;
    // Get SecuMain
    function GetSecuMain: IInterface; safecall;
    // Get MsgService
    function GetMsgService: IInterface; safecall;
    // Get BasicService
    function GetBasicService: IBasicService; safecall;
    // Get AssetService
    function GetAssetService: IAssetService; safecall;
    // Un Register Interface
    procedure UnRegisterInterface(AGuid: TGUID); safecall;
    // Register Interface
    procedure RegisterInterface(AGuid: TGUID; AObj: IUnknown); safecall;
    // Get Interfacec By Guid
    function GetInterfaceByGuid(AGuid: TGUID): IUnknown; safecall;
    // Add Behavior
    function AddBehavior(ABehavior: WideString): Boolean; safecall;
    // Get Error Info
    function GetErrorInfo(AErrorCode: Integer): WideString; safecall;
    // Create interface
    function CreatePlugInById(APlugInId: Integer): IInterface; safecall;
    // HQ Log
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Web Log
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Sys Log
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Indicator Log
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Cache Synchronous Query
    function CacheSyncQuery(ACacheType: TCacheType; ASql: WideString): IWNDataSet; safecall;
    // Synchronous POST
    function GFSyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet; safecall;
    // Asynchronous POST
    function GFAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData; safecall;
    // Priority Synchronous POST
    function GFPrioritySyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet; safecall;
    // Priority Asynchronous POST
    function GFPriorityAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData; safecall;
  end;

implementation

uses
  Utils,
  HqAuth,
  ProAuth,
  LogImpl,
  CfgImpl,
  SecuMain,
  ErrorCode,
  MsgService,
  EDCryptImpl,
  PlugInConst,
  FactoryMgrImpl,
  ResourceCfgImpl,
  ResourceSkinImpl;

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

procedure TAppContextImpl.Initialize;
begin
  FLog := TLogImpl.Create as ILog;
  FLog.Initialize;
  FEDCrypt := TEDCryptImpl.Create as IEDCrypt;
  FEDCrypt.Initialize(Self);
  FResourceCfg := TResourceCfgImpl.Create as IResourceCfg;
  FResourceCfg.Initialize(Self);
  FResourceSkin := TResourceSkinImpl.Create as IResourceSkin;
  FResourceSkin.Initialize(Self);
  FCfg := TCfgImpl.Create as ICfg;
  FCfg.Initialize(Self);
  FFactoryMgr := TFactoryMgrImpl.Create as IFactoryMgr;
  FFactoryMgr.Initialize(Self);
  FResourceSkin.ChangeSkin;
end;

procedure TAppContextImpl.UnInitialize;
begin
  FInterfaceDic.Clear;
  FLogin := nil;
  FBaseCache := nil;
  FUserCache := nil;
  FBasicService := nil;
  FAssetService := nil;
  FFactoryMgr.UnInitialize;
  FFactoryMgr := nil;
  FCfg.UnInitialize;
  FCfg := nil;
  FResourceSkin.UnInitialize;
  FResourceSkin := nil;
  FResourceCfg.UnInitialize;
  FResourceCfg := nil;
  FEDCrypt.UnInitialize;
  FEDCrypt := nil;
  FLog.UnInitialize;
  FLog := nil;
end;

function TAppContextImpl.GetApp: TApplication;
begin

end;

function TAppContextImpl.GetCfg: ICfg;
begin
  Result := FCfg;
end;

function TAppContextImpl.GetLogin: ILogin;
begin
  Result := FLogin;
end;

function TAppContextImpl.GetHqAuth;
begin
  Result := FHqAuth;
end;

function TAppContextImpl.GetProAuth;
begin
  Result := FProAuth;
end;

function TAppContextImpl.GetSecuMain: IInterface;
begin
  Result := FSecuMain;
end;

function TAppContextImpl.GetEDCrypt: IEDCrypt;
begin
  Result := FEDCrypt;
end;

function TAppContextImpl.GetResourceCfg: IResourceCfg;
begin
  Result := FResourceCfg;
end;

function TAppContextImpl.GetResourceSkin: IResourceSkin;
begin
  Result := FResourceSkin;
end;

function TAppContextImpl.GetMsgService: IInterface;
begin
  Result := FMsgService;
end;

function TAppContextImpl.GetBasicService: IBasicService;
begin
  Result := FBasicService;
end;

function TAppContextImpl.GetAssetService: IAssetService;
begin
  Result := FAssetService;
end;

procedure TAppContextImpl.RegisterInterface(AGUID: TGUID; AObj: IUnknown);
var
  LGUID: string;
begin
  if AObj = nil then Exit;
  LGUID := GUIDToString(AGUID);
  FInterfaceDic.AddOrSetValue(LGUID, AObj);
  if LGUID = GUIDToString(IBasicService) then begin
    FBasicService := AObj as IBasicService;
  end else if LGUID = GUIDToString(IAssetService) then begin
    FAssetService := AObj as IAssetService;
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
  end else if LGUID = GUIDToString(IHqAuth) then begin
    FHqAuth := AObj as IInterface;
  end else if LGUID = GUIDToString(IProAuth) then begin
    FProAuth := AObj as IInterface;
  end else if LGUID = GUIDToString(ILogin) then begin
    FLogin := AObj as ILogin;
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

function TAppContextImpl.GetErrorInfo(AErrorCode: Integer): WideString;
begin
  Result := ErrorCodeToErrorInfo(AErrorCode);
end;

function TAppContextImpl.CreatePlugInById(APlugInId: Integer): IInterface;
begin
  Result := FFactoryMgr.CreatePlugInById(APlugInId);
end;

procedure TAppContextImpl.HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FLog.HQLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
begin
  FLog.WebLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
begin
  FLog.SysLog(ALevel, ALog, AUseTime);
end;

procedure TAppContextImpl.IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  FLog.IndicatorLog(ALevel, ALog, AUseTime);
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

function TAppContextImpl.GFSyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LGFData: IGFData;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBasic:
        begin
          LGFData := FBasicService.SyncPost(AIndicator, AWaitTime);
        end;
      stAsset:
        begin
          LGFData := FAssetService.SyncPost(AIndicator, AWaitTime);
        end;
    end;
    Result := Utils.GFData2WNDataSet(LGFData);
    if LGFData <> nil then begin
      LGFData := nil;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBasic:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFSyncQuery] FBasicService.SyncPost Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
      stAsset:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFSyncQuery] FAssetService.SyncPost Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
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
      stBasic:
        begin
          Result := FBasicService.AsyncPOST(AIndicator, AEvent, AKey);
        end;
      stAsset:
        begin
          Result := FAssetService.AsyncPOST(AIndicator, AEvent, AKey);
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBasic:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFAsyncQuery] FBasicService.AsyncPOST Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
      stAsset:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFAsyncQuery] FAssetService.AsyncPOST Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFPrioritySyncQuery(AServiceType: TServiceType; AIndicator: WideString; AWaitTime: DWORD): IWNDataSet;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LGFData: IGFData;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
    case AServiceType of
      stBasic:
        begin
          LGFData := FBasicService.PrioritySyncPost(AIndicator, AWaitTime);
        end;
      stAsset:
        begin
          LGFData := FAssetService.PrioritySyncPost(AIndicator, AWaitTime);
        end;
    end;
    Result := Utils.GFData2WNDataSet(LGFData);
    if LGFData <> nil then begin
      LGFData := nil;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBasic:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFPrioritySyncQuery] FBasicService.PrioritySyncPost Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
      stAsset:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFPrioritySyncQuery] FBasicService.PrioritySyncPost Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

function TAppContextImpl.GFPriorityAsyncQuery(AServiceType: TServiceType; AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
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
      stBasic:
        begin
          Result := FBasicService.PriorityAsyncPOST(AIndicator, AEvent, AKey);
        end;
      stAsset:
        begin
          Result := FAssetService.PriorityAsyncPOST(AIndicator, AEvent, AKey);
        end;
    end;
{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    case AServiceType of
      stBasic:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFPriorityAsyncQuery] FBasicService.AsyncPOST Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
      stAsset:
        begin
          IndicatorLog(llSlow, Format('[TAppContextImpl][GFPriorityAsyncQuery] FAssetService.AsyncPOST Execute Indicator(%s) use time is %d ms.', [AIndicator, LTick]), LTick);
        end;
    end;
  end;
{$ENDIF}
end;

end.
