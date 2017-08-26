unit GFDataMngr_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 2016-09-08 15:51:27 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Project.D2009\GemFire\GFDataMngr\GDataMngr (1)
// LIBID: {28844DE8-F2EE-4C92-B509-063CF95FD161}
// LCID: 0
// Helpfile:
// HelpString: PBDataMngr Library
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\system32\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  GFDataMngrMajorVersion = 1;
  GFDataMngrMinorVersion = 0;

  LIBID_GFDataMngr: TGUID = '{28844DE8-F2EE-4C92-B509-063CF95FD161}';

  IID_IGFDataManager: TGUID = '{3D1C5FC4-4269-41F9-B6CF-5ED5190540D7}';
  DIID_IGFDataManagerEvents: TGUID = '{94ED172C-8112-4710-AC4B-EAFE356F00DF}';
  IID_IGFData: TGUID = '{726D3CA2-6373-420C-A192-FD66DB962B67}';
  CLASS_GFDataManager: TGUID = '{440B8170-DAD9-4591-9F25-D73EB019BCF7}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library
// *********************************************************************//
// Constants for enum DataStatusEnum
type
  DataStatusEnum = TOleEnum;
const
  dsWait = $00000000;
  dsCancel = $00000001;
  dsError = $00000002;
  dsSucceed = $00000003;

// Constants for enum WaitModeEnum
type
  WaitModeEnum = TOleEnum;
const
  wmBlocking = $00000000;
  wmNonBlocking = $00000001;

// Constants for enum ProxyKindEnum
type
  ProxyKindEnum = TOleEnum;
const
  pkNoProxy = $00000001;
  pkHTTPProxy = $00000002;
  pkSocks4 = $00000003;
  pkSocks5 = $00000004;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IGFDataManager = interface;
  IGFDataManagerDisp = dispinterface;
  IGFDataManagerEvents = dispinterface;
  IGFData = interface;
  IGFDataDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  GFDataManager = IGFDataManager;


// *********************************************************************//
// Declaration of structures, unions and aliases.
// *********************************************************************//
  PInteger1 = ^Integer; {*}
  PWideString1 = ^WideString; {*}


// *********************************************************************//
// Interface: IGFDataManager
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3D1C5FC4-4269-41F9-B6CF-5ED5190540D7}
// *********************************************************************//
  IGFDataManager = interface(IDispatch)
    ['{3D1C5FC4-4269-41F9-B6CF-5ED5190540D7}']
    function StartService: WordBool; safecall;
    procedure StopService; safecall;
    procedure ThreadCount(WorkCount: Integer; HighCount: Integer); safecall;
    procedure ProxySetting(Kind: ProxyKindEnum; const proxyIP: WideString; proxyPort: Integer;
                           const proxyUser: WideString; const proxyPWD: WideString;
                           const NTLM: WideString; const NTLMDomain: WideString); safecall;
    function Get_Active: WordBool; safecall;
    function QueryDataSet(Handle: Int64; const SQL: WideString; WaitMode: WaitModeEnum;
                          DataArrive: Int64; Tag: Int64): IGFData; safecall;
    function QueryHighDataSet(Handle: Int64; const SQL: WideString; WaitMode: WaitModeEnum;
                              DataArrive: Int64; Tag: Int64): IGFData; safecall;
    procedure CancelQuery(const GFData: IGFData); safecall;
    function UserLogin(Handle: Int64; const URL: WideString; const User: WideString;
                       const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): WordBool; safecall;
    function Get_Login: WordBool; safecall;
    function Get_SessionID: WideString; safecall;
    function PassSetup(Handle: Int64; const URL: WideString; const User: WideString;
                       const OPass: WideString; const NPass: WideString; var ErrCode: Integer;
                       var ErrMsg: WideString): WordBool; safecall;
    function HSUserLogin(Handle: Int64; const URL: WideString; const User: WideString;
                         const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): WordBool; safecall;
    function HSUserBind(Handle: Int64; const URL: WideString; const User: WideString;
                        const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): IGFData; safecall;
    procedure HeartBeatSetting(Time: Integer); safecall;
    function JYUserLogin(Handle: Int64; const URL: WideString; const User: WideString;
                         const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString; var PwdInfo: WideString): WideString; safecall;
    function JYPassSetup(Handle: Int64; const URL: WideString; const User: WideString;
                         const OPass: WideString; const NPass: WideString; var ErrCode: Integer;
                         var ErrMsg: WideString): WordBool; safecall;
    function PBOXLogin(Handle: Int64; const URL: WideString; const User: WideString;
                       const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): WordBool; safecall;
    property Active: WordBool read Get_Active;
    property Login: WordBool read Get_Login;
    property SessionID: WideString read Get_SessionID;
    //采用了新的加密方法的聚源账号密码修改方法
    function JYPassSetupNew(Handle: Int64; const URL: WideString; const User: WideString;
                         const OPass: WideString; const NPass: WideString; var ErrCode: Integer;
                         var ErrMsg: WideString): WordBool; safecall;
    //采用了新的加密方法的O32账号密码修改方法
    function PassSetupNew(Handle: Int64; const URL: WideString; const User: WideString;
                       const OPass: WideString; const NPass: WideString; var ErrCode: Integer;
                       var ErrMsg: WideString): WordBool; safecall;
  end;

// *********************************************************************//
// DispIntf:  IGFDataManagerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3D1C5FC4-4269-41F9-B6CF-5ED5190540D7}
// *********************************************************************//
  IGFDataManagerDisp = dispinterface
    ['{3D1C5FC4-4269-41F9-B6CF-5ED5190540D7}']
    function StartService: WordBool; dispid 201;
    procedure StopService; dispid 202;
    procedure ThreadCount(WorkCount: Integer; HighCount: Integer); dispid 203;
    procedure ProxySetting(Kind: ProxyKindEnum; const proxyIP: WideString; proxyPort: Integer;
                           const proxyUser: WideString; const proxyPWD: WideString;
                           const NTLM: WideString; const NTLMDomain: WideString); dispid 205;
    property Active: WordBool readonly dispid 206;
    function QueryDataSet(Handle: Int64; const SQL: WideString; WaitMode: WaitModeEnum;
                          DataArrive: Int64; Tag: Int64): IGFData; dispid 207;
    function QueryHighDataSet(Handle: Int64; const SQL: WideString; WaitMode: WaitModeEnum;
                              DataArrive: Int64; Tag: Int64): IGFData; dispid 208;
    procedure CancelQuery(const GFData: IGFData); dispid 209;
    function UserLogin(Handle: Int64; const URL: WideString; const User: WideString;
                       const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): WordBool; dispid 210;
    property Login: WordBool readonly dispid 204;
    property SessionID: WideString readonly dispid 211;
    function PassSetup(Handle: Int64; const URL: WideString; const User: WideString;
                       const OPass: WideString; const NPass: WideString; var ErrCode: Integer;
                       var ErrMsg: WideString): WordBool; dispid 212;
    function HSUserLogin(Handle: Int64; const URL: WideString; const User: WideString;
                         const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): WordBool; dispid 213;
    function HSUserBind(Handle: Int64; const URL: WideString; const User: WideString;
                        const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): IGFData; dispid 214;
    procedure HeartBeatSetting(Time: Integer); dispid 215;
    function JYUserLogin(Handle: Int64; const URL: WideString; const User: WideString;
                         const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): WideString; dispid 216;
    function JYPassSetup(Handle: Int64; const URL: WideString; const User: WideString;
                         const OPass: WideString; const NPass: WideString; var ErrCode: Integer;
                         var ErrMsg: WideString): WordBool; dispid 217;
    function PBOXLogin(Handle: Int64; const URL: WideString; const User: WideString;
                       const Pass: WideString; var ErrCode: Integer; var ErrMsg: WideString): WordBool; dispid 218;
  end;

// *********************************************************************//
// DispIntf:  IGFDataManagerEvents
// Flags:     (0)
// GUID:      {94ED172C-8112-4710-AC4B-EAFE356F00DF}
// *********************************************************************//
  IGFDataManagerEvents = dispinterface
    ['{94ED172C-8112-4710-AC4B-EAFE356F00DF}']
    function OnGFDebug(const Value: WideString): HResult; dispid 201;
    function OnGFError(const URL: WideString; const SQL: WideString; Code: Integer;
                       const Value: WideString): HResult; dispid 202;
    function OnGFLogin(Code: Integer; const Value: WideString): HResult; dispid 203;
  end;

// *********************************************************************//
// Interface: IGFData
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {726D3CA2-6373-420C-A192-FD66DB962B67}
// *********************************************************************//
  IGFData = interface(IDispatch)
    ['{726D3CA2-6373-420C-A192-FD66DB962B67}']
    function DataStatus: DataStatusEnum; safecall;
    function WaitEvent: Int64; safecall;
    function Get_WaitMode: WaitModeEnum; safecall;
    procedure Set_WaitMode(Value: WaitModeEnum); safecall;
    procedure CancelQuery; safecall;
    procedure CallDataArrive(Event: Int64); safecall;
    function Data: Int64; safecall;
    function Size: Int64; safecall;
    function Succeed: WordBool; safecall;
    function ErrorCode: Integer; safecall;
    function ErrorMsg: WideString; safecall;
    procedure Wait(WaitTime: SYSUINT); safecall;
    function Get_Tag: Int64; safecall;
    procedure Set_Tag(Value: Int64); safecall;
    property WaitMode: WaitModeEnum read Get_WaitMode write Set_WaitMode;
    property Tag: Int64 read Get_Tag write Set_Tag;
  end;

// *********************************************************************//
// DispIntf:  IGFDataDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {726D3CA2-6373-420C-A192-FD66DB962B67}
// *********************************************************************//
  IGFDataDisp = dispinterface
    ['{726D3CA2-6373-420C-A192-FD66DB962B67}']
    function DataStatus: DataStatusEnum; dispid 201;
    function WaitEvent: Int64; dispid 202;
    property WaitMode: WaitModeEnum dispid 203;
    procedure CancelQuery; dispid 204;
    procedure CallDataArrive(Event: Int64); dispid 205;
    function Data: Int64; dispid 206;
    function Size: Int64; dispid 207;
    function Succeed: WordBool; dispid 208;
    function ErrorCode: Integer; dispid 211;
    function ErrorMsg: WideString; dispid 212;
    procedure Wait(WaitTime: SYSUINT); dispid 213;
    property Tag: Int64 dispid 214;
  end;

// *********************************************************************//
// The Class CoGFDataManager provides a Create and CreateRemote method to
// create instances of the default interface IGFDataManager exposed by
// the CoClass GFDataManager. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoGFDataManager = class
    class function Create: IGFDataManager;
    class function CreateRemote(const MachineName: string): IGFDataManager;
  end;

implementation

uses System.Win.ComObj;

class function CoGFDataManager.Create: IGFDataManager;
begin
  Result := CreateComObject(CLASS_GFDataManager) as IGFDataManager;
end;

class function CoGFDataManager.CreateRemote(const MachineName: string): IGFDataManager;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_GFDataManager) as IGFDataManager;
end;

end.

