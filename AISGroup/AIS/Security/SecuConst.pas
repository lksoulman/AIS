unit SecuConst;

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
  SysUtils,
  SecurityType;

const
  // 聚源证券市场分类
  // SELECT DISTINCT SecuCategory FROM SecuMain ORDER BY SecuCategory
  GILDATA_SECUMARKET_SHFE      = 10;  // 上海期货交易所(Shanghai futures exchange)	10
  GILDATA_SECUMARKET_DLME      = 13;  // 大连商品交易所(Dalian Mercantile Exchange)	13
  GILDATA_SECUMARKET_ZZME      = 15;  // 郑州商品交易所(Zhengzhou Mercantile Exchange)	15
  GILDATA_SECUMARKET_ASX       = 49;  // 澳大利亚证券交易所(Australian Stock Exchange)	49
  GILDATA_SECUMARKET_NZSE      = 50;  // 新西兰证券交易所(New Zealand Stock Exchange)	50
  GILDATA_SECUMARKET_CFFE      = 51;  // 中国金融期货交易所(China Financial Futures Exchange)	51
  GILDATA_SECUMARKET_ECASE     = 52;  // 埃及开罗及亚历山大证券交易所(Egypt, Cairo and Alexander Stock Exchange)	52
  GILDATA_SECUMARKET_ABASE     = 54;  // 阿根廷布宜诺斯艾利斯证券交易所(Buenos Aires stock exchange of Argentina)	54
  GILDATA_SECUMARKET_BSPSE     = 55;  // 巴西圣保罗证券交易所(St Paul stock exchange of Brazil)	55
  GILDATA_SECUMARKET_MSE       = 56;  // 墨西哥证券交易所(Mexican Stock Exchange)	56
  GILDATA_SECUMARKET_MKLSE     = 57;  // 马来西亚吉隆坡证券交易所(Kuala Lumpur stock exchange of Malaysia)	57
  GILDATA_SECUMARKET_JOSE      = 58;  // 日本大阪证券交易所(Osaka stock exchange, Japan)	58
  GILDATA_SECUMARKET_ISE       = 65;  // 印度尼西亚证券交易所(Indonesia Stock Exchange)	65
  GILDATA_SECUMARKET_TSE       = 66;  // 泰国证券交易所(The Stock Exchange of Thailand)	66
  GILDATA_SECUMARKET_SSE       = 67;  // 韩国首尔证券交易所(Seoul Stock Exchange)	67
  GILDATA_SECUMARKET_TKSE      = 68;  // 东京证券交易所(The Tokyo Stock Exchange)	68
  GILDATA_SECUMARKET_SPSE      = 69;  // 新加坡证券交易所(Singapore Stock Exchange)	69
  GILDATA_SECUMARKET_TWSE      = 70;  // 台湾证券交易所(Taiwan Stock Exchange)	70
  GILDATA_SECUMARKET_OTCM      = 71;  // 柜台交易市场(Over-the-counter market)	71
  GILDATA_SECUMARKET_HKSE      = 72;  // 香港联交所(Hongkong Stock Exchange)	72
  GILDATA_SECUMARKET_PM        = 73;  // 一级市场(Primary Market)	73
  GILDATA_SECUMARKET_GIM       = 74;  // 聚源指数市场(GILDATA index market)	74
  GILDATA_SECUMARKET_AOE       = 75;  // 亚洲其他交易所(Other exchanges in Asia)	75
  GILDATA_SECUMARKET_ASE       = 76;  // 美国证券交易所	76
  GILDATA_SECUMARKET_NSE       = 77;  // 美国纳斯达克证券交易所(Nasdaq Stock Exchange)	77
  GILDATA_SECUMARKET_NYSE      = 78;  // 纽约证券交易所(New York stock exchange)	78
  GILDATA_SECUMARKET_USAOTM    = 79;  // 美国其他交易市场(Other trading markets in the United States)	79
  GILDATA_SECUMARKET_CTSE      = 80;  // 加拿大多伦多证券交易所(Toronto stock exchange, Canada)	80
  GILDATA_SECUMARKET_TBM       = 81;  // 三板市场(Third board Market)	81
  GILDATA_SECUMARKET_SHSE      = 83;  // 上海证券交易所(Shanghai Stock Exchange)	83
  GILDATA_SECUMARKET_OTM       = 84;  // 其他市场(OTHER Market)	84
  GILDATA_SECUMARKET_LSE       = 85;  // 伦敦证券交易所(London Stock Exchange)	85
  GILDATA_SECUMARKET_FPSE      = 86;  // 法国巴黎证券交易所(Paris stock exchange, France)	86
  GILDATA_SECUMARKET_GFSE      = 87;  // 德国法兰克福证券交易所(Frankfurt stock exchange, Germany)	87
  GILDATA_SECUMARKET_OEE       = 88;  // 欧洲其他交易所(Other European exchanges)	88
  GILDATA_SECUMARKET_IBBM      = 89;  // 银行间债券市场(Interbank bond market)	89
  GILDATA_SECUMARKET_SZSE      = 90;  // 深圳证券交易所(Shenzhen Stock Exchange)	90
  GILDATA_SECUMARKET_OTCBB     = 91;  // 美国OTCBB市场	91
  GILDATA_SECUMARKET_OOTC      = 92;  // 美国OtherOTC市场	92
  GILDATA_SECUMARKET_SHIBLM    = 93;  // 上海银行间同业拆借市场(Shanghai interbank lending market)	93
  GILDATA_SECUMARKET_SSSE      = 94;  // 瑞士证券交易所(Swiss Stock Exchange)	94
  GILDATA_SECUMARKET_HLASE     = 95;  // 荷兰阿姆斯特丹证券交易所(Amsterdam stock exchange of Holland)	95
  GILDATA_SECUMARKET_JSE       = 96;  // 约翰内斯堡证券交易所(Johannesburg Stock Exchange)	96
  GILDATA_SECUMARKET_LIFOE     = 97;  // 伦敦国际金融期货期权交易所(London International Financial Futures Options Exchange)	97
  GILDATA_SECUMARKET_NYSEE     = 98;  // 纽约泛欧证券交易所(NYSE Euronext)	98
  GILDATA_SECUMARKET_TKIBLM    = 99;  // 东京同业拆借市场(Tokyo interbank lending market)	99
  GILDATA_SECUMARKET_LIBLM     = 101; // 伦敦银行同业拆借市场(London interbank lending market)	101
  GILDATA_SECUMARKET_HKIBLM    = 102; // 香港银行同业拆借市场(Hongkong interbank lending market)	102
  GILDATA_SECUMARKET_SIBLM     = 103; // 新加坡银行同业拆借市场(Interbank lending market in Singapore)	103
  GILDATA_SECUMARKET_CIBLM     = 104; // 中国银行同业拆借市场(China interbank lending market)	104
  GILDATA_SECUMARKET_EIBLM     = 105; // 欧元银行同业拆借市场(Euro interbank lending market)	105
  GILDATA_SECUMARKET_BSE       = 106; // 布鲁塞尔证券交易所(Brussels Stock Exchange)	106
  GILDATA_SECUMARKET_JKSE      = 107; // 雅加达证券交易所(Jakarta Stock Exchange)	107
  GILDATA_SECUMARKET_JPTM      = 109; // 日本佳斯达克交易市场(Japan's trading market)	109
  GILDATA_SECUMARKET_TASE      = 110; // 特拉维夫证券交易所(Tel-Aviv Stock Exchange)	110
  GILDATA_SECUMARKET_LBSE      = 120; // 卢森堡证券交易所(Luxemburg Stock Exchange)120
  GILDATA_SECUMARKET_BMSE      = 130; // 百慕大证券交易所(Bermuda Stock Exchange)	130
  GILDATA_SECUMARKET_PSE       = 140; // 布拉格证券交易所(Prague Stock Exchange)	140
  GILDATA_SECUMARKET_FHSE      = 160; // 芬兰赫尔辛基证券交易所(Helsinki stock exchange of Finland)	160
  GILDATA_SECUMARKET_ITSE      = 161; // 意大利证券交易所(Italy Stock Exchange)	161
  GILDATA_SECUMARKET_CSE       = 162; // 哥本哈根证券交易所(Copenhagen Stock Exchange)	162
  GILDATA_SECUMARKET_OB        = 180; // 挪威奥斯陆证券交易所(Oslo Bors)	180
  GILDATA_SECUMARKET_SKKE      = 190; // 韩国科斯达克交易所(South Korea kosda exchange)	190
  GILDATA_SECUMARKET_SLSE      = 200; // 斯德哥尔摩证券交易所(stockholm stock exchange)	200
  GILDATA_SECUMARKET_WSE       = 201; // 华沙证券交易所(Warsaw Stock Exchange)	201
  GILDATA_SECUMARKET_IBSE      = 202; // 伊斯坦布尔证券交易所(Istanbul Stock Exchange)	202
  GILDATA_SECUMARKET_INSE      = 210; // 印度国家证券交易所(National stock exchange of India)	210
  GILDATA_SECUMARKET_SGSE      = 220; // 圣地亚哥证券交易所(Santiago Stock Exchange)	220
  GILDATA_SECUMARKET_AVSE      = 230; // 奥地利维也纳证券交易所(Vienna stock exchange of Austria)	230
  GILDATA_SECUMARKET_MDSE      = 240; // 西班牙马德里证券交易所(Madrid Stock Exchange)	240
  GILDATA_SECUMARKET_GAES      = 250; // 希腊雅典证券交易所(Athens stock exchange, Greece)	250
  GILDATA_SECUMARKET_ISSE      = 260; // 爱尔兰证券交易所(Irish stock exchange)	260
  GILDATA_SECUMARKET_TWSCM     = 270; // 台湾证券柜台买卖市场(Taiwan securities counter market)	270
  GILDATA_SECUMARKET_PPSE      = 280; // 菲律宾证券交易所(Philippines Stock Exchange)	280
  GILDATA_SECUMARKET_BBSE      = 290; // 印度孟买证券交易所(Bombay Stock Exchange)	290
  GILDATA_SECUMARKET_AAPSE     = 300; // 澳大利亚亚太证券交易所(Australia Asia Pacific Stock Exchange)	300
  GILDATA_SECUMARKET_IAPP      = 310; // 机构间私募产品报价与服务系统(Inter agency private products pricing and service system)	310
  GILDATA_SECUMARKET_RMSE      = 320; // 俄罗斯莫斯科证券交易所(Russian Moscow Stock Exchange)	320
  GILDATA_SECUMARKET_SHHKM     = 330; // 沪港通联合市场(Shanghai and Hong Kong through the joint market)	330
  GILDATA_SECUMARKET_SZGKM     = 340; // 深港通联合市场(Shenzhen and Hong Kong joint market)	340
  GILDATA_SECUMARKET_HKSM      = 350; // 港股通联合市场(Hong Kong stocks through the joint market)	350

  // 聚源证券类型
  // SELECT DISTINCT SecuMarket FROM SecuMain ORDER BY SecuMarket
  GILDATA_SECUCATEGORY_A_STOCK                        = 1;  // A股	1
  GILDATA_SECUCATEGORY_B_STOCK                        = 2;  // B股	2
  GILDATA_SECUCATEGORY_H_STOCK                        = 3;  // H股	3
  GILDATA_SECUCATEGORY_INDEX                          = 4;  // 大盘	4
  GILDATA_SECUCATEGORY_BUYBACK                        = 5;  // 国债回购	5
  GILDATA_SECUCATEGORY_NATIONALDEBT_CRSH              = 6;  // 国债现货	6
  GILDATA_SECUCATEGORY_FINANCIAL_BOND                 = 7;  // 金融债券	7
  GILDATA_SECUCATEGORY_OPEN_FUND                      = 8;  // 开放式基金	8
  GILDATA_SECUCATEGORY_CONVERTIBLE_BOND               = 9;  // 可转换债券	9
  GILDATA_SECUCATEGORY_OTHER                          = 10; // 其他	10
  GILDATA_SECUCATEGORY_ENTERPRISE_BOND                = 11; // 企业债券	11
  GILDATA_SECUCATEGORY_ENTERPRISE_BUYBACK             = 12; // 企业债券回购	12
  GILDATA_SECUCATEGORY_INVESTMENT_FUND                = 13; // 投资基金	13
  GILDATA_SECUCATEGORY_CENTRAL_BANK_BILL              = 14; // 央行票据	14
  GILDATA_SECUCATEGORY_SZ_PROXY_SH_STOCK              = 15; // 深市代理沪市股票
  GILDATA_SECUCATEGORY_SH_PROXY_SZ_STOCK              = 16; // 沪市代理深市股票
  GILDATA_SECUCATEGORY_ASSET_BACKED                   = 17; // 资产支持证券	17     // bond
  GILDATA_SECUCATEGORY_ASSET_SECURITIZATION_PRODUCTS  = 18; // 资产证券化产品	18   // bond
  GILDATA_SECUCATEGORY_BUYOUT_REPO                    = 19; // 买断式回购	19       // repo
  GILDATA_SECUCATEGORY_DERIVATIVE_WARRANT             = 20; // 衍生权证	20         // 权证
  GILDATA_SECUCATEGORY_EQUITY_WARRANT                 = 21; // 股本权证	21
  GILDATA_SECUCATEGORY_STOCK_IN_FUTURES               = 22; // 股指期货	22
  GILDATA_SECUCATEGORY_COMMERCIAL_BANK_DEPOSIT        = 23; // 商业银行定期存款	23   // 存款
  GILDATA_SECUCATEGORY_OTHER_STOCK                    = 24; // 其他股票	24           //股票
  GILDATA_SECUCATEGORY_OX_BEAR_CERTIFICATE            = 25; // 牛熊证	25             // 权证
  GILDATA_SECUCATEGORY_INCOME_GROWTH_LINE             = 26; // 收益增长线	26
  GILDATA_SECUCATEGORY_NEW_PLEDGED_REPO               = 27; // 新质押式回购	27       // 回购
  GILDATA_SECUCATEGORY_LOCAL_GOVENMENT_DEBT           = 28; // 地方政府债	28         // bond
  GILDATA_SECUCATEGORY_EXCHANGE_BOND                  = 29; // 可交换公司债	29       // bond
  GILDATA_SECUCATEGORY_LENDING                        = 30; // 拆借	30               // 拆借
  GILDATA_SECUCATEGORY_CREDIT_RISK_MITIGATION_VOUCHER = 31; // 信用风险缓释凭证	31
  GILDATA_SECUCATEGORY_FLOATING_INTEREST_RATE         = 32; // 浮息债计息基准利率	32
  GILDATA_SECUCATEGORY_TIME_DEPOSIT_CERTIFICATE       = 33; // 定期存款凭证	33       ///  存款
  GILDATA_SECUCATEGORY_STOCK_OPTION                   = 34; // 个股期权	34           //  期权
  GILDATA_SECUCATEGORY_LARGE_DEPOSIT_CERTIFICATE      = 35; // 大额存款凭证	35       ///  存款
  GILDATA_SECUCATEGORY_STOCK_HK                       = 51; // 港股	51               // stock
  GILDATA_SECUCATEGORY_STAPLED_SECURITIES             = 52; // 合订证券	52
  GILDATA_SECUCATEGORY_STOCK_RED_CHIPS                = 53; // 红筹股	53             // stock
  GILDATA_SECUCATEGORY_PREFERRED_STOCK                = 55; // 优先股	55                          // stock
  GILDATA_SECUCATEGORY_FUND                           = 60; // 基金	60                            // fund
  GILDATA_SECUCATEGORY_TRUST_FUND                     = 61; // 信托基金	61                        // fund
  GILDATA_SECUCATEGORY_ETF_FUND                       = 62; // ETF基金	62                        // fund
  GILDATA_SECUCATEGORY_PARTICIPATION_CERTIFICATE      = 63; // 参与证书	63
  GILDATA_SECUCATEGORY_LEVER_AND_REVERSE_PRODUCTS     = 64; // 杠杆及反向产品	64
  GILDATA_SECUCATEGORY_DEBT_SECURITIES                = 65; // 债务证券	65
  GILDATA_SECUCATEGORY_EXCHANGE_FUND_BILL             = 66; // 基金票据	66                        // bond
  GILDATA_SECUCATEGORY_AMERICAN_SECURITIES            = 69; // 美国证券(交易试验计划)	69
  GILDATA_SECUCATEGORY_ORDINARY_DEPOSITARY_RECEIPT    = 71; // 普通预托证券	71
  GILDATA_SECUCATEGORY_PRE_PREFERRED_SECURITIES       = 72; // 优先预托证券	72
  GILDATA_SECUCATEGORY_STOCK                          = 73; // 股票	73
  GILDATA_SECUCATEGORY_COMMON_STOCK                   = 74; // 普通股	74
  GILDATA_SECUCATEGORY_AMERICAN_DEPOSITARY_RECEIP     = 75; // 美国存托股票（ADS）	75

  // 融资融券常量
  GILDATA_MARGIN_NONE                       = 0;  // 不可融资不可融券
  GILDATA_MARGIN_FINANCE                    = 10; // 可融资
  GILDATA_MARGIN_LOAN                       = 20; // 可融券
  GILDATA_MARGIN_FINANCE_AND_LOAN           = 30; // 可融资可融券

  // 港股通标识常量
  GIlDATA_THROUGH_NONE                      = 0;   // 无通标志
  GIlDATA_THROUGH_HK_SH                     = 1;   // 港股通沪
  GIlDATA_THROUGH_SH                        = 2;   // 沪股通
  GIlDATA_THROUGH_SZ                        = 3;   // 深股通
  GIlDATA_THROUGH_HK_SZ                     = 4;   // 港股通深
  GIlDATA_THROUGH_HK_SH_SZ                  = 5;   // 港股通(沪深)

  // 固定内码证券
  GIlDATA_INNERCODE_YUEBAO                  = 64119;

  // 上市状态
  GIlDATA_LISTING                           = 1;  //上市	1
  GIlDATA_PRE_LISTING                       = 2;  //预上市	2
  GIlDATA_STOP                              = 3;  //暂停	3
  GIlDATA_LISTING_FAILURE                   = 4;  //上市失败	4
  GIlDATA_TERMINATED                        = 5;  //终止	5
  GIlDATA_OTHER                             = 9;  //其他	9
  GIlDATA_TRADING                           = 10; //交易	10
  GIlDATA_SUSPENDED                         = 11; //停牌	11
  GIlDATA_DELIST                            = 12; //摘牌	12

////////////////////////////////////////////////////////////////////////////////

  // 融资融券常量
  MARGIN_NONE                               = $00; // 不可融资不可融券
  MARGIN_FINANCE                            = $01; // 可融资
  MARGIN_LOAN                               = $02; // 可融券
  MARGIN_FINANCE_AND_LOAN                   = $03; // 可融资可融券
  MARGIN_MASK                               = $0F; // 掩码

  // 港股通标识常量
  THROUGH_NONE                              = $00; // 无通标志
  THROUGH_HK_SH                             = $10; // 港股通沪
  THROUGH_SH                                = $20; // 沪股通
  THROUGH_SZ                                = $30; // 深股通
  THROUGH_HK_SZ                             = $40; // 港股通深
  THROUGH_HK_SH_SZ                          = $50; // 港股通(沪深)
  THROUGH_MASK                              = $F0; // 掩码

  //

type

  TGildataUtil = class
  public
    // 融资转化
    class function ValueConvertMargin(AInt: Integer): Byte;
    // 通转化
    class function ValueConvertThrough(AInt: Integer): Byte;
    // 转换融资融券类型
    class function ValueConvertMarginType(AMargin: Integer): TMarginType;
    // 转换通类型
    class function ValueConvertThroughType(AThrough: Integer): TThroughType;
    // 转换上市状态
    class function ValueConvertListedStateType(AListedState: Integer): TListedStateType;
    // 转化类型
    class function ValueConvertSecurityType(AInnerCode, ASecuMarket, ASecuCategory: Integer): TSecurityType;
  end;

implementation

{ TGildataUtil }

class function TGildataUtil.ValueConvertMargin(AInt: Integer): Byte;
begin
  case AInt of
    GILDATA_MARGIN_FINANCE:
      begin
        Result := MARGIN_FINANCE;
      end;
    GILDATA_MARGIN_LOAN:
      begin
        Result := MARGIN_LOAN;
      end;
    GILDATA_MARGIN_FINANCE_AND_LOAN:
      begin
        Result := MARGIN_FINANCE_AND_LOAN;
      end;
  else
    Result := MARGIN_NONE;
  end;
end;

class function TGildataUtil.ValueConvertThrough(AInt: Integer): Byte;
begin
  case AInt of
    GIlDATA_THROUGH_HK_SH:
      begin
        Result := THROUGH_HK_SH;
      end;
    GIlDATA_THROUGH_SH:
      begin
        Result := THROUGH_SH;
      end;
    GIlDATA_THROUGH_SZ:
      begin
        Result := THROUGH_SZ;
      end;
    GIlDATA_THROUGH_HK_SZ:
      begin
        Result := THROUGH_HK_SZ;
      end;
    GIlDATA_THROUGH_HK_SH_SZ:
      begin
        Result := THROUGH_HK_SH_SZ;
      end;
  else
    Result := THROUGH_NONE;
  end;
end;

class function TGildataUtil.ValueConvertMarginType(AMargin: Integer): TMarginType;
begin
  case AMargin of
    MARGIN_FINANCE:
      begin
        Result := mtFinance;
      end;
    MARGIN_LOAN:
      begin
        Result := mtLoan;
      end;
    MARGIN_FINANCE_AND_LOAN:
      begin
        Result := mtFinanceAndLoan;
      end;
  else
    Result := mtNone;
  end;
end;

class function TGildataUtil.ValueConvertThroughType(AThrough: Integer): TThroughType;
begin
  case AThrough of
    THROUGH_HK_SH:
      begin
        Result := ttHKSH;
      end;
    THROUGH_SH:
      begin
        Result := ttSH;
      end;
    THROUGH_SZ:
      begin
        Result := ttSZ;
      end;
    THROUGH_HK_SZ:
      begin
        Result := ttHKSZ;
      end;
    THROUGH_HK_SH_SZ:
      begin
        Result := ttHKSHSZ;
      end;
  else
    Result := ttNone;
  end;
end;

class function TGildataUtil.ValueConvertSecurityType(AInnerCode, ASecuMarket,
  ASecuCategory: Integer): TSecurityType;
begin
  case ASecuCategory of
    1, 2:
      begin
        if ASecuMarket = 81 then begin
          Result := stNewThirdBoardStock;
        end else begin
          Result := stHSStock;
        end;
      end;
    3, 20, 21, 25, 51, 52, 53, 55, 63, 65, 71, 72:
      begin
        Result := stHKStock;
      end;
    4, 910, 920:
      begin
        if AInnerCode = GIlDATA_INNERCODE_YUEBAO then begin
          Result := stYuEBaoIndex;
        end else begin
          case ASecuMarket of
            49, 50, 52, 54, 55, 56, 57, 58, 65, 66,
            67, 68, 69, 70, 72, 75, 76, 77, 78, 79,
            80, 85, 86, 87, 88, 94, 95, 98, 106, 107,
            109, 110, 120, 130, 140, 160, 161, 162, 180, 190,
            200, 201, 210, 220, 230, 240, 250, 260, 270, 280,
            290, 300, 320:
              Result := stForeignIndex;
          else
            Result := stIndex;
          end;
        end;
      end;
    61, 62, 82, 84, 85, 86, 1301, 1302:
      begin
        Result := stInnerFund;
      end;
    81:
      begin
        Result := stOuterNonCurrencyFund;
      end;
    83:
      begin
        Result := stOuterCurrencyFund;
      end;
    6, 7, 11, 14, 18, 17, 28:
      begin
        if (ASecuMarket = 83) or (ASecuMarket =90) then begin
          Result := stHSBond;
        end else begin
          Result := stBond;
        end;
      end;
    5, 12, 19, 27:
      begin
        if (ASecuMarket = 83) or (ASecuMarket =90) then begin
          Result := stBuyBackBond;
        end;
      end;
    9, 29:
      begin
        Result := stConvertibleBond;
      end;
    801, 802:
      begin
        Result := stCommodityFutures;
      end;
    803, 804:
      begin
        Result := stFinancialFutures;
      end;
  else
    Result := stHSStock;
  end;
end;

class function TGildataUtil.ValueConvertListedStateType(AListedState: Integer): TListedStateType;
begin
  if (AListedState = GIlDATA_LISTING)
    or (AListedState = GIlDATA_TRADING)
    or (AListedState = GIlDATA_SUSPENDED) then begin
    Result := ltListing;
  end else begin
    Result := ltDeListing;
  end;
end;

end.

