unit GilQuoteStruct;

interface

uses sysutils, QuoteStruct, QuoteConst, ansistrings, windows;

type
  // 用于判断证券使用TShareRealTimeData结构体中的哪个结构.
  TRealTime_Secu_Category = (rscSTOCK, // 沪深证券
    rscBSTOCKSH,  //上证B股
    rscBSTOCKSZ, //深证B股
    rscINDEX, // 指数
    rscHKSTOCK, // 港股
    rscFinFUTURES, //金融期货
    rscFUTURES, // 期货
    rscOPTION, // 期权
    rscIB, // 银行间证券
    rscFX, // 外汇
    rscUS, // 美股
    rscTHREEBOAD // 新三板
    );

  PStockInfo = ^TStockInfo;

  TStockInfo = packed record
    Stock: TStockInitInfo;
    FinanceIndex: integer;
    ExRightIndex: integer;
    RightCount: WORD;
  end;

  PLimitPrice = ^TLimitPrice;

  TLimitPrice = packed record
    MaxUpPrice: single;
    MinDownPrice: single;
  end;

  TStockInfos = array [0 .. MaxCount] of TStockInfo;
  PStockInfos = ^TStockInfos;

  TCommonTrendData = packed record
    Price: LongInt;
    AvgPrice: single;
    Money: single;
    Vol: UInt32;
  end;

  TIndexTrendData = packed record
    Price: LongInt;
    AdvPrice: LongInt;
    Money: single;
    Vol: UInt32;
    RiseTrend: short; // 上涨趋势
    FallTrend: short; // 下跌趋势
    RiseCount: short; // 上涨家数
    FallCount: short; // 下跌家数
    // SameCount:short; //平盘家数
    // Alignment:short; //预留 对齐
  end;

  TETFTrendData = packed record
    Price: LongInt;
    AvgPrice: LongInt;
    Money: single;
    Vol: UInt32;
    IPOV: LongInt;
  end;

  PTrendDataUnion = ^TTrendDataUnion;

  TTrendDataUnion = packed record
    case integer of
      0:
        (CommonTrendData: TCommonTrendData);
      1:
        (IndexTrendData: TIndexTrendData);
      2:
        (ETFTrendData: TETFTrendData);
  end;

  PTrendInfo = ^TTrendInfo;

  TTrendInfo = packed record
    StopFlag: LongInt; // 0交易 1停牌
    PrevClose: LongInt;
    TradeDate: LongInt;
  end;

  TQuoteCommExtData = packed record
    case integer of
      0:
        (m_StockExt: THSStockRealTimeOther); // 股票
      1:
        (m_HKStockExt: THKBSOrder); // 港股
      2:
        (m_IndexExt: THSIndexRealTimeOther); // 指数
  end;

  PQuoteRealTimeData = ^TQuoteRealTimeData;

  TQuoteRealTimeData = packed record
    StockInitInfo: PStockInitInfo;
    FinanceInfo: PFinanceInfo;
    m_othData: TStockOtherData; // 实时其它数据
    // Level
    // m_LevelothData: TLevelStockOtherData; // 实时其它数据
    // m_LevelcNowData: TLevelRealTime;      //
    VarCode: integer;
    CommExtData: TQuoteCommExtData; // 股票,港股,指数有效(港股暂时为空)
    case integer of
      0:
        (m_cNowData: TShareRealTimeData); // 指向ShareRealTimeData的任意一个
      1:
        (m_cOPTNowData: THSOPTRealTime);
  end;

  PQuoteL2RealTimeData = ^TQuoteL2RealTimeData;

  TQuoteL2RealTimeData = packed record
    // Level
    m_LevelothData: TLevelStockOtherData; // 实时其它数据
    m_LevelcNowData: TLevelRealTime; //
    VarCode: integer;
  end;

  // IQuoteColValue中Datas返回的结构指针
  PGilQuoteColValues = ^TGilQuoteColValues;

  TGilQuoteColValues = packed record
    m_CodeInfo: TCodeInfo;
    case integer of
      0:
        (IntValue: integer);
      1:
        (UIntValue: UInt);
      2:
        (SingleValue: single);
      3:
        (DoubleValue: Double);
      4:
        (Int64Value: Int64);
      5:
        (UInt64Value: UInt64);
  end;

  PGilQuoteColValue32 = ^TGilQuoteColValue32;

  TGilQuoteColValue32 = packed record
    m_CodeInfo: TCodeInfo;
    m_Value: integer;
  end;

  PGilQuoteColValue64 = ^TGilQuoteColValue64;

  TGilQuoteColValue64 = packed record
    m_CodeInfo: TCodeInfo;
    m_Value: Int64;
  end;

  PDDERealtimeData = ^TDDERealtimeData;

  TDDERealtimeData = packed record
    VarCode: integer;
    DDEBigOrderData: THDATradeClassifyData; // 龙虎看盘数据 QuoteType_DDEBigOrderRealTimeByOrder 请求得到
  end;

Function GetRealTimeSC(Codeinfo: PcodeInfo): TRealTime_Secu_Category;
function GetSharesPerHand(Codeinfo: PcodeInfo; QuoteRealTimeData: PQuoteRealTimeData): LongInt;

implementation

Function GetRealTimeSC(Codeinfo: PcodeInfo): TRealTime_Secu_Category;
begin
  if HSMarketType(Codeinfo.m_cCodeType, OTHER_MARKET) then // 指数
    Result := rscINDEX
  else if HSMarketType(Codeinfo.m_cCodeType, HK_MARKET) then // 香港
    Result := rscHKSTOCK
  else if HSMarketType(Codeinfo.m_cCodeType, OPT_MARKET) then // 个股期权
    Result := rscOPTION
  else if HSMarketType(Codeinfo.m_cCodeType, FUTURES_MARKET) then // 期货
    Result := rscFUTURES
  else if HSMarketType(Codeinfo.m_cCodeType, US_MARKET) then // 美股
    Result := rscUS
  else if HSMarketType(Codeinfo.m_cCodeType, FOREIGN_MARKET) then
  begin
    if HSBourseType(Codeinfo.m_cCodeType, YHJZQ_BOURSE) or // 银行间
      HSBourseType(Codeinfo.m_cCodeType, XHCJ_BOURSE) or HSBourseType(Codeinfo.m_cCodeType, ZYSHG_BOURSE) or
      HSBourseType(Codeinfo.m_cCodeType, MDSHG_BOURSE) then

      Result := rscIB
    else // 外汇
      Result := rscFX;
  end
  else
  begin
    if HSKindType(Codeinfo.m_cCodeType, KIND_INDEX) then // 指数
      Result := rscINDEX
    else if HSKindType(Codeinfo.m_cCodeType, KIND_THREEBOAD) then  // 三板
      Result := rscTHREEBOAD
    else// A B 股
      Result := rscSTOCK;
  end;
end;

function GetSharesPerHand(Codeinfo: PcodeInfo; QuoteRealTimeData: PQuoteRealTimeData): LongInt;
begin
  Result := 1;
  case GetRealTimeSC(Codeinfo) of
    rscSTOCK:
      Result := QuoteRealTimeData.m_cNowData.m_nowData.m_nHand; // 沪深证券
    rscINDEX:
      Result := QuoteRealTimeData.m_cNowData.m_indData.m_nHand; // 指数
    rscHKSTOCK:
      Result := QuoteRealTimeData.m_cNowData.m_hkData.m_lHand; // 港股
    rscFUTURES:
      Result := QuoteRealTimeData.m_cNowData.m_qhData.m_nHand; // 期货
    rscOPTION:
      Result := QuoteRealTimeData.m_cOPTNowData.m_nHand; // 期权
    rscIB:
      Result := 1; // 银行间证券
    rscFX:
      Result := 1; // 外汇
    rscUS:
      Result := QuoteRealTimeData.m_cNowData.m_USData.m_nHand;
    rscTHREEBOAD:
      Result := QuoteRealTimeData.m_cNowData.m_nowData.m_nHand; // 沪深证券
  end;
  if Result = 0 then
    Result := 1;
end;

end.
