unit QuoteMngr_TLB;

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
// File generated on 2016-09-28 15:15:28 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\Developments\GilDataTerminal\trunk\Source\Bin\Debug\GilQuoteMngr.dll (1)
// LIBID: {3EC51403-DDBB-46D4-98E6-10906B412C4D}
// LCID: 0
// Helpfile: 
// HelpString: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// Errors:
//   Hint: Parameter 'Begin' of IQuoteTrend.GetVATime changed to 'Begin_'
//   Hint: Parameter 'End' of IQuoteTrend.GetVATime changed to 'End_'
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
  QuoteMngrMajorVersion = 1;
  QuoteMngrMinorVersion = 0;

  LIBID_QuoteMngr: TGUID = '{3EC51403-DDBB-46D4-98E6-10906B412C4D}';

  IID_IQuoteManager: TGUID = '{0A825757-C955-4F84-B0BA-11B77CAD2500}';
  DIID_IQuoteManagerEvents: TGUID = '{9B851423-674B-4FCC-B0CA-70C051EEBF79}';
  CLASS_QuoteManager: TGUID = '{99611CC7-551E-4313-9C40-FD49FF9A5533}';
  IID_IQuoteMessage: TGUID = '{F3FEEF67-0BFD-41CE-900C-52FFCB140111}';
  IID_IQuoteSync: TGUID = '{AFC46AC5-B589-4A00-B618-87ED730AD720}';
  IID_IQuoteUpdate: TGUID = '{72A5BB57-6EA6-4F1D-97B2-954B4B991FB1}';
  IID_IQuoteBlock: TGUID = '{3F56E4A6-5726-4D12-B230-C6D70859DB89}';
  IID_IQuoteRealTime: TGUID = '{E02E1A77-1C55-4379-847D-BC5C4CBCC3C4}';
  IID_IQuoteReportSort: TGUID = '{33E6CE6A-E5F8-4FAD-91F8-B56F6ADF69B4}';
  IID_IQuoteGeneralSort: TGUID = '{34A550D5-5ED4-49CA-A626-AC92FA1ED1A2}';
  IID_IQuoteTrend: TGUID = '{D33C0456-F3A7-4A02-B795-D8330CFE2E12}';
  IID_IQuoteStockTick: TGUID = '{EF02C789-3D3D-4ABF-A899-1DA72EFB5758}';
  IID_IQuoteTechData: TGUID = '{CDAD30E2-C9F1-49B3-AE53-57E37B7D7729}';
  IID_IQuoteLevelTransaction: TGUID = '{ED72D8FA-2F1A-4BB3-BC62-32C835BA5465}';
  IID_IQuoteLevelOrderQueue: TGUID = '{B3EC3D0A-4DB1-4759-913C-45DA1223436F}';
  IID_IQuoteLevelTOTALMAX: TGUID = '{E6E7AE13-FA1F-467D-B9C0-9655397C02E1}';
  IID_IQuoteLevelSINGLEMA: TGUID = '{B364C3EB-C34C-4CD8-B81E-FB778B30083E}';
  IID_IQuoteCodeInfos: TGUID = '{37A75FA9-CC72-4107-A2C2-D2E92DC282C7}';
  IID_IQuoteMultiTrend: TGUID = '{4C82BEFF-787C-4B87-BDB7-A1026D251E65}';
  IID_IQuoteTrendHis: TGUID = '{9B77DC3B-B54A-4C38-A749-DE51C9E3BAC4}';
  IID_IQuoteMarketMonitor: TGUID = '{04E901D3-39EA-4BCC-AECD-A8F66C4ABFB5}';
  IID_IQuoteColValue: TGUID = '{42A9BF77-BDEB-4C3B-9BAA-082F34AC93FC}';
  IID_IQuoteDDERealTime: TGUID = '{65D81541-4A1B-4F19-94CE-248B437E297F}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum ProxyKindEnum
type
  ProxyKindEnum = TOleEnum;
const
  ProxyKind_NoProxy = $00000001;
  ProxyKind_HTTPProxy = $00000002;
  ProxyKind_SOCKS5Proxy = $00000003;
  ProxyKind_SOCKS4Proxy = $00000004;

// Constants for enum QuoteTypeEnum
type
  QuoteTypeEnum = TOleEnum;
const
  QuoteType_REALTIME = $00000001;
  QuoteType_REPORTSORT = $00000002;
  QuoteType_GENERALSORT = $00000004;
  QuoteType_TREND = $00000008;
  QuoteType_STOCKTICK = $00000010;
  QuoteType_LIMITTICK = $00000020;
  QuoteType_TECHDATA_MINUTE1 = $00000040;
  QuoteType_TECHDATA_MINUTE5 = $00000080;
  QuoteType_TECHDATA_DAY = $00000100;
  QuoteType_Level_REALTIME = $00000200;
  QuoteType_Level_TRANSACTION = $00000400;
  QuoteType_Level_ORDERQUEUE = $00000800;
  QuoteType_Level_SINGLEMA = $00001000;
  QuoteType_Level_TOTALMAX = $00002000;
  QuoteType_HISTREND = $00004000;
  QuoteType_CODEINFOS = $00008000;
  QuoteType_TECHDATA_MINUTE15 = $00010000;
  QuoteType_TECHDATA_MINUTE30 = $00020000;
  QuoteType_TECHDATA_MINUTE60 = $00040000;
  QuoteType_SingleColValue = $00080000;
  QuoteType_MarketMonitor = $00100000;
  QuoteType_LIMITPRICE = $00200000;
  QuoteType_DDEBigOrderRealTimeByOrder = $00400000;

// Constants for enum ServerTypeEnum
type
  ServerTypeEnum = TOleEnum;
const
  stStockLevelI = $00000001;
  stStockLevelII = $00000002;
  stFutues = $00000003;
  stStockHK = $00000004;
  stForeign = $00000005;
  stHKDelay = $00000006;
  stDDE = $00000007;
  stUSStock = $00000008;

// Constants for enum CodeTypeEnum
type
  CodeTypeEnum = TOleEnum;
const
  SHStock = $00000000;
  SZStock = $00000001;
  Futues_SH = $00000002;
  Futues_DL = $00000003;
  Futues_ZZ = $00000004;
  Futues_Stock = $00000005;
  HK_Stock = $00000006;
  HK_GE = $00000007;
  HK_Index = $00000008;
  Other_Stock = $00000009;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IQuoteManager = interface;
  IQuoteManagerDisp = dispinterface;
  IQuoteManagerEvents = dispinterface;
  IQuoteMessage = interface;
  IQuoteMessageDisp = dispinterface;
  IQuoteSync = interface;
  IQuoteSyncDisp = dispinterface;
  IQuoteUpdate = interface;
  IQuoteUpdateDisp = dispinterface;
  IQuoteBlock = interface;
  IQuoteBlockDisp = dispinterface;
  IQuoteRealTime = interface;
  IQuoteRealTimeDisp = dispinterface;
  IQuoteReportSort = interface;
  IQuoteReportSortDisp = dispinterface;
  IQuoteGeneralSort = interface;
  IQuoteGeneralSortDisp = dispinterface;
  IQuoteTrend = interface;
  IQuoteTrendDisp = dispinterface;
  IQuoteStockTick = interface;
  IQuoteStockTickDisp = dispinterface;
  IQuoteTechData = interface;
  IQuoteTechDataDisp = dispinterface;
  IQuoteLevelTransaction = interface;
  IQuoteLevelTransactionDisp = dispinterface;
  IQuoteLevelOrderQueue = interface;
  IQuoteLevelOrderQueueDisp = dispinterface;
  IQuoteLevelTOTALMAX = interface;
  IQuoteLevelTOTALMAXDisp = dispinterface;
  IQuoteLevelSINGLEMA = interface;
  IQuoteLevelSINGLEMADisp = dispinterface;
  IQuoteCodeInfos = interface;
  IQuoteCodeInfosDisp = dispinterface;
  IQuoteMultiTrend = interface;
  IQuoteMultiTrendDisp = dispinterface;
  IQuoteTrendHis = interface;
  IQuoteTrendHisDisp = dispinterface;
  IQuoteMarketMonitor = interface;
  IQuoteMarketMonitorDisp = dispinterface;
  IQuoteColValue = interface;
  IQuoteColValueDisp = dispinterface;
  IQuoteDDERealTime = interface;
  IQuoteDDERealTimeDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  QuoteManager = IQuoteManager;


// *********************************************************************//
// Interface: IQuoteManager
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0A825757-C955-4F84-B0BA-11B77CAD2500}
// *********************************************************************//
  IQuoteManager = interface(IDispatch)
    ['{0A825757-C955-4F84-B0BA-11B77CAD2500}']
    function ServerSetting(const IP: WideString; Port: Word; ServerType: ServerTypeEnum): WordBool; safecall;
    function ConcurrentSetting(Value: Word): WordBool; safecall;
    function Proxy1Setting(ProxyKind: ProxyKindEnum; const ProxyIP: WideString; ProxyPort: Word; 
                           const ProxyUser: WideString; const ProxyPWD: WideString): WordBool; safecall;
    function Proxy2Setting(ProxyKind: ProxyKindEnum; const ProxyIP: WideString; ProxyPort: Word; 
                           const ProxyUser: WideString; const ProxyPWD: WideString): WordBool; safecall;
    procedure ClearSetting; safecall;
    procedure StartService; safecall;
    procedure StopService; safecall;
    function Get_Active: WordBool; safecall;
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    function Subscribe(QuoteType: QuoteTypeEnum; Stocks: Int64; Count: Integer; Cookie: Integer; 
                       Value: OleVariant): WordBool; safecall;
    function QueryData(QuoteType: QuoteTypeEnum; CodeInfo: Int64): IUnknown; safecall;
    procedure Connect(ServerType: ServerTypeEnum); safecall;
    procedure Disconnect(ServerType: ServerTypeEnum); safecall;
    function Get_Connected(ServerType: ServerTypeEnum): WordBool; safecall;
    procedure LevelSetting(const User: WideString; const Pass: WideString); safecall;
    procedure SendKeepActiveTime(ServerType: ServerTypeEnum); safecall;
    function KeepActiveRecvTime(ServerType: ServerTypeEnum): Double; safecall;
    procedure ConnectServerInfo(ServerType: ServerTypeEnum; var IP: WideString; var Port: Word); safecall;
    procedure SetWorkPath(const APath: WideString); safecall;
    property Active: WordBool read Get_Active;
    property Connected[ServerType: ServerTypeEnum]: WordBool read Get_Connected;
  end;

// *********************************************************************//
// DispIntf:  IQuoteManagerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0A825757-C955-4F84-B0BA-11B77CAD2500}
// *********************************************************************//
  IQuoteManagerDisp = dispinterface
    ['{0A825757-C955-4F84-B0BA-11B77CAD2500}']
    function ServerSetting(const IP: WideString; Port: Word; ServerType: ServerTypeEnum): WordBool; dispid 201;
    function ConcurrentSetting(Value: Word): WordBool; dispid 202;
    function Proxy1Setting(ProxyKind: ProxyKindEnum; const ProxyIP: WideString; ProxyPort: Word; 
                           const ProxyUser: WideString; const ProxyPWD: WideString): WordBool; dispid 203;
    function Proxy2Setting(ProxyKind: ProxyKindEnum; const ProxyIP: WideString; ProxyPort: Word; 
                           const ProxyUser: WideString; const ProxyPWD: WideString): WordBool; dispid 204;
    procedure ClearSetting; dispid 205;
    procedure StartService; dispid 206;
    procedure StopService; dispid 207;
    property Active: WordBool readonly dispid 208;
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage); dispid 209;
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage); dispid 210;
    function Subscribe(QuoteType: QuoteTypeEnum; Stocks: Int64; Count: Integer; Cookie: Integer; 
                       Value: OleVariant): WordBool; dispid 211;
    function QueryData(QuoteType: QuoteTypeEnum; CodeInfo: Int64): IUnknown; dispid 212;
    procedure Connect(ServerType: ServerTypeEnum); dispid 213;
    procedure Disconnect(ServerType: ServerTypeEnum); dispid 214;
    property Connected[ServerType: ServerTypeEnum]: WordBool readonly dispid 215;
    procedure LevelSetting(const User: WideString; const Pass: WideString); dispid 216;
    procedure SendKeepActiveTime(ServerType: ServerTypeEnum); dispid 217;
    function KeepActiveRecvTime(ServerType: ServerTypeEnum): Double; dispid 218;
    procedure ConnectServerInfo(ServerType: ServerTypeEnum; var IP: WideString; var Port: Word); dispid 219;
    procedure SetWorkPath(const APath: WideString); dispid 220;
  end;

// *********************************************************************//
// DispIntf:  IQuoteManagerEvents
// Flags:     (4096) Dispatchable
// GUID:      {9B851423-674B-4FCC-B0CA-70C051EEBF79}
// *********************************************************************//
  IQuoteManagerEvents = dispinterface
    ['{9B851423-674B-4FCC-B0CA-70C051EEBF79}']
    function OnConnected(const IP: WideString; Port: Word; ServerType: ServerTypeEnum): HResult; dispid 201;
    function OnDisconnected(const IP: WideString; Port: Word; ServerType: ServerTypeEnum): HResult; dispid 202;
    function OnWriteLog(const Log: WideString): HResult; dispid 203;
    function OnProgress(const Msg: WideString; Max: Integer; Value: Integer): HResult; dispid 204;
  end;

// *********************************************************************//
// Interface: IQuoteMessage
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F3FEEF67-0BFD-41CE-900C-52FFCB140111}
// *********************************************************************//
  IQuoteMessage = interface(IDispatch)
    ['{F3FEEF67-0BFD-41CE-900C-52FFCB140111}']
    function Get_MsgCookie: Integer; safecall;
    procedure Set_MsgCookie(Value: Integer); safecall;
    function Get_MsgHandle: Int64; safecall;
    function Get_MsgActive: WordBool; safecall;
    procedure Set_MsgActive(Value: WordBool); safecall;
    property MsgCookie: Integer read Get_MsgCookie write Set_MsgCookie;
    property MsgHandle: Int64 read Get_MsgHandle;
    property MsgActive: WordBool read Get_MsgActive write Set_MsgActive;
  end;

// *********************************************************************//
// DispIntf:  IQuoteMessageDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F3FEEF67-0BFD-41CE-900C-52FFCB140111}
// *********************************************************************//
  IQuoteMessageDisp = dispinterface
    ['{F3FEEF67-0BFD-41CE-900C-52FFCB140111}']
    property MsgCookie: Integer dispid 201;
    property MsgHandle: Int64 readonly dispid 202;
    property MsgActive: WordBool dispid 203;
  end;

// *********************************************************************//
// Interface: IQuoteSync
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {AFC46AC5-B589-4A00-B618-87ED730AD720}
// *********************************************************************//
  IQuoteSync = interface(IDispatch)
    ['{AFC46AC5-B589-4A00-B618-87ED730AD720}']
    procedure BeginRead; safecall;
    procedure EndRead; safecall;
  end;

// *********************************************************************//
// DispIntf:  IQuoteSyncDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {AFC46AC5-B589-4A00-B618-87ED730AD720}
// *********************************************************************//
  IQuoteSyncDisp = dispinterface
    ['{AFC46AC5-B589-4A00-B618-87ED730AD720}']
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteUpdate
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {72A5BB57-6EA6-4F1D-97B2-954B4B991FB1}
// *********************************************************************//
  IQuoteUpdate = interface(IDispatch)
    ['{72A5BB57-6EA6-4F1D-97B2-954B4B991FB1}']
    procedure Update(DataType: Integer; Data: Int64; Size: Integer); safecall;
    procedure BeginWrite; safecall;
    procedure EndWrite; safecall;
    function DataState(State: Integer; var IValue: Int64; var SValue: WideString; 
                       var VValue: OleVariant): WideString; safecall;
  end;

// *********************************************************************//
// DispIntf:  IQuoteUpdateDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {72A5BB57-6EA6-4F1D-97B2-954B4B991FB1}
// *********************************************************************//
  IQuoteUpdateDisp = dispinterface
    ['{72A5BB57-6EA6-4F1D-97B2-954B4B991FB1}']
    procedure Update(DataType: Integer; Data: Int64; Size: Integer); dispid 201;
    procedure BeginWrite; dispid 202;
    procedure EndWrite; dispid 203;
    function DataState(State: Integer; var IValue: Int64; var SValue: WideString; 
                       var VValue: OleVariant): WideString; dispid 204;
  end;

// *********************************************************************//
// Interface: IQuoteBlock
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3F56E4A6-5726-4D12-B230-C6D70859DB89}
// *********************************************************************//
  IQuoteBlock = interface(IDispatch)
    ['{3F56E4A6-5726-4D12-B230-C6D70859DB89}']
    function Get_BlockItem(Block: Integer): Integer; safecall;
    function Get_Blocks: Integer; safecall;
    property BlockItem[Block: Integer]: Integer read Get_BlockItem;
    property Blocks: Integer read Get_Blocks;
  end;

// *********************************************************************//
// DispIntf:  IQuoteBlockDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3F56E4A6-5726-4D12-B230-C6D70859DB89}
// *********************************************************************//
  IQuoteBlockDisp = dispinterface
    ['{3F56E4A6-5726-4D12-B230-C6D70859DB89}']
    property BlockItem[Block: Integer]: Integer readonly dispid 201;
    property Blocks: Integer readonly dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteRealTime
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E02E1A77-1C55-4379-847D-BC5C4CBCC3C4}
// *********************************************************************//
  IQuoteRealTime = interface(IQuoteSync)
    ['{E02E1A77-1C55-4379-847D-BC5C4CBCC3C4}']
    function Get_Codes(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_Finances(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_ExRights(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_Datas(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_CodeToKeyIndex(CodeType: Word; const Code: WideString): Integer; safecall;
    function Get_PrevClose(CodeType: Word; const Code: WideString): Integer; safecall;
    function GetStockTypeInfo(CodeType: Word): Int64; safecall;
    function GetInitDate(CodeType: Word): Int64; safecall;
    function GetCodeInfoByKeyStr(const Key: WideString; out CodeInfo: Int64): WordBool; safecall;
    function GetLimitPrice(CodeType: Word; const Code: WideString): Int64; safecall;
    function Get_LevelDatas(CodeType: Smallint; const Code: WideString): Int64; safecall;
    function GetCodeInfoByName(AName: string; out CodeInfo: Int64): WordBool; safecall;
    procedure SetUpdateConceptCodesEvent(AFunc: TNotifyEvent); safecall;

    property Codes[CodeType: Word; const Code: WideString]: Int64 read Get_Codes;
    property Finances[CodeType: Word; const Code: WideString]: Int64 read Get_Finances;
    property ExRights[CodeType: Word; const Code: WideString]: Int64 read Get_ExRights;
    property Datas[CodeType: Word; const Code: WideString]: Int64 read Get_Datas;
    property CodeToKeyIndex[CodeType: Word; const Code: WideString]: Integer read Get_CodeToKeyIndex;
    property PrevClose[CodeType: Word; const Code: WideString]: Integer read Get_PrevClose;
    property LevelDatas[CodeType: Smallint; const Code: WideString]: Int64 read Get_LevelDatas;
    property OnUpdateConceptCodes: TNotifyEvent write SetUpdateConceptCodesEvent;
  end;

// *********************************************************************//
// DispIntf:  IQuoteRealTimeDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E02E1A77-1C55-4379-847D-BC5C4CBCC3C4}
// *********************************************************************//
  IQuoteRealTimeDisp = dispinterface
    ['{E02E1A77-1C55-4379-847D-BC5C4CBCC3C4}']
    property Codes[CodeType: Word; const Code: WideString]: Int64 readonly dispid 301;
    property Finances[CodeType: Word; const Code: WideString]: Int64 readonly dispid 302;
    property ExRights[CodeType: Word; const Code: WideString]: Int64 readonly dispid 303;
    property Datas[CodeType: Word; const Code: WideString]: Int64 readonly dispid 304;
    property CodeToKeyIndex[CodeType: Word; const Code: WideString]: Integer readonly dispid 305;
    property PrevClose[CodeType: Word; const Code: WideString]: Integer readonly dispid 306;
    function GetStockTypeInfo(CodeType: Word): Int64; dispid 307;
    function GetInitDate(CodeType: Word): Int64; dispid 309;
    function GetCodeInfoByKeyStr(const Key: WideString; out CodeInfo: Int64): WordBool; dispid 308;
    function GetLimitPrice(CodeType: Word; const Code: WideString): Int64; dispid 310;
    property LevelDatas[CodeType: Smallint; const Code: WideString]: Int64 readonly dispid 311;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteReportSort
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {33E6CE6A-E5F8-4FAD-91F8-B56F6ADF69B4}
// *********************************************************************//
  IQuoteReportSort = interface(IQuoteSync)
    ['{33E6CE6A-E5F8-4FAD-91F8-B56F6ADF69B4}']
    function Get_SortType: Integer; safecall;
    function Get_Count: Integer; safecall;
    function Get_Data: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    property SortType: Integer read Get_SortType;
    property Count: Integer read Get_Count;
    property Data: Int64 read Get_Data;
    property VarCode: Integer read Get_VarCode;
  end;

// *********************************************************************//
// DispIntf:  IQuoteReportSortDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {33E6CE6A-E5F8-4FAD-91F8-B56F6ADF69B4}
// *********************************************************************//
  IQuoteReportSortDisp = dispinterface
    ['{33E6CE6A-E5F8-4FAD-91F8-B56F6ADF69B4}']
    property SortType: Integer readonly dispid 301;
    property Count: Integer readonly dispid 302;
    property Data: Int64 readonly dispid 303;
    property VarCode: Integer readonly dispid 304;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteGeneralSort
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {34A550D5-5ED4-49CA-A626-AC92FA1ED1A2}
// *********************************************************************//
  IQuoteGeneralSort = interface(IQuoteSync)
    ['{34A550D5-5ED4-49CA-A626-AC92FA1ED1A2}']
    function Get_Count: Integer; safecall;
    function Get_Data: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    property Count: Integer read Get_Count;
    property Data: Int64 read Get_Data;
    property VarCode: Integer read Get_VarCode;
  end;

// *********************************************************************//
// DispIntf:  IQuoteGeneralSortDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {34A550D5-5ED4-49CA-A626-AC92FA1ED1A2}
// *********************************************************************//
  IQuoteGeneralSortDisp = dispinterface
    ['{34A550D5-5ED4-49CA-A626-AC92FA1ED1A2}']
    property Count: Integer readonly dispid 302;
    property Data: Int64 readonly dispid 303;
    property VarCode: Integer readonly dispid 304;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteTrend
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D33C0456-F3A7-4A02-B795-D8330CFE2E12}
// *********************************************************************//
  IQuoteTrend = interface(IQuoteSync)
    ['{D33C0456-F3A7-4A02-B795-D8330CFE2E12}']
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_IndexToTime(Index: Integer): Integer; safecall;
    function Get_TimeCount: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    function TimeToIndex(Time: Integer): Integer; safecall;
    function GetTrendInfo: Int64; safecall;
    function Get_VADatas: Int64; safecall;
    function Get_VADataCount: Integer; safecall;
    procedure GetVATime(var Begin_: Integer; var End_: Integer); safecall;
    function IsVAData: WordBool; safecall;
    property Datas: Int64 read Get_Datas;
    property Count: Integer read Get_Count;
    property VarCode: Integer read Get_VarCode;
    property IndexToTime[Index: Integer]: Integer read Get_IndexToTime;
    property TimeCount: Integer read Get_TimeCount;
    property CodeInfo: Int64 read Get_CodeInfo;
    property VADatas: Int64 read Get_VADatas;
    property VADataCount: Integer read Get_VADataCount;
  end;

// *********************************************************************//
// DispIntf:  IQuoteTrendDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D33C0456-F3A7-4A02-B795-D8330CFE2E12}
// *********************************************************************//
  IQuoteTrendDisp = dispinterface
    ['{D33C0456-F3A7-4A02-B795-D8330CFE2E12}']
    property Datas: Int64 readonly dispid 301;
    property Count: Integer readonly dispid 302;
    property VarCode: Integer readonly dispid 303;
    property IndexToTime[Index: Integer]: Integer readonly dispid 304;
    property TimeCount: Integer readonly dispid 305;
    property CodeInfo: Int64 readonly dispid 306;
    function TimeToIndex(Time: Integer): Integer; dispid 308;
    function GetTrendInfo: Int64; dispid 307;
    property VADatas: Int64 readonly dispid 309;
    property VADataCount: Integer readonly dispid 310;
    procedure GetVATime(var Begin_: Integer; var End_: Integer); dispid 311;
    function IsVAData: WordBool; dispid 312;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteStockTick
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EF02C789-3D3D-4ABF-A899-1DA72EFB5758}
// *********************************************************************//
  IQuoteStockTick = interface(IQuoteSync)
    ['{EF02C789-3D3D-4ABF-A899-1DA72EFB5758}']
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_IndexToTime(Index: Integer): Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    property Datas: Int64 read Get_Datas;
    property Count: Integer read Get_Count;
    property VarCode: Integer read Get_VarCode;
    property IndexToTime[Index: Integer]: Integer read Get_IndexToTime;
    property CodeInfo: Int64 read Get_CodeInfo;
  end;

// *********************************************************************//
// DispIntf:  IQuoteStockTickDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EF02C789-3D3D-4ABF-A899-1DA72EFB5758}
// *********************************************************************//
  IQuoteStockTickDisp = dispinterface
    ['{EF02C789-3D3D-4ABF-A899-1DA72EFB5758}']
    property Datas: Int64 readonly dispid 301;
    property Count: Integer readonly dispid 302;
    property VarCode: Integer readonly dispid 303;
    property IndexToTime[Index: Integer]: Integer readonly dispid 304;
    property CodeInfo: Int64 readonly dispid 305;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteTechData
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CDAD30E2-C9F1-49B3-AE53-57E37B7D7729}
// *********************************************************************//
  IQuoteTechData = interface(IQuoteSync)
    ['{CDAD30E2-C9F1-49B3-AE53-57E37B7D7729}']
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    property Datas: Int64 read Get_Datas;
    property Count: Integer read Get_Count;
    property VarCode: Integer read Get_VarCode;
    property CodeInfo: Int64 read Get_CodeInfo;
  end;

// *********************************************************************//
// DispIntf:  IQuoteTechDataDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CDAD30E2-C9F1-49B3-AE53-57E37B7D7729}
// *********************************************************************//
  IQuoteTechDataDisp = dispinterface
    ['{CDAD30E2-C9F1-49B3-AE53-57E37B7D7729}']
    property Datas: Int64 readonly dispid 301;
    property Count: Integer readonly dispid 302;
    property VarCode: Integer readonly dispid 303;
    property CodeInfo: Int64 readonly dispid 304;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteLevelTransaction
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {ED72D8FA-2F1A-4BB3-BC62-32C835BA5465}
// *********************************************************************//
  IQuoteLevelTransaction = interface(IQuoteSync)
    ['{ED72D8FA-2F1A-4BB3-BC62-32C835BA5465}']
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    property Datas: Int64 read Get_Datas;
    property Count: Integer read Get_Count;
    property VarCode: Integer read Get_VarCode;
    property CodeInfo: Int64 read Get_CodeInfo;
  end;

// *********************************************************************//
// DispIntf:  IQuoteLevelTransactionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {ED72D8FA-2F1A-4BB3-BC62-32C835BA5465}
// *********************************************************************//
  IQuoteLevelTransactionDisp = dispinterface
    ['{ED72D8FA-2F1A-4BB3-BC62-32C835BA5465}']
    property Datas: Int64 readonly dispid 301;
    property Count: Integer readonly dispid 302;
    property VarCode: Integer readonly dispid 303;
    property CodeInfo: Int64 readonly dispid 304;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteLevelOrderQueue
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B3EC3D0A-4DB1-4759-913C-45DA1223436F}
// *********************************************************************//
  IQuoteLevelOrderQueue = interface(IQuoteSync)
    ['{B3EC3D0A-4DB1-4759-913C-45DA1223436F}']
    function Get_BuyData: Int64; safecall;
    function Get_SellData: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    property BuyData: Int64 read Get_BuyData;
    property SellData: Int64 read Get_SellData;
    property VarCode: Integer read Get_VarCode;
    property CodeInfo: Int64 read Get_CodeInfo;
  end;

// *********************************************************************//
// DispIntf:  IQuoteLevelOrderQueueDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B3EC3D0A-4DB1-4759-913C-45DA1223436F}
// *********************************************************************//
  IQuoteLevelOrderQueueDisp = dispinterface
    ['{B3EC3D0A-4DB1-4759-913C-45DA1223436F}']
    property BuyData: Int64 readonly dispid 301;
    property SellData: Int64 readonly dispid 302;
    property VarCode: Integer readonly dispid 303;
    property CodeInfo: Int64 readonly dispid 304;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteLevelTOTALMAX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E6E7AE13-FA1F-467D-B9C0-9655397C02E1}
// *********************************************************************//
  IQuoteLevelTOTALMAX = interface(IDispatch)
    ['{E6E7AE13-FA1F-467D-B9C0-9655397C02E1}']
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    property Datas: Int64 read Get_Datas;
    property Count: Integer read Get_Count;
    property VarCode: Integer read Get_VarCode;
    property CodeInfo: Int64 read Get_CodeInfo;
  end;

// *********************************************************************//
// DispIntf:  IQuoteLevelTOTALMAXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E6E7AE13-FA1F-467D-B9C0-9655397C02E1}
// *********************************************************************//
  IQuoteLevelTOTALMAXDisp = dispinterface
    ['{E6E7AE13-FA1F-467D-B9C0-9655397C02E1}']
    property Datas: Int64 readonly dispid 201;
    property Count: Integer readonly dispid 202;
    property VarCode: Integer readonly dispid 203;
    property CodeInfo: Int64 readonly dispid 204;
  end;

// *********************************************************************//
// Interface: IQuoteLevelSINGLEMA
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B364C3EB-C34C-4CD8-B81E-FB778B30083E}
// *********************************************************************//
  IQuoteLevelSINGLEMA = interface(IDispatch)
    ['{B364C3EB-C34C-4CD8-B81E-FB778B30083E}']
    function Get_Datas: Int64; safecall;
    function Get_Count: Integer; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_CodeInfo: Int64; safecall;
    property Datas: Int64 read Get_Datas;
    property Count: Integer read Get_Count;
    property VarCode: Integer read Get_VarCode;
    property CodeInfo: Int64 read Get_CodeInfo;
  end;

// *********************************************************************//
// DispIntf:  IQuoteLevelSINGLEMADisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B364C3EB-C34C-4CD8-B81E-FB778B30083E}
// *********************************************************************//
  IQuoteLevelSINGLEMADisp = dispinterface
    ['{B364C3EB-C34C-4CD8-B81E-FB778B30083E}']
    property Datas: Int64 readonly dispid 201;
    property Count: Integer readonly dispid 202;
    property VarCode: Integer readonly dispid 203;
    property CodeInfo: Int64 readonly dispid 204;
  end;

// *********************************************************************//
// Interface: IQuoteCodeInfos
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {37A75FA9-CC72-4107-A2C2-D2E92DC282C7}
// *********************************************************************//
  IQuoteCodeInfos = interface(IDispatch)
    ['{37A75FA9-CC72-4107-A2C2-D2E92DC282C7}']
    function Get_CodeInfos(CodeType: CodeTypeEnum; out Count: Integer): Int64; safecall;
    property CodeInfos[CodeType: CodeTypeEnum; out Count: Integer]: Int64 read Get_CodeInfos;
  end;

// *********************************************************************//
// DispIntf:  IQuoteCodeInfosDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {37A75FA9-CC72-4107-A2C2-D2E92DC282C7}
// *********************************************************************//
  IQuoteCodeInfosDisp = dispinterface
    ['{37A75FA9-CC72-4107-A2C2-D2E92DC282C7}']
    property CodeInfos[CodeType: CodeTypeEnum; out Count: Integer]: Int64 readonly dispid 201;
  end;

// *********************************************************************//
// Interface: IQuoteMultiTrend
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4C82BEFF-787C-4B87-BDB7-A1026D251E65}
// *********************************************************************//
  IQuoteMultiTrend = interface(IQuoteSync)
    ['{4C82BEFF-787C-4B87-BDB7-A1026D251E65}']
    function Count: Integer; safecall;
    function Get_Datas(Index: Integer): IQuoteTrend; safecall;
    property Datas[Index: Integer]: IQuoteTrend read Get_Datas;
  end;

// *********************************************************************//
// DispIntf:  IQuoteMultiTrendDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4C82BEFF-787C-4B87-BDB7-A1026D251E65}
// *********************************************************************//
  IQuoteMultiTrendDisp = dispinterface
    ['{4C82BEFF-787C-4B87-BDB7-A1026D251E65}']
    function Count: Integer; dispid 203;
    property Datas[Index: Integer]: IQuoteTrend readonly dispid 204;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteTrendHis
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9B77DC3B-B54A-4C38-A749-DE51C9E3BAC4}
// *********************************************************************//
  IQuoteTrendHis = interface(IQuoteTrend)
    ['{9B77DC3B-B54A-4C38-A749-DE51C9E3BAC4}']
    procedure ResetDate(ADate: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  IQuoteTrendHisDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9B77DC3B-B54A-4C38-A749-DE51C9E3BAC4}
// *********************************************************************//
  IQuoteTrendHisDisp = dispinterface
    ['{9B77DC3B-B54A-4C38-A749-DE51C9E3BAC4}']
    procedure ResetDate(ADate: Integer); dispid 401;
    property Datas: Int64 readonly dispid 301;
    property Count: Integer readonly dispid 302;
    property VarCode: Integer readonly dispid 303;
    property IndexToTime[Index: Integer]: Integer readonly dispid 304;
    property TimeCount: Integer readonly dispid 305;
    property CodeInfo: Int64 readonly dispid 306;
    function TimeToIndex(Time: Integer): Integer; dispid 308;
    function GetTrendInfo: Int64; dispid 307;
    property VADatas: Int64 readonly dispid 309;
    property VADataCount: Integer readonly dispid 310;
    procedure GetVATime(var Begin_: Integer; var End_: Integer); dispid 311;
    function IsVAData: WordBool; dispid 312;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteMarketMonitor
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {04E901D3-39EA-4BCC-AECD-A8F66C4ABFB5}
// *********************************************************************//
  IQuoteMarketMonitor = interface(IQuoteSync)
    ['{04E901D3-39EA-4BCC-AECD-A8F66C4ABFB5}']
    function Count: Integer; safecall;
    function Get_Datas: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    property Datas: Int64 read Get_Datas;
    property VarCode: Integer read Get_VarCode;
  end;

// *********************************************************************//
// DispIntf:  IQuoteMarketMonitorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {04E901D3-39EA-4BCC-AECD-A8F66C4ABFB5}
// *********************************************************************//
  IQuoteMarketMonitorDisp = dispinterface
    ['{04E901D3-39EA-4BCC-AECD-A8F66C4ABFB5}']
    function Count: Integer; dispid 301;
    property Datas: Int64 readonly dispid 30;
    property VarCode: Integer readonly dispid 303;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteColValue
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {42A9BF77-BDEB-4C3B-9BAA-082F34AC93FC}
// *********************************************************************//
  IQuoteColValue = interface(IQuoteSync)
    ['{42A9BF77-BDEB-4C3B-9BAA-082F34AC93FC}']
    function Count: Integer; safecall;
    function Get_Datas: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_ColCode: Integer; safecall;
    property Datas: Int64 read Get_Datas;
    property VarCode: Integer read Get_VarCode;
    property ColCode: Integer read Get_ColCode;
  end;

// *********************************************************************//
// DispIntf:  IQuoteColValueDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {42A9BF77-BDEB-4C3B-9BAA-082F34AC93FC}
// *********************************************************************//
  IQuoteColValueDisp = dispinterface
    ['{42A9BF77-BDEB-4C3B-9BAA-082F34AC93FC}']
    function Count: Integer; dispid 301;
    property Datas: Int64 readonly dispid 302;
    property VarCode: Integer readonly dispid 303;
    property ColCode: Integer readonly dispid 304;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// Interface: IQuoteDDERealTime
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {65D81541-4A1B-4F19-94CE-248B437E297F}
// *********************************************************************//
  IQuoteDDERealTime = interface(IQuoteSync)
    ['{65D81541-4A1B-4F19-94CE-248B437E297F}']
    function Datas(CodeType: Word; const Code: WideString): Int64; safecall;
  end;

// *********************************************************************//
// DispIntf:  IQuoteDDERealTimeDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {65D81541-4A1B-4F19-94CE-248B437E297F}
// *********************************************************************//
  IQuoteDDERealTimeDisp = dispinterface
    ['{65D81541-4A1B-4F19-94CE-248B437E297F}']
    function Datas(CodeType: Word; const Code: WideString): Int64; dispid 301;
    procedure BeginRead; dispid 201;
    procedure EndRead; dispid 202;
  end;

// *********************************************************************//
// The Class CoQuoteManager provides a Create and CreateRemote method to          
// create instances of the default interface IQuoteManager exposed by              
// the CoClass QuoteManager. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoQuoteManager = class
    class function Create: IQuoteManager;
    class function CreateRemote(const MachineName: string): IQuoteManager;
  end;

implementation

uses System.Win.ComObj;

class function CoQuoteManager.Create: IQuoteManager;
begin
  Result := CreateComObject(CLASS_QuoteManager) as IQuoteManager;
end;

class function CoQuoteManager.CreateRemote(const MachineName: string): IQuoteManager;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_QuoteManager) as IQuoteManager;
end;

end.