unit AppStatus;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º App Status Interface
// Author£º      lksoulman
// Date£º        2017-11-1
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext;

type

   // App Hq Item
  TAppHqItem = packed record
    FInnerCode: Integer;      // Secu InnerCode
    FSecuAbbr: string;        // Secu Abbr
    FSecuInfo: string;        // Secu Info
    FNowPrice: Double;        // Now Price
    FPreClose: Double;        // Prev Price
    FTurnover: Double;        // Turnover

    function GetTurnover: string;
    function GetNowPriceHL: string;
    function GetColorValue: Integer;
  end;

  // App Hq Item Pointer
  PAppHqItem = ^TAppHqItem;

  // App News Item
  TAppNewsItem = packed record
    FId: Integer;
    FTitle: string;
    FDateTime: TDateTime;
  end;

  // App News Item Pointer
  PAppNewsItem = ^TAppNewsItem;

  // App User Item
  TAppUserItem = packed record
    FUserName: string;
  end;

  // App User Item Pointer
  PAppUserItem = ^TAppUserItem;

  // App Time Item
  TAppTimeItem = packed record
    FCurrentTime: TDateTime;

    function GetCurrentTime: string;
  end;

  // App Time Item Pointer
  PAppTimeItem = ^TAppTimeItem;

  // App HqServer Item
  TAppNetworkItem = packed record
  end;

  // App HqServer Item
  PAppNetworkItem = ^TAppNetworkItem;

  IAppStatus = interface(IInterface)
    ['{B1DD119C-AA1F-411D-9A22-F177BF71F864}']
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
    // Lock
    procedure NewsLock;
    // Un Lock
    procedure NewsUnLock;
    // Get L Hq Item Count
    function GetLHqItemCount: Integer;
    // Get R Hq Item Count
    function GetRHqItemCount: Integer;
    // Get L Hq Item
    function GetLHqItem(AIndex: Integer): PAppHqItem;
    // Get R Hq Item
    function GetRHqItem(AIndex: Integer): PAppHqItem;
    // Get User Item
    function GetUserItem: PAppUserItem;
    // Get Time Item
    function GetTimeItem: PAppTimeItem;
    // Get HqServer Item Count
    function GetNetworkItemCount: Integer;
    // Get HqServer Item
    function GetNetworkItem(AIndex: Integer): PAppNetworkItem;
  end;

implementation

uses
  Math;

{ TAppHqItem }

function TAppHqItem.GetTurnover: string;
begin
  Result := '-';
end;

function TAppHqItem.GetNowPriceHL: string;
begin
  Result := '- - -';
end;

function TAppHqItem.GetColorValue: Integer;
begin
  Result := CompareValue(FNowPrice, FPreClose, 0.000001);
end;


{ TAppTimeItem }

function TAppTimeItem.GetCurrentTime: string;
begin
  FCurrentTime := Now;
  Result := Format('CN %s', [FormatDateTime('MM-DD hh:nn:ss', FCurrentTime)]);
end;

end.
