unit BasicService;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Basic Service Interface
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  GFData,
  Windows,
  Classes,
  SysUtils;

type

  // Gil Basic Bind
  TGilBasicBind = packed record
    FErrorCode: Integer;
    FErrorInfo: WideString;
    FServerUrl: WideString;
    FOrgNo: WideString;
    FAssetNo: WideString;
    FUserName: WideString;
    FLicense: WideString;
    FOrgSign: WideString;
    FGilUserName: WideString;
    FHardDiskIdMD5: WideString;
  end;

  // Gil Basic Bind Pointer
  PGilBasicBind = ^TGilBasicBind;

  // Gil Basic Login
  TGilBasicLogin = packed record
    FErrorCode: Integer;
    FErrorInfo: WideString;
    FServerUrl: WideString;
    FOrgNo: WideString;
    FAssetNo: WideString;
    FUserName: WideString;
    FLicense: WideString;
    FHardDiskIdMD5: WideString;
  end;

  // Gil Basic Login Pointer
  PGilBasicLogin = ^TGilBasicLogin;

  // Basic Password set
  TGilBasicPasswordSet = packed record
    ErrorCode: Integer;
    ErrorInfo: WideString;
    GilUserName: WideString;
    OldPassword: WideString;
    NewPassword: WideString;
  end;

  // Basic Password set Pointer
  PGilBasicPasswordSet = ^TGilBasicPasswordSet;

  // Basic Service Interface
  IBasicService = interface(IInterface)
    ['{787328F5-658A-44E1-9242-E4E1F6F577EB}']
    // Is Logined
    function IsLogined: Boolean; safecall;
    // Get SessionId
    function GetSessionId: WideString; safecall;
    // Gil Bind
    function GilBind(APBasicBind: PGilBasicBind): Boolean; safecall;
    // Gil Login
    function GilLogin(APBasicLogin: PGilBasicLogin): Boolean; safecall;
    // Set Re Login Event
    function SetReLoginEvent(AReLoginEvent: TReLoginEvent): Boolean; safecall;
    // Gil Password Set
    function GilPasswordSet(APBasicPasswordSet: PGilBasicPasswordSet): Boolean; safecall;
    // Synchronous POST
    function SyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData; safecall;
    // Asynchronous POST
    function AsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData; safecall;
    // Priority Synchronous POST
    function PrioritySyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData; safecall;
    // Priority Asynchronous POST
    function PriorityAsyncPOST(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData; safecall;
  end;

implementation

end.
