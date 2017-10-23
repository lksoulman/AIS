unit AssetService;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Asset Service Interface
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

  // UFX Login
  TUFXLogin = packed record
    FErrorCode: Integer;
    FErrorInfo: WideString;
    FServerUrl: WideString;
    FOrgNo: WideString;
    FAssetNo: WideString;
    FUserName: WideString;
    FCipherPassword: WideString;
    FMacAddress: WideString;
    FHardDiskId: WideString;
    FHardDiskIdMD5: WideString;
  end;

  // UFX Login Pointer
  PUFXLogin = ^TUFXLogin;

  // Gil Login
  TGILLogin = packed record
    FErrorCode: Integer;
    FErrorInfo: WideString;
    FServerUrl: WideString;
    FOrgNo: WideString;
    FAssetNo: WideString;
    FUserName: WideString;
    FGilUserName: WideString;
    FCipherPassword: WideString;
    FMacAddress: WideString;
    FHardDiskId: WideString;
    FHardDiskIdMD5: WideString;
  end;

  // Gil Login Pointer
  PGILLogin = ^TGILLogin;

  // PBOX Login
  TPBOXLogin = packed record
    FErrorCode: Integer;
    FErrorInfo: WideString;
    FServerUrl: WideString;
    FOrgNo: WideString;
    FAssetNo: WideString;
    FUserName: WideString;
    FCipherPassword: WideString;
    FMacAddress: WideString;
    FHardDiskId: WideString;
    FHardDiskIdMD5: WideString;
  end;

  // PBOX Login Pointer
  PPBOXLogin= ^TPBOXLogin;

  // Asset Service Interface
  IAssetService = interface(IInterface)
    ['{B1F0E6FD-73F7-43EC-B90D-AF7AC627E7FE}']
    // Is Logined
    function IsLogined: Boolean; safecall;
    // Get SessionId
    function GetSessionId: WideString; safecall;
    // UFX Login
    function UFXLogin(APUFXLogin: PUFXLogin): Boolean; safecall;
    // GIL Login
    function GILLogin(APGILLogin: PGILLogin): Boolean; safecall;
    // PBOX Login
    function PBOXLogin(APPBOXLogin: PPBOXLogin): Boolean; safecall;
    // Set Re Login Event
    function SetReLoginEvent(AReLoginEvent: TReLoginEvent): Boolean; safecall;
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
