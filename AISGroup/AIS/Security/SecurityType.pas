unit SecurityType;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // 证券类型
  TSecurityType = ( stHSStock,              // 沪深股票
                    stHKStock,              // 港股
                    stUSStock,              // 美股
                    stNewThirdBoardStock,   // 新三板
                    stIndex,                // 指数
                    stForeignIndex,         // 国外指数
                    stYuEBaoIndex,          // 余额宝情绪指数
                    stBond,                 // 普通债券
                    stHSBond,               // 沪深债券
                    stBuyBackBond,          // 债券回购
                    stConvertibleBond,      // 可转债
                    stInnerFund,            // 场内基金
                    stOuterCurrencyFund,    // 场外基金(货币)
                    stOuterNonCurrencyFund, // 场外基金(非货币)
                    stCommodityFutures,     // 商品期货
                    stFinancialFutures      // 金融期货
                   );

  // 融资融券类型
  TMarginType = ( mtNone,                  // 不可融资不可融券
                  mtFinance,               // 可融资
                  mtLoan,                  // 可融券
                  mtFinanceAndLoan         // 可融资可融券
                 );

  // 通类型
  TThroughType = ( ttNone,
                   ttHKSH,                 // 港股通沪
                   ttHKSZ,                 // 港股通深
                   ttHKSHSZ,               // 港股通沪深
                   ttSH,                   // 沪股通
                   ttSZ                    // 深股通
                   );

  // 上市状态
  TListedStateType = ( ltListing,                // 上市
                       ltDeListing               // 非上市
                      );


implementation

end.
