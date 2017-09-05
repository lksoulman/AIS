unit QuoteBusiness;

interface

uses Windows, Classes, SysUtils, QuoteService, QuoteConst, QuoteStruct,
  IOCPMemory, QDOMarketMonitor, QDOSingleColValue, QDODDERealTime,
  QuoteLibrary, IniFiles, QuoteDataMngr, QuoteMngr_TLB, BizPacket2Impl;

type
  TOnActiveMessage = procedure(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeysIndex: int64) of object;
  TOnActiveMessageCookie = procedure(SendType: QuoteTypeEnum; Cookie: integer) of object;
  TOnResetMessage = procedure(ServerType: ServerTypeEnum) of object;

  // 业务层的请求与解包
  TQuoteBusiness = class
  private
    FQuoteService: TQuoteService;
    FQuoteDataMngr: TQuoteDataMngr;

    FOnActiveMessage: TOnActiveMessage;
    FOnResetMessage: TOnResetMessage;
    FOnActiveMessageCookie: TOnActiveMessageCookie;

    FIsInitial: boolean;

    procedure WriteFile(const FileName: string; buff: Pointer; Size: integer);
    procedure ReadFile(const FileName: string; var buff: Pointer; var Size: integer);
    procedure DoActiveMessage(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeysIndex: int64);
    procedure DoActiveMessageCookie(SendType: QuoteTypeEnum; Cookie: integer);
    procedure DoResetMessage(ServerType: ServerTypeEnum);
    procedure UpdateCommRealTime(CommRealTimeData: PCommRealTimeData; Count: integer; Codes: PCodeInfos);

    // 实时
    procedure UpdateCommRealTime_EXT(CommRealTimeData_Ext: PCommRealTimeData_Ext; Count: integer; Codes: PCodeInfos);

    procedure UpdateCommLevelRealTime(RealTimeDataLevel: PRealTimeDataLevel; Count: integer; Codes: PCodeInfos);

    function GetAskData(p: PCodeInfo): PAskData;
    function GetCodeInfos(p: PCodeInfo; Count: integer): PCodeInfo;
    function GetKeyIndex(p: PCodeInfo): integer;
  public
    constructor Create(QuoteService: TQuoteService; QuoteDataMngr: TQuoteDataMngr);
    destructor Destroy; override;

    // 多线程 调用 处理业务分支
    procedure DoHandleBusiness(pData: Pointer; Size: integer);
    // 数据到达通知事件
    property OnActiveMessage: TOnActiveMessage read FOnActiveMessage write FOnActiveMessage;
    // 初始化通知事件
    property OnResetMessage: TOnResetMessage read FOnResetMessage write FOnResetMessage;
    property OnActiveMessageCookie: TOnActiveMessageCookie read FOnActiveMessageCookie write FOnActiveMessageCookie;
    // 主站信息
    procedure AnsServerInfo(AnsServerInfo: PAnsServerInfo);

    // 用户期货登陆 请求
    procedure ReqFutuesUserLogin;
    // 用户登陆 应答
    procedure AnsFutuesUserLogin(AnsLogin: PAnsLogin);

    // 用户港股登陆 请求
    procedure ReqHKUserLogin;
    // 用户登陆 应答
    procedure AnsHKUserLogin(AnsLogin: PAnsLogin);
    // 用户登陆 请求
    procedure ReqUserLogin;
    // 用户登陆 应答
    procedure AnsUserLogin(AnsLogin: PAnsLogin);
    // DDE登陆请求
    procedure ReqDDEUserLogin();
    // DDE登陆应答
    procedure AnsDDEUserLogin(AnsLogin: PAnsLogin);
    // 美股登陆请求
    procedure ReqUSStockUserLogin();
    // 美股登陆应答
    procedure AnsUSStockUserLogin(AnsLogin: PAnsLogin);

    // 保活通信 请求
    procedure ReqKeepActive(ServerType: ServerTypeEnum);
    // 保活通信 应答
    procedure AnsKeepActive(AnsTestSrvData: PTestSrvData);

    // 初始化主站信息 请求
    procedure ReqInitialInfo(ServerType: ServerTypeEnum);
    // 初始化主站信息 应答
    procedure AnsInitialInfo(AnsInitialData: PAnsInitialData);

    // 最新的财务数据 请求
    procedure ReqCurrentFinance;
    // 最新的财务数据 应答
    procedure AnsCurrentFinance(AnsTextData: PAnsTextData);

    // 最新的财务数据 文件载入
    procedure LoadCurrentFinance; overload;
    // 最新的财务数据 内存载入
    procedure LoadCurrentFinance(Data: Pointer; Size: integer); overload;

    // 除权数据 请求
    procedure ReqExRightData;
    // 除权数据 应答
    procedure AnsExRightData(AnsTextData: PAnsTextData); overload;

    // 除权数据 文件载入
    procedure LoadExRight; overload;
    // 除权数据 内存载入
    procedure LoadExRight(Data: Pointer; Size: integer); overload;

    // 板块数据 请求
    procedure ReqBlockData(ServerType: ServerTypeEnum);
    // 板块数据 应答
    procedure AnsBlockData(AnsTextData: PAnsTextData);

    procedure LoadBlockData;

    // 报价牌  请求
    procedure ReqRealTime(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // 报价牌  应答
    procedure AnsRealTime(AnsRealTime: PAnsRealTime);

    // 扩展实时报价(主要用于个股期权,沪深ETF)  请求
    procedure ReqRealTime_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // 扩展实时报价(主要用于个股期权,沪深ETF)   应答
    procedure AnsRealTime_Ext(AnsRealTime_Ext: PAnsRealTime_Ext);

    // 实时推送  请求
    procedure ReqAutoPush(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // 实时推送  应答
    procedure AnsAutoPush(AnsRealTime: PAnsRealTime);

    // 实时推送扩展  请求
    procedure ReqAutoPush_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // 实时推送扩展  应答
    procedure AnsAutoPush_Ext(AnsRealTime: PAnsRealTime_Ext);

    // 延时推送扩展  请求
    procedure ReqDelayAutoPush_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // 延时推送扩展  应答
    procedure AnsDelayAutoPush_Ext(AnsRealTime: PAnsRealTime_Ext);

    // 个股分时  请求
    procedure ReqTrend(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // 个股分时  应答
    procedure AnsTrend(AnsTrendData: PAnsTrendData);

    // 个股分时  请求
    procedure ReqTrend_Ext(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // 个股分时  应答
    procedure AnsTrend_Ext(AnsTrendData: PAnsTrendData_Ext);

    // ---------------------沪深指数相关-------------------------------------------
    // 指数领先分时  请求
    procedure ReqMILeadData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // 指数领先分时  应答
    procedure AnsMILeadData(AnsLeadData: PAnsLeadData);
    // 指数分时  请求
    procedure ReqMITickData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // 指数分时  应答
    procedure AnsMITickData(AnsMajorIndexTick: PAnsMajorIndexTick);

    // 个股历史分时  请求
    procedure ReqHisTrend(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; Date, key: LongInt);
    // 个股历史分时  应答
    procedure AnsHisTrend(AnsHisTrend: PAnsHisTrend);

    // 个股集合竞价数据 请求
    procedure ReqVirtualAuction(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // 个股集合竞价数据 应答
    procedure AnsVirtualAuction(AnsVirtualAuction: PAnsVirtualAuction);

    // 个股分笔  请求
    procedure ReqStockTick(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // 个股分笔  应答
    procedure AnsStockTick(AnsStockTick: PAnsStockTick);

    // 指定长度 个股分笔  请求
    procedure ReqLimitTick(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; Limit: Word);
    // 指定长度  个股分笔  应答
    procedure AnsLimitTick(AnsStockTick: PAnsStockTick);

    // 盘后分析数据 请求
    procedure ReqTechData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; TechData: IQuoteUpdate; Period: short;
      nDay: Word);
    // 盘后分析数据 应答
    procedure AnsTechData(AnsDayDataEx: PAnsDayDataEx);
    // 涨跌停数据 请求
    procedure ReqSeverCalculate(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
    // 涨跌停数据 应答
    procedure AnsSeverCalculate(AnsSeverCalculate: PAnsSeverCalculate);
    // 报价牌 排序 请求
    procedure ReqPeportSort(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer; Cookie: integer;
      ReqReportSort: PReqReportSort);
    // 报价牌 排序 应答
    procedure AnsPeportSort(AnsReportData: PAnsReportData);

    // 综合排名 请求
    procedure ReqGeneralSortEx(ServerType: ServerTypeEnum; Cookie: integer; GeneralSortEx: PReqGeneralSortEx);
    // 综合排名 应答
    procedure AnsGeneralSortEx(AnsGeneralSortEx: PAnsGeneralSortEx);

    // procedure ReqMarketEvent(ServerType: ServerTypeEnum;Cookie: integer);
    // procedure AnsMaretEvent(AnsMarketEvent:PAnsMarketEvent);
    procedure ReqMarketEventAutoPush(ServerType: ServerTypeEnum);
    procedure AnsMaretEventAutoPush(AnsMarketEvent: PAnsMarketEvent);

    // -- Level2

    // 用户登陆level2 请求
    procedure ReqLevelUserLogin;
    // 用户登陆level2 应答
    procedure AnsLevelUserLogin(AnsLogin: PAnsLogin);

    // Level2十档行情  请求
    procedure ReqLevelRealTime(CodeInfos: PCodeInfos; Count: integer);
    // Level2十档行情   应答
    procedure AnsLevelRealTime(LevelRealTime: PAnsHSAutoPushLevel);

    // 实时推送 Level2  请求
    procedure ReqAutoPushLevelRealTime(CodeInfos: PCodeInfos; Count: integer);
    // 实时推送  Level2 应答
    procedure AnsAutoPushLevelRealTime(LevelRealTime: PAnsHSAutoPushLevel);

    // Level2 逐笔成交  请求
    procedure ReqLevelTransaction(CodeInfo: PCodeInfo; nSize, nPostion: integer);

    procedure AnsLevelTransaction(LevelTransaction: PAnsLevelTransaction);

    // 实时推送 Level2  逐笔成交  请求
    procedure ReqAutoPushLevelTransaction(CodeInfos: PCodeInfos; Count: integer);
    // 实时推送  Level2 逐笔成交  应答
    procedure AnsAutoPushLevelTransaction(LevelTransactionAuto: PAnsLevelTransactionAuto);

    // Level2 盘口数据  请求
    procedure ReqLevelOrderQueue(CodeInfo: PCodeInfo; direct: AnsiChar);
    // Level2 盘口数据   应答
    procedure AnsLevelOrderQueue(QueryOrderQueue: PAnsQueryOrderQueue);

    // 实时推送 Level2  盘口数据  请求
    procedure ReqAutoPushLevelOrderQueue(CodeInfos: PCodeInfos; Count: integer; direct: AnsiChar);

    // 实时推送  Level2 盘口数据  应答
    procedure AnsAutoPushLevelOrderQueue(LevelOrderQueueAuto: PAnsLevelOrderQueueAuto);

    // LEVEL2单笔撤单主推排名  LEVEL2累计撤单主推排名
    procedure ReqLevelCancel(CodeInfo: PCodeInfo; direct: AnsiChar);
    procedure AnsLevelCancelSINGLEMA(AnsHsLevelCancelOrder: PAnsHsLevelCancelOrder);
    procedure AnsLevelCancelTOTALMAX(AnsHsLevelCancelOrder: PAnsHsLevelCancelOrder);

    procedure ReqAutoPushLevelCancel(CodeInfo: PCodeInfo; direct: AnsiChar);

    // 订阅短线精灵主推
    procedure ReqAutoPushMarketEvent(ServerType: ServerTypeEnum);

    procedure AnsAutoPushMarketEvent(pData: PAnsMarketEvent);
    // 订阅单列数据用于排序
    procedure ReqSingleHQColValue(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count, ColCode: UInt;
      Cookie: integer);
    procedure AnsSingleHQColValue(pData: PAnsHQColValue);

    // 个股龙虎看盘
    // 龙虎看盘
    procedure ReqHDA_TradeClassify_ByOrder(CodeInfo: PCodeInfo; Count, ClassifyView: integer);
    procedure AnsHDA_TradeClassify_ByOrder(AnsTradeClassify: PAnsTradeClassify_HDA);
    // 龙虎看盘 主推
    procedure ReqAutoPushHDA_TradeClassify_ByOrder(CodeInfos: PCodeInfos; ClassifyView: integer; Count: integer);
    procedure AnsAutoPushHDA_TradeClassify_ByOrder(AnsTradeClassify: PAnsTradeClassify_HDA);

    // 银行间债券  登陆请求
    procedure ReqForeignUserLogin;
    // 银行间债券 登陆应答
    procedure AnsForeignUserLogin(AnsLogin: PAnsLogin);

    // 银行间债券  分时请求
    procedure ReqIBTREND(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // 银行间债券 分时应答
    procedure AnsIBTREND(AnsIBTrendData: PAnsIBTrendData);

    // 银行间债券  日内行情
    procedure ReqForeignTRANS(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
    // 银行间债券 日内行情应答              ReqIBTrans
    procedure AnsForeignTRANS(AnsIBTransData: PAnsIBTransData);

    // 银行间债券  K线行情
    procedure ReqForeignTECHDATA(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; TechData: IQuoteUpdate; Period: short;
      nDay: Word);
    procedure AnsForeignTECHDATA(AnsIBTechData: PAnsIBTechData);

    // 银行间债券 基础信息
    procedure ReqForeignBASEINFO(ServerType: ServerTypeEnum);
    procedure AnsForeignBASEINFO(AnsIBBondBaseInfoData: PAnsIBBondBaseInfoData);
  end;

function PeriodToQuoteType(Period: ULONG): QuoteTypeEnum;

implementation

function PeriodToQuoteType(Period: ULONG): QuoteTypeEnum;
begin
  case Period of
    PERIOD_TYPE_MINUTE1:
      Result := QuoteType_TECHDATA_MINUTE1; // 分析周期：1分钟
    PERIOD_TYPE_MINUTE5:
      Result := QuoteType_TECHDATA_MINUTE5; // 分析周期：5分钟
    PERIOD_TYPE_MINUTE15:
      Result := QuoteType_TECHDATA_MINUTE15;
    PERIOD_TYPE_MINUTE30:
      Result := QuoteType_TECHDATA_MINUTE30;
    PERIOD_TYPE_MINUTE60:
      Result := QuoteType_TECHDATA_MINUTE60;
    // PERIOD_TYPE_WEEK: Result := QuoteType_TECHDATA_WEEK;
    // PERIOD_TYPE_MONTH: Result := QuoteType_TECHDATA_MONTH;
  else
    Result := QuoteType_TECHDATA_DAY;
  end;
end;
{ TQuoteBusiness }

constructor TQuoteBusiness.Create(QuoteService: TQuoteService; QuoteDataMngr: TQuoteDataMngr);
begin
  FQuoteService := QuoteService;
  FQuoteDataMngr := QuoteDataMngr;
end;

destructor TQuoteBusiness.Destroy;
begin
  inherited Destroy;
end;

function TQuoteBusiness.GetAskData(p: PCodeInfo): PAskData;
begin
  // Result := GetMemory();
  GetMemEx(Pointer(Result), SizeOf(TAskData));
  FillMemory(Pointer(Result), SizeOf(TAskData), 0);
  if p <> nil then
    Result.m_nPrivateKey.m_pCode := p^;
end;

function TQuoteBusiness.GetCodeInfos(p: PCodeInfo; Count: integer): PCodeInfo;
var
  len: Cardinal;
begin
  len := SizeOf(TCodeInfo) * Count;
  GetMemEx(Pointer(Result), len);
  CopyMemory(Result, p, len);
end;

function TQuoteBusiness.GetKeyIndex(p: PCodeInfo): integer;
begin
  // Result := -1;
  Result := FQuoteDataMngr.QuoteRealTime.CodeToKeyIndex[p.m_cCodeType, CodeInfoToCode(p)];
end;

procedure TQuoteBusiness.DoHandleBusiness(pData: Pointer; Size: integer);
var
  pHead: PDataHead;
begin
  pHead := PDataHead(pData);
  // 暂时处理2类报文
  case pHead^.m_nType of
    RT_INITIALINFO:
      begin // 初始化市场信息
        // 注意,初始化信息,(沪深二市9:00左右会分别发送二次)
        AnsInitialInfo(PAnsInitialData(pHead));
      end;
    RT_LOGIN:
      begin // 用户登陆
        AnsUserLogin(PAnsLogin(pHead));
      end;
    RT_Login_DDE:
      begin
        AnsDDEUserLogin(PAnsLogin(pHead));
      end;
    RT_LOGIN_US:
      begin
        AnsUSStockUserLogin(PAnsLogin(pHead));
      end;
    RT_LOGIN_FUTURES:
      begin // 用户登陆
        AnsFutuesUserLogin(PAnsLogin(pHead));
      end;
    RT_LOGIN_HK:
      begin
        AnsHKUserLogin(PAnsLogin(pHead));
      end;
    RT_LOGIN_FOREIGN:
      AnsForeignUserLogin(PAnsLogin(pHead));
    RT_SERVERINFO:
      AnsServerInfo(PAnsServerInfo(pHead));
    RT_SEVER_CALCULATE:
      AnsSeverCalculate(PAnsSeverCalculate(pHead));
    RT_LOGIN_LEVEL, RT_DISCONNLEVEL2:
      begin
        AnsLevelUserLogin(PAnsLogin(pHead));
      end;

    RT_CURRENTFINANCEDATA or $0010:
      begin // 最新财务数据
        AnsCurrentFinance(PAnsTextData(pHead));
      end;
    RT_EXRIGHT_DATA or $0010:
      begin // 复权数据
        AnsExRightData(PAnsTextData(pHead));
      end;
    RT_BLOCK_DATA:
      begin // 板块数据
        AnsBlockData(PAnsTextData(pHead));
      end;
    RT_REALTIME:
      begin // 报价数据
        AnsRealTime(PAnsRealTime(pHead));
      end;
    RT_REALTIME_EXT: // 扩展 报价数据
      begin
        AnsRealTime_Ext(PAnsRealTime_Ext(pHead));
      end;
    RT_AUTOPUSH:
      begin // 实时主推
        AnsAutoPush(PAnsRealTime(pHead));
      end;
    RT_AUTOPUSH_EXT: // 扩展主推
      AnsAutoPush_Ext(PAnsRealTime_Ext(pHead));
    RT_AUTOPUSH_EXT_DELAY:
      AnsDelayAutoPush_Ext(PAnsRealTime_Ext(pHead));
    RT_TESTSRV:
      begin // 心跳
        AnsKeepActive(PTestSrvData(pHead));
      end;
    RT_TREND:
      begin // 分时走势
        AnsTrend(PAnsTrendData(pHead));
      end;
    RT_TREND_EXT:
      begin // 分时走势
        AnsTrend_Ext(PAnsTrendData_Ext(pHead));
      end;
    RT_HISTREND:
      begin
        AnsHisTrend(PAnsHisTrend(pHead));
      end;
    RT_MAJORINDEXTICK:
      AnsMITickData(PAnsMajorIndexTick(pHead));
    RT_LEAD:
      AnsMILeadData(PAnsLeadData(pHead));
    RT_VIRTUAL_AUCTION:
      AnsVirtualAuction(PAnsVirtualAuction(pHead)); // 集合竞价分时数据
    RT_MARKET_MONITOR_AUTOPUSH:
      AnsAutoPushMarketEvent(PAnsMarketEvent(pHead)); // 短线精灵主推
    RT_HQCOL_VALUE:
      AnsSingleHQColValue(PAnsHQColValue(pHead)); // 取单列行情数据
    RT_STOCKTICK:
      begin // 个股分笔
        AnsStockTick(PAnsStockTick(pHead));
      end;
    RT_LIMITTICK:
      begin // 限制个数 取个股分笔
        AnsLimitTick(PAnsStockTick(pHead));
      end;
    RT_TECHDATA, RT_TECHDATA_EX:
      begin // 取盘后分析
        AnsTechData(PAnsDayDataEx(pHead));
      end;
    RT_REPORTSORT:
      begin
        AnsPeportSort(PAnsReportData(pHead));
      end;
    RT_GENERALSORT_EX:
      begin
        AnsGeneralSortEx(PAnsGeneralSortEx(pHead));
      end;
    RT_LEVEL_REALTIME:
      begin
        AnsLevelRealTime(PAnsHSAutoPushLevel(pHead));
      end;
    RT_LEVEL_AUTOPUSH:
      begin
        AnsAutoPushLevelRealTime(PAnsHSAutoPushLevel(pHead));
      end;
    RT_LEVEL_TRANSACTION:
      begin
        AnsLevelTransaction(PAnsLevelTransaction(pHead));
      end;

    // EVEL2逐笔成交主推
    RT_LEVEL_TRANSACTION_AUTOPUSH:
      begin
        AnsAutoPushLevelTransaction(PAnsLevelTransactionAuto(pHead));
      end;

    RT_LEVEL_ORDERQUEUE:
      begin
        AnsLevelOrderQueue(PAnsQueryOrderQueue(pHead));
      end;
    // LEVEL2买卖队列买方向主推      LEVEL2买卖队列卖方向主推
    RT_LEVEL_BORDERQUEUE_AUTOPUSH, RT_LEVEL_SORDERQUEUE_AUTOPUSH:
      begin
        AnsAutoPushLevelOrderQueue(PAnsLevelOrderQueueAuto(pHead));
      end;
    RT_LEVEL_TOTALMAX_AUTOPUSH:
      begin
        FQuoteService.WriteDebug('RT_LEVEL_TOTALMAX_AUTOPUSH');
      end;
    RT_LEVEL_SINGLEMA_AUTOPUSH:
      begin
        FQuoteService.WriteDebug('RT_LEVEL_SINGLEMA_AUTOPUSH');
      end;

    RT_LEVEL_TOTALMAX, RT_LEVEL_TOTALMAX or $1000:
      begin
        AnsLevelCancelTOTALMAX(PAnsHsLevelCancelOrder(pHead));
      end;

    RT_LEVEL_SINGLEMAX:
      begin
        FQuoteService.WriteDebug('RT_LEVEL_SINGLEMAX  ' + inttostr(Size) + #13#10 +
          inttostr(SizeOf(TAnsHsLevelCancelOrder)));
        AnsLevelCancelSINGLEMA(PAnsHsLevelCancelOrder(pHead));
      end;
    RT_LEVEL_SINGLEMAX or $1000:
      begin

        AnsLevelCancelSINGLEMA(PAnsHsLevelCancelOrder(pHead));
      end;
    // DDE 龙虎看盘
    RT_HDA_TRADE_CLASSIFY_BYORDER_QUERY:
      AnsHDA_TradeClassify_ByOrder(PAnsTradeClassify_HDA(pHead));
    // DDE 龙虎看盘主推
    RT_HDA_TRADE_CALSSIFY_BYORDER_AUTOPUSH:
      AnsAutoPushHDA_TradeClassify_ByOrder(PAnsTradeClassify_HDA(pHead));
    // 银行间债券
    RT_TREND_IB:
      begin
        AnsIBTREND(PAnsIBTrendData(pHead));
      end;
    RT_TRANS_IB:
      begin
        AnsForeignTRANS(PAnsIBTransData(pHead));
      end;
    RT_TECHDATA_IB:
      begin // 银行间债券 	K线
        AnsForeignTECHDATA(PAnsIBTechData(pHead));
      end;
    RT_BOND_BASE_INFO_IB:
      begin // 银行间债券 债券基础信息
        AnsForeignBASEINFO(PAnsIBBondBaseInfoData(pHead));
      end;

    RT_SEVER_EMPTY:
      begin
        // with PAnsSeverEmpty(pHead) do
        // pHead.m_nType
        FQuoteService.WriteDebug('RT_SEVER_EMPTY');
      end;
    RT_RETURN_EMPTY:
      begin
        FQuoteService.WriteDebug('RT_RETURN_EMPTY');
      end;
  else
    FQuoteService.WriteDebug('--------HandleOneBiz else:' + inttostr(pHead^.m_nType));
  end;
end;

procedure TQuoteBusiness.DoResetMessage(ServerType: ServerTypeEnum);
begin
  if Assigned(FOnResetMessage) then
    FOnResetMessage(ServerType);
end;

procedure TQuoteBusiness.DoActiveMessage(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeysIndex: int64);
begin
  if Assigned(FOnActiveMessage) then
    FOnActiveMessage(MaskType, SendType, Keys, KeysIndex);
end;

procedure TQuoteBusiness.DoActiveMessageCookie(SendType: QuoteTypeEnum; Cookie: integer);
begin
  if Assigned(FOnActiveMessageCookie) then
    FOnActiveMessageCookie(SendType, Cookie);

end;

procedure TQuoteBusiness.ReadFile(const FileName: string; var buff: Pointer; var Size: integer);
var
  FileStrm: TFileStream;
begin
  // 删原先的文件
  buff := nil;
  if FileExists(FileName) then
  begin
    FileStrm := TFileStream.Create(FileName, fmOpenRead);
    try
      Size := FileStrm.Size;
      GetMemEx(buff, Size);

      FileStrm.Position := 0;
      FileStrm.Read(buff^, Size);
    finally
      FileStrm.Free;
    end;
  end;
end;

procedure TQuoteBusiness.ReqAutoPush(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // 主推
  AskData^.m_nType := RT_AUTOPUSH;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

// 实时推送扩展  请求
procedure TQuoteBusiness.ReqAutoPush_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
// RT_AUTOPUSH_EXT
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // 扩展主推
  AskData^.m_nType := RT_AUTOPUSH_EXT;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqAutoPushLevelCancel(CodeInfo: PCodeInfo; direct: AnsiChar);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Code^ := CodeInfo^;

  if direct = '1' then // 1:Single 2:Consolidated
    AskData^.m_nType := RT_LEVEL_SINGLEMA_AUTOPUSH
  else
    AskData^.m_nType := RT_LEVEL_TOTALMAX_AUTOPUSH;
  AskData.m_nPrivateKey.m_pCode := CodeInfo^;
  AskData^.m_nSize := 1;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Code, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo), 0);
end;

// 订阅短线精灵主推
procedure TQuoteBusiness.ReqAutoPushMarketEvent(ServerType: ServerTypeEnum);
var
  AskData: PAskData;
  ReqMarketMonitor: PReqMarketMonitor;
  len: integer;
  MarketMonitor: PMarketMonitor;
begin
  if ServerType = stStockLevelI then
  begin
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(AskData, SizeOf(TAskData), 0);
    len := SizeOf(TReqMarketMonitor) + SizeOf(TMarketMonitor);

    GetMemEx(Pointer(ReqMarketMonitor), len);
    FillMemory(ReqMarketMonitor, len, 0);

    AskData.m_nType := RT_MARKET_MONITOR_AUTOPUSH;
    AskData.m_nSize := FloorSize(len, SizeOf(TCodeInfo));

    ReqMarketMonitor.m_nMktCount := 2;
    ReqMarketMonitor.m_sMarkets[0].m_nMarketType := STOCK_MARKET or SH_BOURSE; // 上海市场
    MarketMonitor := PMarketMonitor(int64(ReqMarketMonitor) + SizeOf(TReqMarketMonitor));
    MarketMonitor.m_nMarketType := STOCK_MARKET or SZ_BOURSE; // 深圳市场

    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqMarketMonitor, nil, SizeOf(TAskData), len, 0);
  end;
end;

procedure TQuoteBusiness.AnsAutoPushMarketEvent(pData: PAnsMarketEvent);
var
  Inf: IQuoteUpdate;
begin
  Inf := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_MarketMonitor, ''] as IQuoteUpdate;
  if Inf <> nil then
    Inf.Update(UPDATE_MARKET_EVENT, int64(@pData.m_MarketEvents[0]), pData.m_nSize);
  DoActiveMessage(QuoteType_MarketMonitor, QuoteType_MarketMonitor, nil, -1);
end;

procedure TQuoteBusiness.ReqSingleHQColValue(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count, ColCode: UInt;
  Cookie: integer);
var
  AskData: PAskData;
  len: integer;
  ReqHQColValue: PReqHQColValue;
begin
  if (Count = 0) or (CodeInfos = nil) then
    exit;
  GetMemEx(PAnsiChar(AskData), SizeOf(TAskData));
  FillMemory(AskData, SizeOf(TAskData), 0);
  len := SizeOf(TReqHQColValue) + (Count - 1) * SizeOf(TCodeInfo);
  GetMemEx(PAnsiChar(ReqHQColValue), len);
  FillMemory(ReqHQColValue, len, 0);

  AskData.m_nType := RT_HQCOL_VALUE;
  AskData.m_nSize := FloorSize(len, SizeOf(TCodeInfo));
  AskData.m_lKey := Cookie;

  ReqHQColValue.m_lHQColCount := 1;
  ReqHQColValue.m_lHQCols[0] := ColCode;
  ReqHQColValue.m_lCodeSize := Count;
  CopyMemory(@ReqHQColValue.m_pCode[0], CodeInfos, SizeOf(TCodeInfo) * Count);
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqHQColValue, nil, SizeOf(TAskData), len, 0);
end;

procedure TQuoteBusiness.AnsSingleHQColValue(pData: PAnsHQColValue);
var
  Inf: IQuoteUpdate;
begin
  if pData.m_lColCodeSize <= 0 then
    exit;
  Inf := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_SingleColValue, inttostr(pData.m_dhHead.m_lKey)] as IQuoteUpdate;
  if Inf = nil then
    exit;
  Inf.Update(UPDATE_COLVELUE_DATA, int64(pData), pData.m_lColCodeSize);
  DoActiveMessageCookie(QuoteType_SingleColValue, pData.m_dhHead.m_lKey);
end;

procedure TQuoteBusiness.ReqHDA_TradeClassify_ByOrder(CodeInfo: PCodeInfo; Count, ClassifyView: integer);
var
  AskData: PAskData;
  Codes: PCodeInfo;
begin
  // Count := 1;
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfo^, Codes^, SizeOf(TCodeInfo) * Count);

  AskData^.m_nType := RT_HDA_TRADE_CLASSIFY_BYORDER_QUERY;
  AskData^.m_nSize := Count;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;
  FQuoteService.SendData(FQuoteService.TCPIndex(stDDE), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.AnsHDA_TradeClassify_ByOrder(AnsTradeClassify: PAnsTradeClassify_HDA);
var
  i, keyIndex: integer;
  QuotaUpdateData: IQuoteUpdate;
  KeysIndex: int64;
  Keys: TIntegerList;
  p: PHDATradeClassifyData;
begin
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  QuotaUpdateData := FQuoteDataMngr.QuoteDDERealTime as IQuoteUpdate;
  QuotaUpdateData.BeginWrite;
  try
    for i := 0 to AnsTradeClassify.m_nSize - 1 do
    begin
      p := PHDATradeClassifyData(int64(@AnsTradeClassify.m_lpClassify[0]) + i * SizeOf(THDATradeClassifyData));
      keyIndex := FQuoteDataMngr.QuoteRealTime.CodeToKeyIndex[p.m_StockCode.m_cCodeType, CodeInfoToCode(@p.m_StockCode)];
      if KeysIndex >= 0 then
      begin
        QuotaUpdateData.Update(UPDATE_DDE_BIGORDER_BYORDER, int64(p), 1);
        Keys.Add(keyIndex);
        StocksBit64Index(KeysIndex, keyIndex);
      end;
    end;
    // 通知数据到达
    DoActiveMessage(QuoteType_DDEBigOrderRealTimeByOrder, QuoteType_DDEBigOrderRealTimeByOrder, Keys, KeysIndex);
  finally
    QuotaUpdateData.EndWrite;
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.AnsAutoPushHDA_TradeClassify_ByOrder(AnsTradeClassify: PAnsTradeClassify_HDA);
begin
  AnsHDA_TradeClassify_ByOrder(AnsTradeClassify);
end;

procedure TQuoteBusiness.ReqAutoPushHDA_TradeClassify_ByOrder(CodeInfos: PCodeInfos; ClassifyView, Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  AskData^.m_nType := RT_HDA_TRADE_CALSSIFY_BYORDER_AUTOPUSH;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stDDE), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqAutoPushLevelOrderQueue(CodeInfos: PCodeInfos; Count: integer; direct: AnsiChar);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);
  if direct = '1' then
    AskData^.m_nType := RT_LEVEL_BORDERQUEUE_AUTOPUSH
  else
    AskData^.m_nType := RT_LEVEL_SORDERQUEUE_AUTOPUSH;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqAutoPushLevelRealTime(CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_LEVEL_AUTOPUSH;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);

end;

procedure TQuoteBusiness.ReqAutoPushLevelTransaction(CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // 板块数据
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_LEVEL_TRANSACTION_AUTOPUSH;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqBlockData(ServerType: ServerTypeEnum);
var
  AskData: PAskData;
  ReqBlockData: PReqBlockData;
begin
  // 板块数据
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqBlockData), SizeOf(TReqBlockData));
  FillMemory(Pointer(ReqBlockData), SizeOf(TReqBlockData), 0);
  ReqBlockData^.m_lLastDate := 19700101; // 日期

  AskData^.m_nType := RT_BLOCK_DATA;
  AskData^.m_nSize := FloorSize(SizeOf(TReqBlockData), SizeOf(TCodeInfo));

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), Pointer(AskData), Pointer(ReqBlockData), nil,
    SizeOf(TAskData), SizeOf(TReqBlockData), 0);
end;

procedure TQuoteBusiness.ReqCurrentFinance;
var
  AskData: PAskData;
  ReqCurrentFinanceData: PReqCurrentFinanceData;
begin
  // 最新的财务数据
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqCurrentFinanceData), SizeOf(TReqCurrentFinanceData));
  FillMemory(Pointer(ReqCurrentFinanceData), SizeOf(TReqCurrentFinanceData), 0);
  ReqCurrentFinanceData^.m_lLastDate := 0; // 日期

  AskData^.m_nType := RT_CURRENTFINANCEDATA;
  AskData^.m_nSize := FloorSize(SizeOf(TReqCurrentFinanceData), SizeOf(TCodeInfo));

  FQuoteService.SendData(FQuoteService.TCPIndex, AskData, ReqCurrentFinanceData, nil, SizeOf(TAskData),
    SizeOf(TReqCurrentFinanceData), 0);
end;

procedure TQuoteBusiness.ReqExRightData;
var
  AskData: PAskData;
  ReqExRightData: PReqExRightData;
begin
  // 除权数据
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqExRightData), SizeOf(TReqExRightData));
  FillMemory(Pointer(ReqExRightData), SizeOf(TReqExRightData), 0);
  ReqExRightData^.m_lLastDate := 0; // 日期

  AskData^.m_nType := RT_EXRIGHT_DATA;
  AskData^.m_nSize := FloorSize(SizeOf(TReqExRightData), SizeOf(TCodeInfo));

  FQuoteService.SendData(FQuoteService.TCPIndex, Pointer(AskData), Pointer(ReqExRightData), nil, SizeOf(TAskData),
    SizeOf(TReqExRightData), 0);
end;

procedure TQuoteBusiness.ReqGeneralSortEx(ServerType: ServerTypeEnum; Cookie: integer; GeneralSortEx: PReqGeneralSortEx);
var
  AskData: PAskData;
  ReqGeneralSortEx: PReqGeneralSortEx;
begin
  // 报价牌排序
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqGeneralSortEx), SizeOf(TReqGeneralSortEx));
  FillMemory(Pointer(ReqGeneralSortEx), SizeOf(TReqGeneralSortEx), 0);

  // 参数赋值
  ReqGeneralSortEx^ := GeneralSortEx^;
  // 主站信息
  AskData^.m_nType := RT_GENERALSORT_EX;
  AskData^.m_nSize := FloorSize(SizeOf(TReqGeneralSortEx), SizeOf(TCodeInfo));
  AskData^.m_lKey := Cookie;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqGeneralSortEx, nil, SizeOf(TAskData),
    SizeOf(TReqGeneralSortEx), 0);
end;

// 指数领先分时  请求
procedure TQuoteBusiness.ReqMILeadData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  AskData := GetAskData(CodeInfo);
  Code := GetCodeInfos(CodeInfo, 1);
  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_LEAD;
  AskData^.m_nSize := 1;
  // AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

// 指数领先分时  应答
procedure TQuoteBusiness.AnsMILeadData(AnsLeadData: PAnsLeadData);
var
  TrendUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  keyIndex: integer;
begin
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsLeadData.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin
    TrendUpdate.Update(Update_Trend_MAjorIndexLeadData, int64(AnsLeadData), 0);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    keyIndex := GetKeyIndex(@AnsLeadData.m_dhHead.m_nPrivateKey.m_pCode);
    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;
end;

// 指数分时  请求
procedure TQuoteBusiness.ReqMITickData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  AskData := GetAskData(CodeInfo);
  Code := GetCodeInfos(CodeInfo, 1);
  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_MAJORINDEXTICK;
  AskData^.m_nSize := 1;
  // AskData^.m_nPrivateKey.m_pCode := CodeInfo^;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

// 指数分时  应答
procedure TQuoteBusiness.AnsMITickData(AnsMajorIndexTick: PAnsMajorIndexTick);
var
  TrendUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  keyIndex: integer;
begin
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsMajorIndexTick.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin
    TrendUpdate.Update(Update_Trend_MAjorIndexTickData, int64(AnsMajorIndexTick), AnsMajorIndexTick.m_nSize);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    keyIndex := GetKeyIndex(@AnsMajorIndexTick.m_dhHead.m_nPrivateKey.m_pCode);
    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;

end;

// 分时
procedure TQuoteBusiness.ReqHisTrend(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; Date, key: LongInt);
var
  AskData: PAskData;
  ReqHisTrend: PReqHisTrend;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqHisTrend), SizeOf(TReqHisTrend));

  Move(ReqHisTrend^, ReqHisTrend^, SizeOf(TReqHisTrend));

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_HISTREND;
  AskData.m_lKey := key;
  AskData^.m_nSize := FloorSize(SizeOf(TReqHisTrend), SizeOf(TCodeInfo));
  ReqHisTrend^.m_ciStockCode := CodeInfo^;
  ReqHisTrend^.m_lDate := Date;

  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqHisTrend, nil, SizeOf(TAskData),
    SizeOf(TReqHisTrend), 0);
end;

// 个股集合竞价数据 请求
procedure TQuoteBusiness.ReqVirtualAuction(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
begin
  AskData := GetAskData(CodeInfo);
  AskData.m_nType := RT_VIRTUAL_AUCTION;
  AskData.m_nSize := 1;
  AskData.m_nPrivateKey.m_pCode := CodeInfo^;
  CodeInfo := GetCodeInfos(CodeInfo, 1);
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, CodeInfo, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo), 0);
end;

// 个股集合竞价数据 应答
procedure TQuoteBusiness.AnsVirtualAuction(AnsVirtualAuction: PAnsVirtualAuction);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
begin
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsVirtualAuction.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
    TrendUpdate.Update(Update_Trend_VirtualAuction, int64(AnsVirtualAuction), 0);
  // 通知数据到达
  if TrendUpdate <> nil then
  begin
    if FQuoteDataMngr.QuoteRealTime <> nil then
    begin
      with AnsVirtualAuction.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := FQuoteDataMngr.QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsVirtualAuction.m_dhHead.m_nPrivateKey.m_pCode)];
      if keyIndex <> -1 then
        DoActiveMessage(QuoteType_TREND, QuoteType_TREND or QuoteType_TREND, nil, keyIndex);
    end;
  end;
end;

// procedure TQuoteBusiness.ReqMarketEvent(ServerType: ServerTypeEnum;Cookie: integer);
// begin
//
//
// end;
//
// procedure TQuoteBusiness.AnsMaretEvent(AnsMarketEvent:PAnsMarketEvent);
// begin
//
// end;

procedure TQuoteBusiness.ReqMarketEventAutoPush(ServerType: ServerTypeEnum);
var
  AskData: PAskData;
  ReqMarketMonitor: PReqMarketMonitor;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);
  // CodeInfo 空
  GetMemEx(Pointer(ReqMarketMonitor), SizeOf(TReqMarketMonitor) + SizeOf(TMarketMonitor));
  FillMemory(Pointer(ReqMarketMonitor), SizeOf(TReqDayData) + SizeOf(TMarketMonitor), 0);
  AskData.m_nType := RT_MARKET_MONITOR_AUTOPUSH;

end;

procedure TQuoteBusiness.AnsMaretEventAutoPush(AnsMarketEvent: PAnsMarketEvent);
begin

end;

procedure TQuoteBusiness.ReqHKUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // 客户端登录
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // 客户端登录
    AskData^.m_nType := RT_LOGIN_HK;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(stStockHK), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

procedure TQuoteBusiness.LoadBlockData;
var
  FileName: string;
begin
  // 板块数据
  FileName := FQuoteDataMngr.AppPath + PATH_Block + BLOCK_DEF_FILE;
  // if FBlocks <> nil then begin
  // FBlocks.Free;
  // FBlocks := nil;
  // end;
  // if FileExists(FileName) then begin
  // //载入INI文件
  // FBlocks := TMemIniFile.Create(FileName);
  // end;
end;

procedure TQuoteBusiness.LoadCurrentFinance(Data: Pointer; Size: integer);
// var
// i, count, index: integer;
begin
  // count := (size - 8 ) div SizeOf(TFinanceInfo);
  // SetLength(FFinances, count);
  // inc(Integer(Data), 8);
  // Move(Data^, FFinances[0],  sizeof(TFinanceInfo) * Count);
  // //FillMemory(@FStockList[0], SizeOf(TStockInfo) * v, 0);
  // FQuoteService.WriteDebug('RT_CURRENTFINANCEDATA' +'/'+ inttostr(count));
  // for i := low(FFinances) to high(FFinances) do begin
  //
  // index := FStockHash.ValueOf(CodeInfoKey(string(FFinances[i].m_cAType), string(FFinances[i].m_cCode)));
  // if index >= 0 then begin
  // FStockList[index].FinanceIndex := i + 1;
  // end;
  // FQuoteService.Progress('财务数据', count, i);
  // end;
  // FQuoteService.Progress('财务数据', count, count);
end;

procedure TQuoteBusiness.LoadExRight;
var
  FileName: string;
  buff: Pointer;
  Size: integer;
begin
  // 最新财务数据
  FileName := FQuoteDataMngr.AppPath + PATH_Setting + EX_RIGHT_FILE;
  // 删原先的文件
  buff := nil;
  Size := 0;
  ReadFile(FileName, buff, Size);
  if Size <> 0 then
    try
      LoadExRight(buff, Size);
    finally
      // 释放内存
      if buff <> nil then
        FreeMemEx(buff)
    end;
end;

procedure TQuoteBusiness.LoadExRight(Data: Pointer; Size: integer);
// var
// p, count, i, index, rcount: integer;
// ExRight: PExRight;
// ExRightItem: PExRightItem;
begin
  // FQuoteService.WriteDebug(Format('RT_EXRIGHT_DATA %d', [size]));
  //
  // //预估的大小
  // count := (size - 8 - 4) div SizeOf(TExRightItem);
  // SetLength(FExRights, Count);
  // p := 8 + 4; index := 0;
  // inc(Integer(Data), p);
  // while (PInteger(Data)^ <> -1) and (p < Size) do begin
  // ExRight := PExRight(Data);
  // rcount := 0;
  // inc(Integer(Data), Sizeof(TExRight));
  // inc(P, Sizeof(TExRight));
  //
  // while (PInteger(Data)^ <> -1) and (p < Size) do begin
  // ExRightItem := PExRightItem(Data);
  // FExRights[index] := ExRightItem^;
  //
  // FExRights[index].m_nTime := DateToInt(FRightBaseDate + ExRightItem^.m_nTime / 86400);
  //
  // FQuoteService.Progress('复权数据', count, index);
  // inc(rcount); inc(index);
  // inc(P, Sizeof(TExRightItem));
  // inc(integer(Data), Sizeof(TExRightItem));
  // end;
  //
  // if PInteger(Data)^ = -1 then begin
  // inc(P, Sizeof(Integer));
  // inc(integer(Data), Sizeof(Integer));
  // end;
  //
  // i := FStockHash.ValueOf(string(ExRight^.m_cACode) + '_' + string(ExRight^.m_cAType));
  // if i >= 0 then begin
  // FStockList[i].ExRightIndex := index - rcount + 1;
  // FStockList[i].RightCount := rcount;
  // end;
  // end;
  //
  // FQuoteService.Progress('复权数据', Count, Count);
end;

procedure TQuoteBusiness.LoadCurrentFinance;
var
  FileName: string;
  buff: Pointer;
  Size: integer;
begin
  // 最新财务数据
  FileName := FQuoteDataMngr.AppPath + PATH_Setting + CURRENT_FINANCE_FILE;
  buff := nil;
  Size := 0;
  ReadFile(FileName, buff, Size);
  if Size <> 0 then
    try
      LoadCurrentFinance(buff, Size);
    finally
      // 释放内存
      if buff <> nil then
        FreeMemEx(buff)
    end;
end;

procedure TQuoteBusiness.ReqInitialInfo(ServerType: ServerTypeEnum);
var
  Count: integer;
  AskData: PAskData;
  ReqInitSrv: PReqInitSrv;
  ServerCompares: PServerCompares;
begin
  if FQuoteService.Active then
  begin
    // 客户端数据初始化系列
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    // 代码表的验证和初始化；
    GetMemEx(Pointer(ReqInitSrv), SizeOf(TReqInitSrv));
    FillMemory(Pointer(ReqInitSrv), SizeOf(TReqInitSrv), 0);
    ReqInitSrv.m_nSrvCompareSize := 0;

    // 代码表的验证和初始化；
    if ServerType = stStockLevelI then
      Count := 2
    else
      Count := 1;

    GetMemEx(Pointer(ServerCompares), SizeOf(TServerCompare) * Count);
    FillMemory(Pointer(ServerCompares), SizeOf(TServerCompare) * Count, 0);

    // 股票
    case ServerType of
      stStockLevelI:
        begin
          ServerCompares^[0].m_cBourse := STOCK_MARKET;
          ServerCompares^[1].m_cBourse := OTHER_MARKET;
          ServerCompares^[1].m_dwCRC := 0;
        end;
      stFutues:
        ServerCompares^[0].m_cBourse := FUTURES_MARKET;
      stStockHK:
        ServerCompares^[0].m_cBourse := HK_MARKET;
      stForeign:
        ServerCompares^[0].m_cBourse := FOREIGN_MARKET;
      stUSStock:
        ServerCompares^[0].m_cBourse := US_MARKET;
    else
      ServerCompares^[0].m_cBourse := STOCK_MARKET;
    end;

    ServerCompares^[0].m_dwCRC := 0;

    // 客户端数据初始化系列
    AskData^.m_nType := RT_INITIALINFO;
    // 计算上传的数据
    AskData^.m_nSize := FloorSize(SizeOf(TReqInitSrv) + SizeOf(TServerCompare) * Count, SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqInitSrv, ServerCompares, SizeOf(TAskData),
      SizeOf(TReqInitSrv), SizeOf(TServerCompare) * Count);
  end;
end;

procedure TQuoteBusiness.ReqKeepActive(ServerType: ServerTypeEnum);
var
  TestSrvData: PTestSrvData;
begin
  if FQuoteService.Active then
  begin

    GetMemEx(Pointer(TestSrvData), SizeOf(TTestSrvData));
    FillMemory(Pointer(TestSrvData), SizeOf(TTestSrvData), 0);

    // 客户端登录               RT_TESTSRV
    TestSrvData^.m_nType := RT_TESTSRV;
    TestSrvData^.m_nIndex := ServerType;

    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), Pointer(TestSrvData), nil, nil,
      SizeOf(TTestSrvData), 0, 0);

    FQuoteService.WriteDebug('发心跳包....' + ServerTypeToStr(ServerType));
  end;
end;

procedure TQuoteBusiness.ReqLevelCancel(CodeInfo: PCodeInfo; direct: AnsiChar);
var
  AskData: PAskData;
  // ReqOrderQueue: PReqOrderQueue;
  Code: PCodeInfo;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Code^ := CodeInfo^;

  { GetMemEx(pointer(ReqOrderQueue), SizeOf(TReqOrderQueue));
    ReqOrderQueue.m_CodeInfo := CodeInfo^;
    ReqOrderQueue.m_direct := direct; }
  AskData^.m_nType := $0B04;

  { if direct = '1' then      //   1:Single 2:Consolidated
    AskData^.m_nType := $0B04
    else AskData^.m_nType := RT_LEVEL_TOTALMAX;
  }
  AskData.m_nPrivateKey.m_pCode := CodeInfo^;
  AskData^.m_nSize := 1;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Code, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo), 0);

end;

procedure TQuoteBusiness.ReqLevelOrderQueue(CodeInfo: PCodeInfo; direct: AnsiChar);
var
  AskData: PAskData;
  ReqOrderQueue: PReqOrderQueue;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqOrderQueue), SizeOf(TReqOrderQueue));
  ReqOrderQueue.m_CodeInfo := CodeInfo^;
  ReqOrderQueue.m_direct := ord(direct);

  AskData^.m_nType := RT_LEVEL_ORDERQUEUE;
  AskData^.m_nSize := FloorSize(SizeOf(TReqOrderQueue), SizeOf(TCodeInfo));;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, ReqOrderQueue, nil, SizeOf(TAskData),
    SizeOf(TReqOrderQueue), 0);
end;

procedure TQuoteBusiness.ReqLevelRealTime(CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_LEVEL_REALTIME;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);

end;

procedure TQuoteBusiness.ReqLevelTransaction(CodeInfo: PCodeInfo; nSize, nPostion: integer);
var
  AskData: PAskData;
  ReqLevelTransaction: PReqLevelTransaction;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqLevelTransaction), SizeOf(TReqLevelTransaction));
  FillMemory(Pointer(ReqLevelTransaction), SizeOf(TReqLevelTransaction), 0);
  ReqLevelTransaction^.m_CodeInfo := CodeInfo^;
  ReqLevelTransaction^.m_nSize := nSize;
  ReqLevelTransaction^.m_nPostion := nPostion;

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_LEVEL_TRANSACTION;
  AskData^.m_nSize := FloorSize(SizeOf(TReqLevelTransaction), SizeOf(TCodeInfo));
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), AskData, ReqLevelTransaction, nil, SizeOf(TAskData),
    SizeOf(TReqLevelTransaction), 0);
end;

procedure TQuoteBusiness.ReqLimitTick(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; Limit: Word);
var
  AskData: PAskData;
  ReqLimitTick: PReqLimitTick;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqLimitTick), SizeOf(TReqLimitTick));
  FillMemory(Pointer(ReqLimitTick), SizeOf(TReqLimitTick), 0);

  ReqLimitTick^.m_pCode := CodeInfo^;
  ReqLimitTick^.m_nCount := Limit;

  // 个股分笔
  AskData^.m_nType := RT_LIMITTICK;
  AskData^.m_nSize := FloorSize(SizeOf(TReqLimitTick), SizeOf(TCodeInfo));;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqLimitTick, nil, SizeOf(TAskData),
    SizeOf(TReqLimitTick), 0);
end;

procedure TQuoteBusiness.ReqPeportSort(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer; Cookie: integer;
  ReqReportSort: PReqReportSort);
var
  AskData: PAskData;
  ReqAnyReport: PReqAnyReport;
  AnyReportDatas: PAnyReportDatas;
begin
  // 报价牌排序
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqAnyReport), SizeOf(TReqAnyReport));

  FillMemory(Pointer(ReqAnyReport), SizeOf(TReqAnyReport), 0);

  // 复制股票
  GetMemEx(Pointer(AnyReportDatas), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], AnyReportDatas^[0], SizeOf(TCodeInfo) * Count);

  ReqAnyReport^.m_cCodeType := USERDEF_BOURSE;
  ReqAnyReport^.m_nColID := ReqReportSort^.m_nColID;
  ReqAnyReport^.m_bAscending := ReqReportSort^.m_bAscending;
  ReqAnyReport^.m_nBegin := ReqReportSort^.m_nBegin;
  ReqAnyReport^.m_nCount := ReqReportSort^.m_nCount;
  ReqAnyReport^.m_nSize := Count;

  AskData^.m_nType := RT_REPORTSORT;
  AskData^.m_lKey := Cookie; // 保存Cookie
  AskData^.m_nSize := FloorSize(SizeOf(TReqAnyReport) + SizeOf(TAnyReportData) * Count, SizeOf(TCodeInfo));
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqAnyReport, AnyReportDatas, SizeOf(TAskData),
    SizeOf(TReqAnyReport), SizeOf(TAnyReportData) * Count);
end;

procedure TQuoteBusiness.ReqRealTime(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_REALTIME;
  AskData^.m_nSize := Count;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.AnsRealTime(AnsRealTime: PAnsRealTime);
begin
  // FQuoteService.WriteDebug('RT_REALTIME' +'/'+ inttostr(AnsRealTime^.m_nSize));
  if AnsRealTime^.m_nSize > 0 then
    UpdateCommRealTime(@AnsRealTime^.m_pnowData[0], AnsRealTime.m_nSize, nil);
end;

// 扩展实时报价(主要用于个股期权,沪深ETF)  请求
procedure TQuoteBusiness.ReqRealTime_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_REALTIME_EXT;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

// 扩展实时报价(主要用于个股期权,沪深ETF)   应答
procedure TQuoteBusiness.AnsRealTime_Ext(AnsRealTime_Ext: PAnsRealTime_Ext);
begin
  if AnsRealTime_Ext^.m_nSize > 0 then
    UpdateCommRealTime_EXT(@AnsRealTime_Ext.m_pnowData[0], AnsRealTime_Ext.m_nSize, nil);
end;

procedure TQuoteBusiness.ReqStockTick(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  // 测试下来，一次只能取一个
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Move(CodeInfo^, Code^, SizeOf(TCodeInfo));

  // 个股分笔
  AskData^.m_nType := RT_STOCKTICK;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

procedure TQuoteBusiness.ReqTechData(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; TechData: IQuoteUpdate;
  Period: short; nDay: Word);
var
  AskData: PAskData;
  ReqDayData: PReqDayData;
  StateCount: int64;
  SValue: WideString;
  OValue: OleVariant;
begin
  // 增加了忙碌标准 增加了最大请求合并 解决多次请求的问题

  // 取出从今天开始有效的天数
  TechData.DataState(State_Tech_DataLen, StateCount, SValue, OValue);
  if nDay < StateCount then
  begin // 需要的数据比缓存数据多 全部重取
    // 1分钟 5分钟都要重新取     Max(缓存数, 清求数)
    if Period <> PERIOD_TYPE_DAY then
    begin
      nDay := StateCount; // 如果是 1 分钟 5分钟 取一条 就会补最新的数据回来
      // 是日线不要重取
    end
    else
      nDay := 0;
  end;

  if nDay > 0 then
  begin

    // 标记忙碌
    TechData.Update(Update_Tech_Busy, 0, 0);

    // 盘后分析
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    // CodeInfo 空
    GetMemEx(Pointer(ReqDayData), SizeOf(TReqDayData));
    FillMemory(Pointer(ReqDayData), SizeOf(TReqDayData), 0);

    // 协议定义是这样,都是从头取数据 本想增量取,
    // 但存有 1分钟线 5分钟线的问题,数据长度变化 实现起来有问题
    // 所以都从头开始取(浪费啊)

    // AskData.m_lKey :=
    ReqDayData^.m_ciCode := CodeInfo^;
    ReqDayData^.m_cPeriod := Period;
    ReqDayData^.m_lBeginPosition := 0; // 从现在开始
    ReqDayData^.m_nDay := nDay; // 多少个

    // 主站信息
    AskData^.m_nType := RT_TECHDATA_EX;

    // 保存类型状态
    AskData^.m_lKey := Period;

    // if StateCount = 0 then AskData^.m_nIndex := 1  //取全部数据
    // else AskData^.m_nIndex := 2;    //取增量数据

    AskData^.m_nSize := FloorSize(SizeOf(TReqDayData), SizeOf(TCodeInfo));
    AskData^.m_nPrivateKey.m_pCode := ReqDayData^.m_ciCode;
    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), Pointer(AskData), Pointer(ReqDayData), nil,
      SizeOf(TAskData), SizeOf(TReqDayData), 0);
  end;
end;

// 个股分时  请求
procedure TQuoteBusiness.ReqTrend(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Move(CodeInfo^, Code^, SizeOf(TCodeInfo));

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_TREND;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

procedure TQuoteBusiness.ReqTrend_Ext(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Move(CodeInfo^, Code^, SizeOf(TCodeInfo));

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_TREND_EXT;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);
end;

procedure TQuoteBusiness.AnsAutoPush(AnsRealTime: PAnsRealTime);
var
  i, keyIndex: integer;
  KeysIndex: int64;
  QuoteRealTime: IQuoteRealTime;
  RealTimeUpdate: IQuoteUpdate;
  QuoteUpdate: IQuoteUpdate;

  CommRealTimeData: PCommRealTimeData;
  Keys: TIntegerList;
begin
  // FQuoteService.WriteDebug('RT_AUTOPUSH' +'/'+ inttostr(AnsRealTime^.m_nSize));
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // 获取 QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin

      // 获取  IQuoteUpdate 开始更新数据
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

      CommRealTimeData := @AnsRealTime^.m_pnowData[0];
      for i := 0 to AnsRealTime.m_nSize - 1 do
      begin
        keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData^.m_ciStockCode.m_cCodeType,
          CodeInfoToCode(@CommRealTimeData^.m_ciStockCode)];

        // 指数成交额单位改为元
        if { HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType,OTHER_MARKET) or } // 申万指数、中信指数、地域板块、概念板块成交额的单位为元
          (HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
          HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
          CommRealTimeData.m_cNowData.m_indData.m_fAvgPrice := CommRealTimeData.m_cNowData.m_indData.m_fAvgPrice * 100;

        // 更新报价排
        if keyIndex >= 0 then
        begin
          RealTimeUpdate.Update(Update_RealTime_RealTimeData, int64(CommRealTimeData), 0);

          Keys.Add(keyIndex);
          StocksBit64Index(KeysIndex, keyIndex);
        end;

        // 更新分时线
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Trend_AutoPush, int64(CommRealTimeData), 0)
        end;

        // 更新分笔
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_STOCKTICK, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_StockTick_AutoPush, int64(CommRealTimeData), 0);
        end;

        // 更新 限制 分笔
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_LIMITTICK, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_StockTick_AutoPush, int64(CommRealTimeData), 0)
        end;

        // 更新 日线
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_DAY, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // 更新 1分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE1, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // 更新 5分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE5, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // 更新 15分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE15, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // 更新 30分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE30, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;

        // 更新 60分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE60, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        end;
        // 更新周
        // QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_WEEK,
        // @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
        // if QuoteUpdate <> nil then
        // begin
        // QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        // end;
        // // 更新月
        // QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MONTH,
        // @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
        // if QuoteUpdate <> nil then
        // begin
        // QuoteUpdate.Update(Update_Tech_AutoPush, int64(CommRealTimeData), 0)
        // end;

        // 实际情况 位移数据  指数
        if HSMarketType(CommRealTimeData^.m_ciStockCode.m_cCodeType, OTHER_MARKET) then
        begin
          inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSIndexRealTime));

        end
        else if HSMarketType(CommRealTimeData^.m_ciStockCode.m_cCodeType, HK_MARKET) then
        begin
          inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSHKStockRealTime));
        end
        else if HSMarketType(CommRealTimeData^.m_ciStockCode.m_cCodeType, FOREIGN_MARKET) then
        begin
          inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSIBRealTime));

          // 期货
        end
        else if HSMarketType(CommRealTimeData^.m_ciStockCode.m_cCodeType, FUTURES_MARKET) then
        begin
          inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSQHRealTime))
        end
        else
        begin // 股票
          if HSKindType(CommRealTimeData^.m_ciStockCode.m_cCodeType, KIND_INDEX) then
            inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSIndexRealTime))
            // A B 股
          else
            inc(IntPtr(CommRealTimeData), SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + SizeOf(THSStockRealTime));
        end;
      end;

      // 数据到达通知
      DoActiveMessage(QuoteType_REALTIME or QuoteType_TREND or QuoteType_STOCKTICK or QuoteType_LIMITTICK or
        QuoteType_TECHDATA_MINUTE1 or QuoteType_TECHDATA_MINUTE5 or QuoteType_TECHDATA_DAY or
        QuoteType_TECHDATA_MINUTE15 or QuoteType_TECHDATA_MINUTE30 or QuoteType_TECHDATA_MINUTE60 { or
          QuoteType_TECHDATA_WEEK or QuoteType_TECHDATA_MONTH } , QuoteType_REALTIME, Keys, KeysIndex); // 报价牌  分时走势  分笔成交
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.AnsAutoPush_Ext(AnsRealTime: PAnsRealTime_Ext);
var
  i, keyIndex, OffSet: integer;
  KeysIndex: int64;
  QuoteRealTime: IQuoteRealTime;
  RealTimeUpdate: IQuoteUpdate;
  QuoteUpdate: IQuoteUpdate;

  CommRealTimeData: PCommRealTimeData_Ext;
  Keys: TIntegerList;
begin
  // FQuoteService.WriteDebug('RT_AUTOPUSH' +'/'+ inttostr(AnsRealTime^.m_nSize));
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // 获取 QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin

      // 获取  IQuoteUpdate 开始更新数据
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

      CommRealTimeData := @AnsRealTime^.m_pnowData[0];
      OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + 2 * SizeOf(uShort);
      for i := 0 to AnsRealTime.m_nSize - 1 do
      begin
        keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData^.m_ciStockCode.m_cCodeType,
          CodeInfoToCode(@CommRealTimeData^.m_ciStockCode)];

        // 指数成交额单位改为元
        if { HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType,OTHER_MARKET) or } // 申万指数、中信指数、地域板块、概念板块成交额的单位为元
          (HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
          HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
          CommRealTimeData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice :=
            CommRealTimeData.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;

        // 更新报价排
        if keyIndex >= 0 then
        begin
          RealTimeUpdate.Update(Update_RealTime_RealTimeDataExt, int64(CommRealTimeData), 0);

          Keys.Add(keyIndex);
          StocksBit64Index(KeysIndex, keyIndex);
        end;

        // 更新分时线
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @CommRealTimeData.m_ciStockCode] as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Trend_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // 更新分笔
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_STOCKTICK, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_StockTick_AutoPush_Ext, int64(CommRealTimeData), 0);
        end;

        // 更新 限制 分笔
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_LIMITTICK, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_StockTick_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // 更新 日线
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_DAY, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // 更新 1分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE1, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // 更新 5分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE5, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // 更新 15分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE15, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // 更新 30分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE30, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // 更新 60分钟
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MINUTE60, @CommRealTimeData^.m_ciStockCode]
          as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
        end;
        // 更新周
        { QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_WEEK,
          @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
          if QuoteUpdate <> nil then
          begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
          end;
          // 更新月
          QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TECHDATA_MONTH,
          @CommRealTimeData^.m_ciStockCode] as IQuoteUpdate;
          if QuoteUpdate <> nil then
          begin
          QuoteUpdate.Update(Update_Tech_AutoPush_Ext, int64(CommRealTimeData), 0)
          end; }

        // 实际情况 位移数据  指数
        if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OTHER_MARKET) then // 指数
          // CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + sizeof(THSIndexRealTime_EXT))
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Ext))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, HK_MARKET) then // 香港
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSHKStockRealTime_EXT))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OPT_MARKET) then // 个股期权
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSOPTRealTime))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, FUTURES_MARKET) then // 期货
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSQHRealTime))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, US_MARKET) then // 美股
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSUSStockRealTime))
        else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, FOREIGN_MARKET) then
        begin
          if HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, YHJZQ_BOURSE) or // 银行间
            HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, XHCJ_BOURSE) or
            HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, ZYSHG_BOURSE) or
            HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, MDSHG_BOURSE) then

            CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSIBRealTime))
          else // 外汇
            CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSWHRealTime));
        end
        else
        begin
          if HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX) then
            CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Ext))
          else // A B 股
            CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime_Ext));
        end;
      end;

      // 数据到达通知
      DoActiveMessage(QuoteType_REALTIME or QuoteType_TREND or QuoteType_STOCKTICK or QuoteType_LIMITTICK or
        QuoteType_TECHDATA_MINUTE1 or QuoteType_TECHDATA_MINUTE5 or QuoteType_TECHDATA_DAY or
        QuoteType_TECHDATA_MINUTE15 or QuoteType_TECHDATA_MINUTE30 or QuoteType_TECHDATA_MINUTE60 { or
          QuoteType_TECHDATA_WEEK or QuoteType_TECHDATA_MONTH } , QuoteType_REALTIME, Keys, KeysIndex); // 报价牌  分时走势  分笔成交
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.AnsAutoPushLevelOrderQueue(LevelOrderQueueAuto: PAnsLevelOrderQueueAuto);
var
  i, keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  OrderQueueUpdate: IQuoteUpdate;
  // LevelTransaction: PLevelTransaction;
  OrderQueue: POrderQueueData;
begin
  FQuoteService.WriteDebug('AnsAutoPushLevelOrderQueue' + inttostr(LevelOrderQueueAuto^.m_nSize));
  QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  keyIndex := -1;
  for i := 0 to LevelOrderQueueAuto^.m_nSize - 1 do
  begin
    OrderQueue := @LevelOrderQueueAuto^.m_pstData[i];

    OrderQueueUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_ORDERQUEUE, @OrderQueue^.m_CodeInfo] as IQuoteUpdate;
    if OrderQueueUpdate <> nil then
    begin
      // 数据更新
      OrderQueueUpdate.Update(Update_OrderQueue_Data, int64(@OrderQueue^.m_Data), 1);

      QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
      if QuoteRealTime <> nil then
        with OrderQueue^.m_CodeInfo do
          keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType, CodeInfoToCode(@OrderQueue^.m_CodeInfo)];
    end;
  end;
  // 通知数据到达
  if keyIndex <> -1 then
    DoActiveMessage(QuoteType_Level_ORDERQUEUE, QuoteType_Level_ORDERQUEUE, nil, keyIndex);

end;

procedure TQuoteBusiness.AnsAutoPushLevelRealTime(LevelRealTime: PAnsHSAutoPushLevel);
begin
  if LevelRealTime^.m_nSize > 0 then
    UpdateCommLevelRealTime(@LevelRealTime^.m_pstData[0], LevelRealTime.m_nSize, nil);
end;

procedure TQuoteBusiness.AnsAutoPushLevelTransaction(LevelTransactionAuto: PAnsLevelTransactionAuto);
var
  i, keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  TransactionUpdate: IQuoteUpdate;
  LevelTransaction: PLevelTransaction;
begin
  FQuoteService.WriteDebug('AnsAutoPushLevelTransaction' + inttostr(LevelTransactionAuto^.m_nSize));
  QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  keyIndex := -1;
  for i := 0 to LevelTransactionAuto^.m_nSize - 1 do
  begin
    LevelTransaction := @LevelTransactionAuto^.m_Data[i];
    TransactionUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_TRANSACTION, @LevelTransaction^.m_CodeInfo]
      as IQuoteUpdate;
    if TransactionUpdate <> nil then
    begin
      // 数据更新
      TransactionUpdate.Update(Update_TransactionAuto_Data, int64(@LevelTransaction^.m_Data), LevelTransaction^.m_nSize);

      if QuoteRealTime <> nil then
        with LevelTransaction^.m_CodeInfo do
          keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType, CodeInfoToCode(@LevelTransaction^.m_CodeInfo)];
    end;
  end;
  // 通知数据到达
  if keyIndex <> -1 then
    DoActiveMessage(QuoteType_Level_TRANSACTION, QuoteType_Level_TRANSACTION, nil, keyIndex);
end;

function UnZipBlockFile(Data: PAnsiChar; len: integer): TMemoryStream;
begin
  // var
  // ms: TMemoryStream;
  // num: Integer;
  // begin
  Result := nil;
  // if (Data = nil) or (len = 0) then exit;
  // ms := TMemoryStream.Create;
  // try
  // ms.Write(Data^,len);
  // ds := TDecompressionStream.Create(ms);
  // try
  // //ds.Write(Data^,len);
  // //ds.Read(ms.Memory^, num);
  // ms.Clear;
  // ms.CopyFrom(ds,ds.Size);
  // Result := ms;
  // finally
  // ds.Free;
  // end;
  // except
  // ms.Free;
  // end;

end;

procedure TQuoteBusiness.AnsBlockData(AnsTextData: PAnsTextData);
var
  fs: TMemoryStream;
  FileName: string;
begin
  if AnsTextData^.m_nSize > 0 then
  begin
    // 解压板块数据
    FileName := FQuoteDataMngr.AppPath + PATH_Block + BLOCK_DEF_FILE;
    fs := TMemoryStream.Create;
    fs.Write(AnsTextData^.m_cData[0], AnsTextData^.m_nSize);
    fs.SaveToFile(FileName);
    fs.Free;
    // ms := UnZipBlockFile(@AnsTextData^.m_cData[0], AnsTextData^.m_nSize);
    // if ms = nil then Exit;
    //
    //
    // ms.SaveToFile(FileName);
    // ms.Free;
    // 导入板块数据
    LoadBlockData;
  end;
end;

procedure TQuoteBusiness.AnsCurrentFinance(AnsTextData: PAnsTextData);
var
  FileName: string;
  RealTimeUpdate: IQuoteUpdate;
begin
  if AnsTextData^.m_nSize > 0 then
  begin
    // 最新财务数据
    FileName := FQuoteDataMngr.AppPath + PATH_Setting + CURRENT_FINANCE_FILE;

    // 写入文件
    WriteFile(FileName, @AnsTextData^.m_cData[0], AnsTextData^.m_nSize);

    // 载入当前财务数据
    // 获取  IQuoteUpdate 开始更新数据
    RealTimeUpdate := (FQuoteDataMngr.QuoteRealTime as IQuoteUpdate);
    if RealTimeUpdate <> nil then
      RealTimeUpdate.Update(Update_RealTime_Finance_SetData, int64(@AnsTextData^.m_cData[0]), AnsTextData^.m_nSize);

  end;
end;

procedure TQuoteBusiness.AnsExRightData(AnsTextData: PAnsTextData);
var
  FileName: string;
  RealTimeUpdate: IQuoteUpdate;
begin
  if AnsTextData^.m_nSize > 0 then
  begin
    // 除权数据 应答
    FileName := FQuoteDataMngr.AppPath + PATH_Setting + EX_RIGHT_FILE;
    // 写入文件
    WriteFile(FileName, @AnsTextData^.m_cData[0], AnsTextData^.m_nSize);

    // 载入除权数据
    // 获取  IQuoteUpdate 开始更新数据
    RealTimeUpdate := (FQuoteDataMngr.QuoteRealTime as IQuoteUpdate);
    if RealTimeUpdate <> nil then
      RealTimeUpdate.Update(Update_RealTime_ExRight_SetData, int64(@AnsTextData^.m_cData[0]), AnsTextData^.m_nSize);
  end;
end;

procedure TQuoteBusiness.AnsGeneralSortEx(AnsGeneralSortEx: PAnsGeneralSortEx);
var
  GeneralSortUpdate: IQuoteUpdate;

begin
  // 更新报价牌数据
  if AnsGeneralSortEx^.m_nSize > 0 then
  begin

    // 更新排序数据
    GeneralSortUpdate := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_GENERALSORT,
      inttostr(AnsGeneralSortEx^.m_dhHead.m_lKey)] as IQuoteUpdate;
    if GeneralSortUpdate <> nil then
    begin
      GeneralSortUpdate.BeginWrite;
      try
        GeneralSortUpdate.Update(Update_GeneralSort_Data, int64(AnsGeneralSortEx), 0);
      finally
        GeneralSortUpdate.EndWrite;
      end;
      DoActiveMessageCookie(QuoteType_GENERALSORT, AnsGeneralSortEx^.m_dhHead.m_lKey);
    end;
  end;
end;

procedure TQuoteBusiness.AnsHisTrend(AnsHisTrend: PAnsHisTrend);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  // 多日分时
  if AnsHisTrend.m_dhHead.m_lKey < 0 then
  begin
    TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode]
      as IQuoteUpdate;
    if TrendUpdate <> nil then
      TrendUpdate.Update(Update_Trend_MultiHisTrendData, int64(@AnsHisTrend.m_shTend), AnsHisTrend.m_dhHead.m_lKey);
  end
  else if AnsHisTrend.m_dhHead.m_lKey = 99999 then
  begin
    TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode]
      as IQuoteUpdate;
    if TrendUpdate <> nil then
      TrendUpdate.Update(Update_Trend_HisTrendData, int64(@AnsHisTrend.m_shTend), 0);
  end
  else
  begin
    TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_HisTREND, @AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode]
      as IQuoteUpdate;
    if TrendUpdate <> nil then
      TrendUpdate.Update(Update_Trend_HisTrendData, int64(@AnsHisTrend.m_shTend), 0);
  end;
  // 通知数据到达
  if TrendUpdate <> nil then
  begin
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsHisTrend^.m_dhHead.m_nPrivateKey.m_pCode)];
    if keyIndex <> -1 then
      if AnsHisTrend.m_dhHead.m_lKey < 0 then // 通知分时(多日)
      begin
        DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
      end
      else if AnsHisTrend.m_dhHead.m_lKey = 99999 then
      begin
        DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
      end
      else
      begin
        DoActiveMessage(QuoteType_HisTREND, QuoteType_HisTREND, nil, keyIndex);
      end;
  end;
end;

procedure TQuoteBusiness.AnsHKUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('HK 登陆成功!');
  FQuoteService.SendEvent(etLoginHK, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsInitialInfo(AnsInitialData: PAnsInitialData);
var
  i, J, v, index, OpenTime, CloseTime: integer;
  OneMarketData: POneMarketData;
  StockInitData: PStockInitData;
  RealTimeUpdate: IQuoteUpdate;
  ServerType: ServerTypeEnum;
  p: PCommBourseInfo;
  AStockTypeInfo: TStockTypeInfo;
begin
  ServerType := stStockLevelI;
  // 初始化 行情服务器数据
  FQuoteDataMngr.InitDataMngr;

  FQuoteService.WriteDebug('RT_INITIALINFO' + '/' + inttostr(AnsInitialData^.m_nSize));
  RealTimeUpdate := (FQuoteDataMngr.QuoteRealTime as IQuoteUpdate);
  // 初始化应答 市场信息结构
  if (AnsInitialData^.m_nSize > 0) and (RealTimeUpdate <> nil) then
  begin
    OneMarketData := @AnsInitialData^.m_sOneMarketData[0];
    i := 0;
    while i < AnsInitialData^.m_nSize do
    begin

      FQuoteDataMngr.BeginWrite;
      try
        p := FQuoteDataMngr.GetBourseInfo(OneMarketData.m_biInfo.m_nMarketType);
        CopyMemory(p, @OneMarketData.m_biInfo, SizeOf(TCommBourseInfo));
        // 初始化 分时线数
        for v := 0 to OneMarketData.m_biInfo.m_cCount - 1 do
        begin
          if (OneMarketData.m_biInfo.m_stNewType[v].m_nTotal <> 0) and
            (OneMarketData.m_biInfo.m_stNewType[v].m_nNewTimes[0].m_nOpenTime <> -1) then
          begin
            AStockTypeInfo := FQuoteDataMngr.GetStockTypeInfo(OneMarketData.m_biInfo.m_stNewType[v].m_nStockType);
            if AStockTypeInfo = nil then
              continue;

            AStockTypeInfo.StockType := OneMarketData.m_biInfo.m_stNewType[v];
            AStockTypeInfo.Times.Clear;
            index := 0;
            for J := 0 to 9 do
            begin
              OpenTime := OneMarketData.m_biInfo.m_stNewType[v].m_nNewTimes[J].m_nOpenTime;
              CloseTime := OneMarketData.m_biInfo.m_stNewType[v].m_nNewTimes[J].m_nCloseTime;
              if OpenTime = -1 then
                break;
              // 中间连续 前一时间不能算 11:30 13:00    13:00 就不能算
              if J > 0 then
                inc(OpenTime);

              while OpenTime <= CloseTime do
              begin
                AStockTypeInfo.Times.Add(index, OpenTime);
                inc(OpenTime);
                inc(index);
              end;
            end;
            AStockTypeInfo.Times.tag := index;
          end;
        end;
      finally
        FQuoteDataMngr.EndWrite;
      end;

      if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, STOCK_MARKET, SH_BOURSE) then
      begin
        ServerType := stStockLevelI;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, STOCK_MARKET, SZ_BOURSE) then
      begin
        ServerType := stStockLevelI;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FOREIGN_MARKET, YHJZQ_BOURSE) then
      begin
        ServerType := stForeign;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FOREIGN_MARKET, XHCJ_BOURSE) then
      begin
        ServerType := stForeign; // 信用拆借
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FOREIGN_MARKET, ZYSHG_BOURSE) then
      begin
        ServerType := stForeign; // 质押式回购
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FOREIGN_MARKET, MDSHG_BOURSE) then
      begin
        ServerType := stForeign; // 买断式回购
      end
      else if HSMarketType(OneMarketData.m_biInfo.m_nMarketType, OTHER_MARKET) then
      begin
        ServerType := stStockLevelI;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FUTURES_MARKET, DALIAN_BOURSE) then
      begin
        ServerType := stFutues;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FUTURES_MARKET, SHANGHAI_BOURSE) then
      begin
        ServerType := stFutues;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FUTURES_MARKET, ZHENGZHOU_BOURSE) then
      begin
        ServerType := stFutues;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, FUTURES_MARKET, GUZHI_BOURSE) then
      begin
        ServerType := stFutues;
        // 港股主板
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, HK_MARKET, HK_BOURSE) then
      begin
        ServerType := stStockHK;
        // 港股指数
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, HK_MARKET, GE_BOURSE) then
      begin
        ServerType := stStockHK;
      end
      else if HSMarketBourseType(OneMarketData.m_biInfo.m_nMarketType, HK_MARKET, INDEX_BOURSE) then
      begin
        ServerType := stStockHK;
      end
      else if HSMarketType(OneMarketData.m_biInfo.m_nMarketType, US_MARKET) then
        ServerType := stUSStock
      else
        ServerType := stStockLevelI;

      // 定位 StockInitData
      StockInitData := Pointer(IntPtr(@OneMarketData^.m_biInfo.m_stNewType[0]) + SizeOf(TStockType) *
        OneMarketData^.m_biInfo.m_cCount);

      // 更新数据
      RealTimeUpdate.Update(Update_RealTime_Codes_SetData, int64(StockInitData), OneMarketData.m_biInfo.m_nMarketType);

      // 定位
      OneMarketData := Pointer(IntPtr(@StockInitData^.m_pstInfo[0]) + SizeOf(TStockInitInfo) * StockInitData^.m_nSize);
      inc(i);
    end;

    // if ServerType in [stStockLevelI,stFutues] then
    // ReqSeverCalculate(ServerType);
    // 先从文件里加载
    // LoadCurrentFinance;
    // LoadExRight;

    // 板块数据 不取
    // ReqBlockData;

    // 请求财务数据
    // ReqCurrentFinance;
    // 请求除权数据
    // ReqExRightData;
    // 历史财务数据 ???

    // 标记为已初始完成
    FIsInitial := true;
    if ServerType = stStockLevelI then
      FQuoteService.SendEvent(etInited, nil, '', 0, ServerType);

    // 通知初始化 成功  并会清除connter
    FQuoteService.WriteDebug(format('服务器%s成功初始化.', [ServerTypeToStr(ServerType)]));
    DoResetMessage(ServerType);
  end;
end;

procedure TQuoteBusiness.AnsKeepActive(AnsTestSrvData: PTestSrvData);
begin
  // FQuoteService.WriteDebug('RT_KEEPACTIVE' +'/'+ inttostr(AnsKeepActive^.m_nDateTime));
  FQuoteService.WriteDebug('RT_KEEPACTIVE ' + ServerTypeToStr(AnsTestSrvData.m_nIndex));
  FQuoteService.SendEvent(etAnsKeepActive, nil, '', 0, AnsTestSrvData.m_nIndex);
end;

procedure TQuoteBusiness.AnsLevelCancelSINGLEMA(AnsHsLevelCancelOrder: PAnsHsLevelCancelOrder);
var
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  SINGLEMAUpdate: IQuoteUpdate;
begin
  SINGLEMAUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_SINGLEMA,
    @AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if SINGLEMAUpdate <> nil then
  begin
    // 数据更新
    if AnsHsLevelCancelOrder^.m_pData.ctype in [1, 2] then
    begin
      SINGLEMAUpdate.Update(Update_SINGLEMA_Data, int64(@AnsHsLevelCancelOrder^.m_pData), 0);
      keyIndex := -1;
      QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
      if QuoteRealTime <> nil then
        with AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode do
          keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
            CodeInfoToCode(@AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode)];

      // 通知数据到达
      if keyIndex <> -1 then
        DoActiveMessage(QuoteType_Level_SINGLEMA, QuoteType_Level_SINGLEMA, nil, keyIndex);
    end;
  end;
end;

procedure TQuoteBusiness.AnsLevelCancelTOTALMAX(AnsHsLevelCancelOrder: PAnsHsLevelCancelOrder);
var
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  TOTALMAXUpdate: IQuoteUpdate;
begin
  TOTALMAXUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_TOTALMAX,
    @AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if TOTALMAXUpdate <> nil then
  begin
    // 数据更新
    TOTALMAXUpdate.Update(Update_TOTALMAX_Data, int64(@AnsHsLevelCancelOrder^.m_pData), 0);
    keyIndex := -1;
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsHsLevelCancelOrder^.m_dhHead.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_Level_TOTALMAX, QuoteType_Level_TOTALMAX, nil, keyIndex);

  end;
end;

procedure TQuoteBusiness.AnsLevelOrderQueue(QueryOrderQueue: PAnsQueryOrderQueue);
var
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  OrderQueueUpdate: IQuoteUpdate;

begin
  OrderQueueUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_ORDERQUEUE,
    @QueryOrderQueue^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if OrderQueueUpdate <> nil then
  begin

    // 数据更新
    OrderQueueUpdate.Update(Update_OrderQueue_Data, int64(@QueryOrderQueue^.m_pstData), 1);
    keyIndex := -1;
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with QueryOrderQueue^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@QueryOrderQueue^.m_dhHead.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_Level_ORDERQUEUE, QuoteType_Level_ORDERQUEUE, nil, keyIndex);

  end;
end;

procedure TQuoteBusiness.AnsLevelRealTime(LevelRealTime: PAnsHSAutoPushLevel);
begin
  if LevelRealTime^.m_nSize > 0 then
    UpdateCommLevelRealTime(@LevelRealTime^.m_pstData[0], LevelRealTime.m_nSize, nil);
end;

procedure TQuoteBusiness.AnsLevelTransaction(LevelTransaction: PAnsLevelTransaction);
var
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
  TransactionUpdate: IQuoteUpdate;
begin

  TransactionUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_Level_TRANSACTION,
    @LevelTransaction^.m_ciStockCode.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if TransactionUpdate <> nil then
  begin
    // 数据更新
    keyIndex := -1;
    TransactionUpdate.Update(Update_Transaction_Data, int64(@LevelTransaction^.m_Data[0]), LevelTransaction^.m_nSize);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with LevelTransaction^.m_ciStockCode.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@LevelTransaction^.m_ciStockCode.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_Level_TRANSACTION, QuoteType_Level_TRANSACTION, nil, keyIndex);

  end;
end;

procedure TQuoteBusiness.AnsLimitTick(AnsStockTick: PAnsStockTick);
var
  StockTickUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;

  StockTickUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_LIMITTICK, @AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if StockTickUpdate <> nil then
  begin

    StockTickUpdate.Update(Update_StockTick_StockTickData, int64(@AnsStockTick^.m_traData), AnsStockTick^.m_nSize);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_LIMITTICK, QuoteType_LIMITTICK, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.AnsPeportSort(AnsReportData: PAnsReportData);
var
  PeportSortUpdate: IQuoteUpdate;
  Codes: array of TCodeInfo;
begin
  // 更新报价牌数据
  if AnsReportData^.m_nSize > 0 then
  begin
    SetLength(Codes, AnsReportData^.m_nSize);
    UpdateCommRealTime(@AnsReportData^.m_prptData[0], AnsReportData^.m_nSize, @Codes[0]);
    // 更新排序数据
    PeportSortUpdate := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_REPORTSORT, inttostr(AnsReportData^.m_dhHead.m_lKey)
      ] as IQuoteUpdate;
    if PeportSortUpdate <> nil then
    begin
      PeportSortUpdate.BeginWrite;
      try
        PeportSortUpdate.Update(Update_ReprotSort_Data, int64(@Codes[0]), AnsReportData^.m_nSize);
      finally
        PeportSortUpdate.EndWrite;
      end;
      // 通知数据到达
      DoActiveMessageCookie(QuoteType_REPORTSORT, AnsReportData^.m_dhHead.m_lKey);
      // DoActiveMessage(QuoteType_REALTIME, QuoteType_REALTIME, Keys, KeysIndex);
    end;
  end;
end;

procedure TQuoteBusiness.AnsServerInfo(AnsServerInfo: PAnsServerInfo);
begin
  FQuoteService.WriteDebug(format('主站信息 %s %s 已连接过的总数%d 当日连接总数%d 当前连接数%d', [AnsServerInfo^.m_pName,
    AnsServerInfo^.m_pSerialNo, AnsServerInfo^.m_lTotalCount, AnsServerInfo^.m_lToDayCount, AnsServerInfo^.m_lNowCount]));
end;

procedure TQuoteBusiness.AnsStockTick(AnsStockTick: PAnsStockTick);
var
  StockTickUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  StockTickUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_STOCKTICK, @AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if StockTickUpdate <> nil then
  begin

    StockTickUpdate.Update(Update_StockTick_StockTickData, int64(@AnsStockTick^.m_traData), AnsStockTick^.m_nSize);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsStockTick^.m_dhHead.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_STOCKTICK, QuoteType_STOCKTICK, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.AnsTechData(AnsDayDataEx: PAnsDayDataEx);
var
  keyIndex: integer;
  QuoteType: QuoteTypeEnum;
  QuoteRealTime: IQuoteRealTime;
  QuoteTechData: IQuoteUpdate;
  ivalue: int64;
  SValue: WideString;
  vvalue: OleVariant;
  CodeInfo: PCodeInfo;
begin
  // 确定哪个类型的
  QuoteType := PeriodToQuoteType(AnsDayDataEx.m_dhHead.m_lKey);

  // 取出更新对像
  QuoteTechData := FQuoteDataMngr.QuoteDataObjs[QuoteType, @AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  if QuoteTechData <> nil then
  begin
    QuoteTechData.BeginWrite;
    try
      // 取全部数据
      QuoteTechData.Update(Update_Tech_TechData, int64(@AnsDayDataEx^.m_sdData[0]), AnsDayDataEx^.m_nSize);

      // 看是否 还有数据需要再取
      QuoteTechData.DataState(State_Tech_WaitCount, ivalue, SValue, vvalue);
      if ivalue <> 0 then
      begin
        // 等待个数清空
        QuoteTechData.Update(Update_Tech_ResetWaitCount, 0, 0);
        // 重新订阅
        CodeInfo := @AnsDayDataEx^.m_dhHead.m_nPrivateKey;
        ReqTechData(ToServerType(CodeInfo^.m_cCodeType), @AnsDayDataEx^.m_dhHead.m_nPrivateKey, QuoteTechData,
          AnsDayDataEx.m_dhHead.m_lKey, ivalue)
      end;
    finally
      QuoteTechData.EndWrite;
    end;

    keyIndex := -1;
    // 通知 代码部份
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType, QuoteType, nil, keyIndex);
  end;
  // if QuoteType = PERIOD_TYPE_MINUTE1 then
  // begin
  // QuoteTechData := FQuoteDataMngr.QuoteDataObjs[QuoteType_MULTITREND,
  // @AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode] as IQuoteUpdate;
  // if QuoteTechData <> nil then
  // begin
  // QuoteTechData.Update(Update_Trend_MultiTrendData,
  // int64(@AnsDayDataEx^.m_sdData[0]), AnsDayDataEx^.m_nSize);
  // keyIndex := -1;
  // // 通知 代码部份
  // QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  // if QuoteRealTime <> nil then
  // with AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode do
  // keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
  // CodeInfoToCode(@AnsDayDataEx^.m_dhHead.m_nPrivateKey.m_pCode)];
  //
  // // 通知数据到达
  // if keyIndex <> -1 then
  // DoActiveMessage(QuoteType_MULTITREND, QuoteType_MULTITREND, nil,
  // keyIndex);
  // end;
  // end;
end;

// 涨跌停数据 请求
procedure TQuoteBusiness.ReqSeverCalculate(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  pCodes: PCodeInfo;
begin
  if Count = 0 then
    exit;
  AskData := GetAskData(nil);
  pCodes := GetCodeInfos(@CodeInfos[0], Count);
  AskData.m_nType := RT_SEVER_CALCULATE;
  AskData.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, pCodes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

// 涨跌停数据 应答
procedure TQuoteBusiness.AnsSeverCalculate(AnsSeverCalculate: PAnsSeverCalculate);
var
  Update: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  keyIndex, i: integer;
  KeysIndex: int64;
  p: PSeverCalculateData;
  Keys: TIntegerList;
begin
  if AnsSeverCalculate.m_nSize < 1 then
    exit;
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    Update := FQuoteDataMngr.QuoteRealTime as IQuoteUpdate;
    Update.Update(Update_RealTime_Server_Calc, int64(AnsSeverCalculate), 0);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    p := @AnsSeverCalculate.SeverCalculateData[0];
    for i := 0 to AnsSeverCalculate.m_nSize - 1 do
    begin
      keyIndex := QuoteRealTime.CodeToKeyIndex[p.m_ciStockCode.m_cCodeType, CodeInfoToCode(@p.m_ciStockCode)];
      Keys.Add(keyIndex);
      StocksBit64Index(KeysIndex, keyIndex);
      inc(p);
    end;
    DoActiveMessage(QuoteType_REALTIME, QuoteType_REALTIME, Keys, KeysIndex);
  finally
    QuoteRealTime := nil;
    Keys.Free;
  end;
end;

// 个股分时  应答
procedure TQuoteBusiness.AnsTrend(AnsTrendData: PAnsTrendData);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin

    TrendUpdate.Update(Update_Trend_TrendData, int64(AnsTrendData), AnsTrendData.m_nHisLen);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.AnsTrend_Ext(AnsTrendData: PAnsTrendData_Ext);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin

    TrendUpdate.Update(Update_Trend_TrendData_Ext, int64(AnsTrendData), AnsTrendData.m_nHisLen);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsTrendData^.m_dhHead.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.ReqForeignBASEINFO(ServerType: ServerTypeEnum);
var
  AskData: PAskData;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);
  AskData^.m_nType := RT_BOND_BASE_INFO_IB;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, nil, nil, SizeOf(TAskData), 0, 0);
end;

procedure TQuoteBusiness.ReqForeignTECHDATA(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo; TechData: IQuoteUpdate;
  Period: short; nDay: Word);
var
  AskData: PAskData;
  ReqIBTechData: PReqIBTechData;
begin
  // 增加了忙碌标准 增加了最大请求合并 解决多次请求的问题

  // 取出从今天开始有效的天数
  { TechData.DataState(State_Tech_DataLen, StateCount, SValue, OValue);
    if nDay < StateCount then  begin//需要的数据比缓存数据多 全部重取
    //1分钟 5分钟都要重新取     Max(缓存数, 清求数)
    if Period <> PERIOD_TYPE_DAY then begin
    nDay := StateCount;   // 如果是 1 分钟 5分钟 取一条 就会补最新的数据回来
    //是日线不要重取
    end else nDay := 0;
    end; }

  if nDay > 0 then
  begin

    // 标记忙碌
    // TechData.Update(Update_Tech_Busy, 0, 0);

    // 盘后分析
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    // CodeInfo 空
    GetMemEx(Pointer(ReqIBTechData), SizeOf(TReqIBTechData));
    FillMemory(Pointer(ReqIBTechData), SizeOf(TReqIBTechData), 0);

    // 协议定义是这样,都是从头取数据 本想增量取,
    // 但存有 1分钟线 5分钟线的问题,数据长度变化 实现起来有问题
    // 所以都从头开始取(浪费啊)

    ReqIBTechData^.m_ciCode := CodeInfo^;
    ReqIBTechData^.m_nDataType := 1; // 数据类型，1为净价，2为净价收益率，3为中债估值

    ReqIBTechData^.m_cPeriod := PERIOD_TYPE_DAY;
    ReqIBTechData^.m_lBeginPosition := 0; // 从现在开始
    ReqIBTechData^.m_nSize := nDay; // 多少个

    // 主站信息
    AskData^.m_nType := RT_TECHDATA_IB;

    // 保存类型状态
    AskData^.m_lKey := Period;

    // if StateCount = 0 then AskData^.m_nIndex := 1  //取全部数据
    // else AskData^.m_nIndex := 2;    //取增量数据

    AskData^.m_nSize := FloorSize(SizeOf(TReqDayData), SizeOf(TCodeInfo));
    AskData^.m_nPrivateKey.m_pCode := ReqIBTechData^.m_ciCode;
    FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), Pointer(AskData), Pointer(ReqIBTechData), nil,
      SizeOf(TAskData), SizeOf(TReqIBTechData), 0);
  end;
end;

procedure TQuoteBusiness.ReqForeignTRANS(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  ReqIBTrans: PReqIBTrans;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(ReqIBTrans), SizeOf(TReqIBTrans));

  ReqIBTrans.m_ciStockCode := CodeInfo^;
  ReqIBTrans.m_nSize := 0;

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_TRANS_IB;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, ReqIBTrans, nil, SizeOf(TAskData),
    SizeOf(TReqIBTrans), 0);

end;

procedure TQuoteBusiness.ReqIBTREND(ServerType: ServerTypeEnum; CodeInfo: PCodeInfo);
var
  AskData: PAskData;
  Code: PCodeInfo;
begin
  // 行情报价表
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Code), SizeOf(TCodeInfo));
  Move(CodeInfo^, Code^, SizeOf(TCodeInfo));

  // 获取完正的 报价牌信息
  AskData^.m_nType := RT_TREND_IB;
  AskData^.m_nSize := 1;
  AskData^.m_nPrivateKey.m_pCode := CodeInfo^;

  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Code, nil, SizeOf(TAskData), SizeOf(TCodeInfo), 0);

end;

procedure TQuoteBusiness.ReqForeignUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // 客户端登录
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // 客户端登录
    AskData^.m_nType := RT_LOGIN_FOREIGN;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(stForeign), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

procedure TQuoteBusiness.ReqFutuesUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // 客户端登录
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // 客户端登录
    AskData^.m_nType := RT_LOGIN_FUTURES;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(stFutues), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

procedure TQuoteBusiness.ReqUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // 客户端登录
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // 客户端登录

    AskData^.m_nType := RT_LOGIN;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex, Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

// 美股登陆请求
procedure TQuoteBusiness.ReqUSStockUserLogin;
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // 客户端登录
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);
    // 客户端登录
    AskData^.m_nType := RT_LOGIN_US;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));
    AskData.m_nPrivateKey.m_pCode.m_cCodeType := US_MARKET;
    // CopyMemory(@AskData.m_nPrivateKey.m_pCode.m_cCode[0],@US_Login_Flag[1],Length(US_Login_Flag));

    FQuoteService.SendData(FQuoteService.TCPIndex(stUSStock), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

// DDE登陆请求
procedure TQuoteBusiness.ReqDDEUserLogin();
var
  AskData: PAskData;
  ReqLogin: PReqLogin;
begin
  if FQuoteService.Active then
  begin
    // 客户端登录
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    GetMemEx(Pointer(ReqLogin), SizeOf(TReqLogin));
    FillMemory(Pointer(ReqLogin), SizeOf(TReqLogin), 0);

    // 客户端登录
    AskData^.m_nType := RT_Login_DDE;
    AskData^.m_nSize := FloorSize(SizeOf(TReqLogin), SizeOf(TCodeInfo));

    FQuoteService.SendData(FQuoteService.TCPIndex(stDDE), Pointer(AskData), Pointer(ReqLogin), nil, SizeOf(TAskData),
      SizeOf(TReqLogin), 0);
  end;
end;

procedure TQuoteBusiness.ReqDelayAutoPush_Ext(ServerType: ServerTypeEnum; CodeInfos: PCodeInfos; Count: integer);
var
  AskData: PAskData;
  Codes: PCodeInfos;
begin
  GetMemEx(Pointer(AskData), SizeOf(TAskData));
  FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

  GetMemEx(Pointer(Codes), SizeOf(TCodeInfo) * Count);
  Move(CodeInfos^[0], Codes^[0], SizeOf(TCodeInfo) * Count);

  // 延时扩展主推
  AskData^.m_nType := RT_AUTOPUSH_EXT_DELAY;
  AskData^.m_nSize := Count;
  FQuoteService.SendData(FQuoteService.TCPIndex(ServerType), AskData, Codes, nil, SizeOf(TAskData),
    SizeOf(TCodeInfo) * Count, 0);
end;

procedure TQuoteBusiness.ReqLevelUserLogin;
var
  AskData: PAskData;
  Data: PAnsiChar;
  Biz2Packer: TBiz2Packer;
begin
  Biz2Packer := TBiz2Packer.Create;
  try
    Biz2Packer.BeginPack;
    Biz2Packer.AddStringField('c_login_type', 255);
    Biz2Packer.AddStringField('vc_user', 255);
    Biz2Packer.AddStringField('vc_user_pw', 255);

    Biz2Packer.Field['c_login_type'].Value := '1';

    Biz2Packer.Field['vc_user'].Value := FQuoteDataMngr.LevelUser; // '1017';
    Biz2Packer.Field['vc_user_pw'].Value := FQuoteDataMngr.LevelPass; // '1017';
    Biz2Packer.EndPack();

    GetMemEx(Data, Biz2Packer.DataLength);
    CopyMemory(Data, Biz2Packer.GetData, Biz2Packer.DataLength);

    // 客户端登录
    GetMemEx(Pointer(AskData), SizeOf(TAskData));
    FillMemory(Pointer(AskData), SizeOf(TAskData), 0);

    AskData^.m_nType := RT_LOGIN_LEVEL;
    AskData^.m_nSize := Biz2Packer.DataLength;
    // FloorSize(Biz2Packer.DataLength , Sizeof(TCodeInfo));
    AskData^.m_Oper.m_cOperator := AnsiChar(Login_Option_Password);

    FQuoteService.SendData(FQuoteService.TCPIndex(stStockLevelII), Pointer(AskData), Data, nil, SizeOf(TAskData),
      Biz2Packer.DataLength, 0);

  finally
    Biz2Packer.Free;
  end;
end;

procedure TQuoteBusiness.UpdateCommLevelRealTime(RealTimeDataLevel: PRealTimeDataLevel; Count: integer;
  Codes: PCodeInfos);
var
  i, keyIndex: integer;
  RealTimeUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  KeysIndex: int64;
  Keys: TIntegerList;
begin

  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // 获取 QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin
      // 获取  IQuoteUpdate 开始更新数据
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
      RealTimeUpdate.BeginWrite; // 写入开始
      try
        // 获取  IQuoteUpdate 开始更新数据
        RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

        for i := 0 to Count - 1 do
        begin
          // Codeinfo
          keyIndex := QuoteRealTime.CodeToKeyIndex[RealTimeDataLevel^.m_ciStockCode.m_cCodeType,
            CodeInfoToCode(@RealTimeDataLevel^.m_ciStockCode)];
          // 更新
          if keyIndex >= 0 then
          begin
            RealTimeUpdate.Update(Update_RealTime_Level_RealTimeData, int64(RealTimeDataLevel), 0);
            if Codes <> nil then
              Codes^[i] := RealTimeDataLevel^.m_ciStockCode;
            Keys.Add(keyIndex);
            StocksBit64Index(KeysIndex, keyIndex);
          end;

          // 实际情况 位移数据

          inc(IntPtr(RealTimeDataLevel), SizeOf(TRealTimeDataLevel));
        end;
      finally
        RealTimeUpdate.EndWrite;
        RealTimeUpdate := nil;
      end;
      // 通知数据到达
      DoActiveMessage(QuoteType_Level_REALTIME, QuoteType_Level_REALTIME, Keys, KeysIndex);
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.UpdateCommRealTime(CommRealTimeData: PCommRealTimeData; Count: integer; Codes: PCodeInfos);
var
  i, keyIndex: integer;
  RealTimeUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  KeysIndex: int64;
  Keys: TIntegerList;
  OffSet: integer;
begin
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // 获取 QuoteRealTime
    OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherData);
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin
      // 获取  IQuoteUpdate 开始更新数据
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
      RealTimeUpdate.BeginWrite; // 写入开始
      try
        // 获取  IQuoteUpdate 开始更新数据
        // RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
        for i := 0 to Count - 1 do
        begin
          // Codeinfo
          keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData^.m_ciStockCode.m_cCodeType,
            CodeInfoToCode(@CommRealTimeData^.m_ciStockCode)];
          // 更新
          if keyIndex >= 0 then
          begin
            // 指数成交额单位改为元
            if { HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType,OTHER_MARKET) or } // 申万指数、中信指数、地域板块、概念板块成交额的单位为元
              (HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
              HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
            begin
              // 指数成交额以百元为单位
              CommRealTimeData.m_cNowData.m_indData.m_fAvgPrice :=
                CommRealTimeData.m_cNowData.m_indData.m_fAvgPrice * 100;
            end;

            RealTimeUpdate.Update(Update_RealTime_RealTimeData, int64(CommRealTimeData), 0);
            if Codes <> nil then
              Codes^[i] := CommRealTimeData^.m_ciStockCode;
            Keys.Add(keyIndex);
            StocksBit64Index(KeysIndex, keyIndex);
          end;
          if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OTHER_MARKET) then // 指数
            CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSIndexRealTime))
          else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, HK_MARKET) then // 香港
            CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSHKStockRealTime))
          else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, OPT_MARKET) then // 个股期权
            CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSOPTRealTime))
          else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, FUTURES_MARKET) then // 期货
            CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSQHRealTime))
          else if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, FOREIGN_MARKET) then
          begin
            if HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, YHJZQ_BOURSE) or // 银行间
              HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, XHCJ_BOURSE) or
              HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, ZYSHG_BOURSE) or
              HSBourseType(CommRealTimeData.m_ciStockCode.m_cCodeType, MDSHG_BOURSE) then

              CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSIBRealTime))
            else // 外汇
              CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSWHRealTime));
          end
          else
          begin
            if HSKindType(CommRealTimeData.m_ciStockCode.m_cCodeType, KIND_INDEX) then
              CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSIndexRealTime))
            else // A B 股
              CommRealTimeData := PCommRealTimeData(int64(CommRealTimeData) + OffSet + SizeOf(THSStockRealTime));
          end;
        end;
      finally
        RealTimeUpdate.EndWrite;
        RealTimeUpdate := nil;
      end;
      // 通知数据到达
      DoActiveMessage(QuoteType_REALTIME, QuoteType_REALTIME, Keys, KeysIndex);
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.UpdateCommRealTime_EXT(CommRealTimeData_Ext: PCommRealTimeData_Ext; Count: integer;
  Codes: PCodeInfos);
var
  i, keyIndex: integer;
  RealTimeUpdate: IQuoteUpdate;
  QuoteRealTime: IQuoteRealTime;
  KeysIndex: int64;
  Keys: TIntegerList;
  OffSet: integer;
begin
  KeysIndex := 0;
  QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
  if QuoteRealTime = nil then
    exit;
  Keys := TIntegerList.Create;
  try
    // 获取 QuoteRealTime
    OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + 2 * SizeOf(uShort);

    // 获取  IQuoteUpdate 开始更新数据
    RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);
    RealTimeUpdate.BeginWrite; // 写入开始
    try
      for i := 0 to Count - 1 do
      begin
        // Codeinfo
        keyIndex := QuoteRealTime.CodeToKeyIndex[CommRealTimeData_Ext^.m_ciStockCode.m_cCodeType,
          CodeInfoToCode(@CommRealTimeData_Ext^.m_ciStockCode)];
        // 更新
        if keyIndex >= 0 then
        begin
          // 指数成交额单位改为元
          if { HSMarketType(CommRealTimeData_ext.m_ciStockCode.m_cCodeType,OTHER_MARKET) or }
          // 申万指数、中信指数、地域板块、概念板块成交额的单位为元
            (HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, STOCK_MARKET) and
            HSKindType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, KIND_INDEX)) then
          begin
            // 指数成交额以百元为单位
            CommRealTimeData_Ext.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice :=
              CommRealTimeData_Ext.m_cNowData.m_indData.m_indexRealTime.m_fAvgPrice * 100;
          end;

          RealTimeUpdate.Update(Update_RealTime_RealTimeDataExt, int64(CommRealTimeData_Ext), 0);
          if Codes <> nil then
            Codes^[i] := CommRealTimeData_Ext^.m_ciStockCode;
          Keys.Add(keyIndex);
          StocksBit64Index(KeysIndex, keyIndex);
        end;
        if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, OTHER_MARKET) then // 指数
          // CommRealTimeData_ext := PCommRealTimeData_Ext(int64(CommRealTimeData_ext) + OffSet + sizeof(THSIndexRealTime_EXT))
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet +
            SizeOf(THSStockRealTime_Ext))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, HK_MARKET) then // 香港
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet +
            SizeOf(THSHKStockRealTime_EXT))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, OPT_MARKET) then // 个股期权
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSOPTRealTime))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, FUTURES_MARKET) then // 期货
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSQHRealTime))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, US_MARKET) then // 美股
          CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSUSStockRealTime))
        else if HSMarketType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, FOREIGN_MARKET) then
        begin
          if HSBourseType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, YHJZQ_BOURSE) or // 银行间
            HSBourseType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, XHCJ_BOURSE) or
            HSBourseType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, ZYSHG_BOURSE) or
            HSBourseType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, MDSHG_BOURSE) then

            CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSIBRealTime))
          else // 外汇
            CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet + SizeOf(THSWHRealTime));
        end
        else
        begin
          if HSKindType(CommRealTimeData_Ext.m_ciStockCode.m_cCodeType, KIND_INDEX) then
            CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet +
              SizeOf(THSStockRealTime_Ext))
          else // A B 股
            CommRealTimeData_Ext := PCommRealTimeData_Ext(int64(CommRealTimeData_Ext) + OffSet +
              SizeOf(THSStockRealTime_Ext));
        end;
      end;
    finally
      RealTimeUpdate.EndWrite;
      RealTimeUpdate := nil;
    end;
    // 通知数据到达
    DoActiveMessage(QuoteType_REALTIME, QuoteType_REALTIME, Keys, KeysIndex);
  finally
    Keys.Free;
    QuoteRealTime := nil;
  end;
end;

procedure TQuoteBusiness.WriteFile(const FileName: string; buff: Pointer; Size: integer);
var
  FileStrm: TFileStream;
begin
  if Size > 0 then
  begin
    // 删原先的文件
    if FileExists(FileName) then
      DeleteFile(FileName);

    FileStrm := TFileStream.Create(FileName, fmCreate);
    try
      FileStrm.Write(buff^, Size)
    finally
      FileStrm.Free;
    end;
  end;
end;

procedure TQuoteBusiness.AnsForeignBASEINFO(AnsIBBondBaseInfoData: PAnsIBBondBaseInfoData);
begin
  FQuoteService.WriteDebug('AnsForeignBASEINFO:' + inttostr(AnsIBBondBaseInfoData.m_nSize));

end;

procedure TQuoteBusiness.AnsForeignTECHDATA(AnsIBTechData: PAnsIBTechData);
begin
  FQuoteService.WriteDebug('AnsIBTechData:' + inttostr(AnsIBTechData.m_nSize));
end;

procedure TQuoteBusiness.AnsForeignTRANS(AnsIBTransData: PAnsIBTransData);
begin
  FQuoteService.WriteDebug('AnsIBTransData:' + inttostr(AnsIBTransData.m_nSize));
end;

procedure TQuoteBusiness.AnsIBTREND(AnsIBTrendData: PAnsIBTrendData);
var
  TrendUpdate: IQuoteUpdate;
  keyIndex: integer;
  QuoteRealTime: IQuoteRealTime;
begin
  keyIndex := -1;
  TrendUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @AnsIBTrendData^.m_dhHead.m_nPrivateKey.m_pCode]
    as IQuoteUpdate;
  if TrendUpdate <> nil then
  begin

    // TrendUpdate.Update(Update_Trend_TrendData, Int64(@AnsIBTrendData^.m_pVolData), AnsIBTrendData^.m_nCount);

    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
      with AnsIBTrendData^.m_dhHead.m_nPrivateKey.m_pCode do
        keyIndex := QuoteRealTime.CodeToKeyIndex[m_cCodeType,
          CodeInfoToCode(@AnsIBTrendData^.m_dhHead.m_nPrivateKey.m_pCode)];

    // 通知数据到达
    if keyIndex <> -1 then
      DoActiveMessage(QuoteType_TREND, QuoteType_TREND, nil, keyIndex);
  end;
end;

procedure TQuoteBusiness.AnsForeignUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('Foreign 登陆成功!');
  FQuoteService.SendEvent(etLoginForeign, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsFutuesUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('Futues 登陆成功!');
  FQuoteService.SendEvent(etLoginFutues, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('登陆成功!');
  FQuoteService.SendEvent(etLogin, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsUSStockUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('美股登陆成功!');
  FQuoteService.SendEvent(etLoginUSStock, nil, '', 0, 0);
end;

// DDE登陆应答
procedure TQuoteBusiness.AnsDDEUserLogin(AnsLogin: PAnsLogin);
begin
  FQuoteService.WriteDebug('DDE登陆成功!');
  FQuoteService.SendEvent(etLoginDDE, nil, '', 0, 0);
end;

procedure TQuoteBusiness.AnsDelayAutoPush_Ext(AnsRealTime: PAnsRealTime_Ext);
var
  i, OffSet: integer;
  KeysIndex: int64;
  QuoteRealTime: IQuoteRealTime;
  RealTimeUpdate: IQuoteUpdate;
  QuoteUpdate: IQuoteUpdate;

  CommRealTimeData: PCommRealTimeData_Ext;
  Keys: TIntegerList;
begin
  KeysIndex := 0;
  Keys := TIntegerList.Create;
  try
    // 获取 QuoteRealTime
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin
      // 获取  IQuoteUpdate 开始更新数据
      RealTimeUpdate := (QuoteRealTime as IQuoteUpdate);

      CommRealTimeData := @AnsRealTime^.m_pnowData[0];
      OffSet := SizeOf(TCodeInfo) + SizeOf(TStockOtherData) + 2 * SizeOf(uShort);
      for i := 0 to AnsRealTime.m_nSize - 1 do
      begin
        // 更新分时线
        QuoteUpdate := FQuoteDataMngr.QuoteDataObjs[QuoteType_TREND, @CommRealTimeData.m_ciStockCode] as IQuoteUpdate;
        if QuoteUpdate <> nil then
        begin
          QuoteUpdate.Update(Update_Trend_DelayAutoPush_Ext, int64(CommRealTimeData), 0)
        end;

        // 实际情况 位移数据  指数
        if HSMarketType(CommRealTimeData.m_ciStockCode.m_cCodeType, US_MARKET) then // 美股
          CommRealTimeData := PCommRealTimeData_Ext(int64(CommRealTimeData) + OffSet + SizeOf(THSUSStockRealTimeDelay));
      end;

      // 数据到达通知
      DoActiveMessage(QuoteType_REALTIME or QuoteType_TREND, QuoteType_REALTIME, Keys, KeysIndex);
    end;
  finally
    Keys.Free;
  end;
end;

procedure TQuoteBusiness.AnsLevelUserLogin(AnsLogin: PAnsLogin);
var
  nErrorNO: integer;
  strErrorInfo: string;
  BizUnpacker: TBiz2Unpacker;
  l_user_no: string;
  vc_User_Nickname: string;
  vc_Product_Name: string;
  vc_service_name: string;
  l_pro_end_date: integer;
  l_date: integer;
  c_pro_status: string;
begin
  if AnsLogin^.m_nError = 0 then
  begin
    nErrorNO := 0;
    strErrorInfo := '';
    l_pro_end_date := 0;
    l_date := 0;
    BizUnpacker := TBiz2Unpacker.Create;
    try
      BizUnpacker.Open(@AnsLogin^.m_szRet[0], AnsLogin^.m_nSize);
      if BizUnpacker.Exist['error_no'] then
      begin

        nErrorNO := BizUnpacker.Field['error_no'].Value;
        strErrorInfo := BizUnpacker.Field['error_info'].Value;
      end
      else if BizUnpacker.Exist['l_user_no'] then
      begin

        l_user_no := BizUnpacker.Field['l_user_no'].Value;
        vc_User_Nickname := BizUnpacker.Field['vc_User_Nickname'].Value;
        vc_Product_Name := BizUnpacker.Field['vc_Product_Name'].Value;
        vc_service_name := BizUnpacker.Field['vc_service_name'].Value;
        l_pro_end_date := BizUnpacker.Field['l_pro_end_date'].Value;
        l_date := BizUnpacker.Field['l_date'].Value;
        c_pro_status := BizUnpacker.Field['c_pro_status'].Value;
      end;

      if nErrorNO = 0 then
      begin
        FQuoteService.WriteDebug
          (format('Level2 登陆成功! no:%s Nickname:%s Product_Name:%s service_name:%s end_date:%d date:%d status:%s',
          [l_user_no, vc_User_Nickname, vc_Product_Name, vc_service_name, l_pro_end_date, l_date, c_pro_status]));

        FQuoteService.SendEvent(etLoginLevel, nil, '', 0, 0);
        DoResetMessage(stStockLevelII);
      end
      else
      begin
        FQuoteService.WriteDebug(format('[level2登录失败]错误号:%d，错误信息:%s', [nErrorNO, strErrorInfo]));

      end;
    finally
      BizUnpacker.Free;
    end;
  end;
end;

end.
