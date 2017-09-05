unit SecuMain;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SecuMain Memory Table
// Author：      lksoulman
// Date：        2017-9-2
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonObject;

type

  // 证券类型
  TSecurityType = ( stHSStock,                  // 沪深股票
                    stHKStock,                  // 港股
                    stUSStock,                  // 美股
                    stNewThirdBoardStock,       // 新三板
                    stIndex,                    // 指数
                    stForeignIndex,             // 国外指数
                    stYuEBaoIndex,              // 余额宝情绪指数
                    stBond,                     // 普通债券
                    stHSBond,                   // 沪深债券
                    stBuyBackBond,              // 债券回购
                    stConvertibleBond,          // 可转债
                    stInnerFund,                // 场内基金
                    stOuterCurrencyFund,        // 场外基金(货币)
                    stOuterNonCurrencyFund,     // 场外基金(非货币)
                    stCommodityFutures,         // 商品期货
                    stFinancialFutures          // 金融期货
                   );

  // 融资融券类型
  TMarginType = ( mtNone,                       // 不可融资不可融券
                  mtFinance,                    // 可融资
                  mtLoan,                       // 可融券
                  mtFinanceAndLoan              // 可融资可融券
                 );

  // 通类型
  TThroughType = ( ttNone,
                   ttHKSH,                      // 港股通沪
                   ttHKSZ,                      // 港股通深
                   ttHKSHSZ,                    // 港股通沪深
                   ttSH,                        // 沪股通
                   ttSZ                         // 深股通
                   );

  // 上市状态
  TListedType = ( ltListing,                    // 上市
                  ltDeListing                   // 非上市
                  );

  // SecuMain Item
  TSecuMainItem = packed record
    FIsUsed: Boolean;                           // 是不是再用
    FInnerCode: Int32;                          // 证券内码
    FSecuMarket: UInt8;                         // 证券市场
    FListedState: UInt8;                        // 上市状态
    FSecuCategory: UInt16;                      // 证券类别
    FSecuSpecialMark: UInt8;                    // 证券特殊标记(融资融券，港股通，沪股通，深股通)
    FMarginType: TMarginType;                   // 融资融券类型
    FThroughType: TThroughType;                 // 港股通，沪股通，深股通
    FSecurityType: TSecurityType;               // 证券类型
    FSecuAbbr: string;                          // 证券简称
    FSecuCode: string;                          // 证券代码
    FSecuSpell: string;                         // 证券拼音
    FSecuSuffix: string;                        // 证券后缀
    FFormerAbbr: string;                        // 证券曾用名
    FFormerSpell: string;                       // 证券曾用名拼音

    // Set Update
    function SetUpdate: boolean;
    // Get Margin
    function GetMargin: Integer;
    // Get Through
    function GetThrough: Integer;
    // Get MarginType
    function GetMarginType: TMarginType;
    // Get Through Type
    function GetThroughType: TThroughType;
    // Get Security Type
    function GetSecurityType: TSecurityType;
  end;

  // SecuMain Item Pointer
  PSecuMainItem = ^TSecuMainItem;

  // SecuMain Item Pointer Dynamic Array
  TPSecuMainItemDynArray = Array Of PSecuMainItem;

  // SecuMain Memory Table Interface
  ISecuMain = Interface(IInterface)
    ['{B0E5F129-246A-4537-A142-D745D6D1B859}']
    // Lock
    procedure Lock; safecall;
    // Un Lock
    procedure UnLock; safecall;
    // Get Item Count
    function GetItemCount: Integer; safecall;
    // Get Item
    function GetItem(AIndex: Integer): PSecuMainItem; safecall;
    // Get Item By InnerCode
    function GetItemByInnerCode(AInnerCode: Integer): PSecuMainItem; safecall;
  end;

  // SecuMain Query
  ISecuMainQuery = Interface(IInterface)
    ['{CB6B22C8-1BCF-449A-9328-8D9E85046448}']
    // Get Security By InnerCode
    function GetSecurity(AInnerCode: Integer): PSecuMainItem; safecall;
    // Get Securitys By InnerCodes
    function GetSecuritys(AInnerCodes: TIntegerDynArray; var APSecuMainItems: TPSecuMainItemDynArray): Boolean; safecall;
  end;

implementation

uses
  SecuMainConst;

{ TSecuMainItem }

function TSecuMainItem.SetUpdate: boolean;
begin
  Result := True;
end;

function TSecuMainItem.GetMargin: Integer;
var
  LMargin: UInt8;
begin
  LMargin := FSecuSpecialMark and MARGIN_MASK;
  LMargin := LMargin shr 4;
  Result := LMargin;
end;

function TSecuMainItem.GetThrough: Integer;
begin
  Result := (FSecuSpecialMark and THROUGH_MASK);
end;

function TSecuMainItem.GetMarginType: TMarginType;
begin
  Result := FMarginType;
end;

function TSecuMainItem.GetThroughType: TThroughType;
begin
  Result := FThroughType;
end;

function TSecuMainItem.GetSecurityType: TSecurityType;
begin
  Result := FSecurityType;
end;

end.
