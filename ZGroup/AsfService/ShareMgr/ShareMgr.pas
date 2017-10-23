unit ShareMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Share Manager Interface
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  ElAES,
  Proxy,
  GFData,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  HttpContextPool,
  CommonRefCounter;

type

  // Share Manager Interface
  IShareMgr = interface(IInterface)
    ['{4CB4F19C-3D52-43B1-AC9A-5C3C229F0A62}']
    // Init
    procedure Initialize(AContext: IAppContext); safecall;
    // Un Init
    procedure UnInitialize; safecall;
    // Get Url
    function GetUrl: string; safecall;
    // Get Proxy
    function GetProxy: PProxy; safecall;
    // Get Session Id
    function GetSessionId: string; safecall;
    // Get Is Logined
    function GetIsLogined: Boolean; safecall;
    // Get AES Key 128
    function GetAESKey128: TAESKey128; safecall;
    // Get Hard Disk Id MD5
    function GetHardDiskIdMD5: string; safecall;
    // Get AppContext
    function GetAppContext: IAppContext; safecall;
    // Get Re Login Event
    function GetReLoginEvent: TReLoginEvent; safecall;
    // Get Handler Pool
    function GetHttpContextPool: THttpContextPool; safecall;
    // Set Url
    procedure SetUrl(AUrl: string); safecall;
    // Set Proxy
    procedure SetProxy(APProxy: PProxy); safecall;
    // Set Session Id
    procedure SetSessionId(ASessionId: string); safecall;
    // Get Is Logined
    procedure SetIsLogined(AIsLogined: Boolean); safecall;
    // Set HardDiskId MD5
    procedure SetHardDiskIdMD5(AHardDiskIdMD5: string); safecall;
    // Set Re Login Event
    procedure SetReLoginEvent(AReLoginEvent: TReLoginEvent); safecall;
  end;

implementation

end.
