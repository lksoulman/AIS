unit AppContext;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Application Context Interface
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Cfg,
  Login,
  GFData,
  EDCrypt,
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  CacheType,
  ServiceType,
  ResourceCfg,
  ResourceSkin,
  BasicService,
  AssetService,
  WNDataSetInf;

type

  // Application Context Interface
  IAppContext = Interface(IInterface)
    ['{919A20C7-3242-4DBB-81F7-18EF05813380}']
    // Exit Application
    procedure ExitApp; safecall;
    // Restart Application
    procedure ReStartApp; safecall;
    // Initialize
    procedure Initialize; safecall;
    // Un Initialize
    procedure UnInitialize; safecall;
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

end.
