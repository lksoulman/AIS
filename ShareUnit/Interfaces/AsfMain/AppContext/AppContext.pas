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
  Windows,
  Classes,
  SysUtils,
  CacheType,
  ServiceType,
  FastLogLevel,
  WNDataSetInf,
  GFDataMngr_TLB;

type

  // Application Context Interface
  IAppContext = Interface(IInterface)
    ['{919A20C7-3242-4DBB-81F7-18EF05813380}']
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

end.
