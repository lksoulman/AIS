unit AppStatus;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º App Status Bar Data Interface
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

  // App Hq Status Item Pointer
  PAppHqItem = ^TAppHqItem;

  // App News Status Item
  TAppNewsItem = packed record
    FId: Integer;
    FTitle: string;
    FDateTime: TDateTime;
  end;

  // App News Status Item Pointer
  PAppNewsItem = ^TAppNewsItem;

  // App User Status Item
  TAppUserItem = packed record
    FUserName: string;
  end;

  // App User Status Item Pointer
  PAppUserItem = ^TAppUserItem;

  // App HqServer Status Item
  TAppNetworkItem = packed record
  end;

  // App HqServer Status Item
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
    // Get L Hq Status Item Count
    function GetLHqItemCount: Integer;
    // Get R Hq Status Item Count
    function GetRHqItemCount: Integer;
    // Get L Hq Status Item
    function GetLHqItem(AIndex: Integer): PAppHqItem;
    // Get R Hq Status Item
    function GetRHqItem(AIndex: Integer): PAppHqItem;
    // Get User Status Item
    function GetUserItem: PAppUserItem;
    // Get HqServer Status Item Count
    function GetNetworkItemCount: Integer;
    // Get HqServer Status Item
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


end.
