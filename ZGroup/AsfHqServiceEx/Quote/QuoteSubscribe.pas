unit QuoteSubscribe;

interface

uses Windows, Classes, SysUtils, QuoteService, QuoteLibrary, QuoteMngr_TLB,
  QuoteConst, QuoteStruct, IOCPMemory, IniFiles, QuoteBusiness, QuoteDataObject,
  QuoteDataMngr, QDOMarketMonitor, QDOSingleColValue;

type

  TQuoteSubscribe = class;

  // 订阅内容
  TSubscribeContent = class
  private
    FSubscribe: TQuoteSubscribe;
    FCookie: integer;
    FStocks: array of TCodeInfo;
    // 保存从RealTime里查到的key
    FCodeKeys: TIntegerList;
    // 保存 key 与 Stocks关系
    FKeysHash: TIntegerHash;
    FKeysIndex: Int64;
    FTag: integer;
    FQuoteType: QuoteTypeEnum;
  public
    constructor Create(Subscribe: TQuoteSubscribe; Cookie: integer; QuoteType: QuoteTypeEnum);
    destructor Destroy; override;
    procedure Subscribe(StockList: PCodeInfos; StockCount: integer); virtual;

    property CodeKeys: TIntegerList read FCodeKeys;
    property KeysHash: TIntegerHash read FKeysHash;
    function KeyToCodeInfo(key: integer): PCodeInfo;
    property Cookie: integer read FCookie;
    property Tag: integer read FTag write FTag;
    property QuoteType: QuoteTypeEnum read FQuoteType;
    property KeysIndex: Int64 read FKeysIndex;
  end;

  // 订阅对像 单线程对像
  TQuoteSubscribe = class
  private
    // 读写锁
    FReadWriteSync: TMultiReadExclusiveWriteSynchronizer;
    FQuoteService: TQuoteService;
    FQuoteDataMngr: TQuoteDataMngr;
    FQuoteBusiness: TQuoteBusiness;
    FMessageList: TInterfaceList;
    FContents: TList;
    FContentsHash: TString64Hash;
    function QuoteTypeToPeriod(QuoteType: QuoteTypeEnum): integer;
    // 发送订阅
    procedure SendSubscribe(QuoteType: QuoteTypeEnum; inStocks: PCodeInfos; inCount: integer; Value: OleVariant;
      Content: TSubscribeContent);
    // 订阅主推数据
    procedure SendAutoPush;
    procedure SendLevelAutoPush_REALTIME;
    procedure SendLevelAutoPush_TRANSACTION;
    procedure SendLevelAutoPush_ORDERQUEUE;

    // 合并第一步,取出股票代码
    procedure MergeStocks(QuoteType: QuoteTypeEnum; Stocks: TIntegerList; StocksHash: TIntegerHash);
    // 合并股票列表
    procedure MergeCodeInfo(QuoteType: QuoteTypeEnum; var outStocks: PCodeInfos; var outCount: integer);
    // 合并股票, 增量数据
    procedure MergeIncCode(QuoteType: QuoteTypeEnum; inStocks: PCodeInfos; inCount: integer; var outStocks: PCodeInfos;
      var outCount: integer);

    procedure FilterCode(Market, Market1: integer; inStocks: PCodeInfos; inCount: integer; var outStocks: PCodeInfos;
      var outCount: integer);

    function CreateDataObject(QuoteType: QuoteTypeEnum; Stock: PCodeInfo): IUnknown;

  protected
    procedure SubRealTime(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    procedure SubServerCalc(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    // procedure SubMultiTrend(Content: TSubscribeContent; inStocks: PCodeInfos;
    // inCount: integer; Value: OleVariant); // 订阅多日历史分时
    procedure SubTrend(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    Procedure SubHisTrend(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);

    Procedure SubStockTick(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);

    Procedure SubTechData(QuoteType: QuoteTypeEnum; Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
      Value: OleVariant);

    Procedure SubLimitTick(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);

    procedure SubGeneralSort(Content: TSubscribeContent; inStocks: PCodeInfos);
    procedure SubReportSort(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    procedure SubLevelRealTime(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    procedure SubLevel_Transaction(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    procedure SubLevel_OrderQueue(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    procedure SubLevel_CancellationSort(QuoteType: QuoteTypeEnum; Content: TSubscribeContent; inStocks: PCodeInfos;
      inCount: integer; Value: OleVariant);
    procedure SubSingleColValue(QuoteType: QuoteTypeEnum; Content: TSubscribeContent; inStocks: PCodeInfos;
      inCount: integer; Value: OleVariant);
    procedure SubMarketMonitor(Content: TSubscribeContent; Value: OleVariant);
    procedure SubDDEBigOrderRealTimeByOrder(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
      Value: OleVariant);
    procedure SendAutoPush_DDEBigOrderRealTimeByOrder;
  public
    constructor Create(QuoteService: TQuoteService; QuoteDataMngr: TQuoteDataMngr; QuoteBusiness: TQuoteBusiness);
    destructor Destroy; override;

    procedure DoActiveMessage(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeyIndex: Int64);
    procedure DoActiveMessageCookie(SendType: QuoteTypeEnum; Cookie: integer);
    procedure DoResetMessage(ServerType: ServerTypeEnum);

    // 注册消息机制
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage);
    // 取消消息机制
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage);
    // 订阅数据
    function Subscribe(QuoteType: QuoteTypeEnum; Stocks: PCodeInfos; Count, Cookie: integer; Value: OleVariant): WordBool;
  end;

implementation

{ TSubscribeContent }

constructor TSubscribeContent.Create(Subscribe: TQuoteSubscribe; Cookie: integer; QuoteType: QuoteTypeEnum);
begin
  FSubscribe := Subscribe;
  FCookie := Cookie;
  FQuoteType := QuoteType;
  FKeysHash := TIntegerHash.Create; // 开256个空间
  FCodeKeys := TIntegerList.Create;
end;

destructor TSubscribeContent.Destroy;
begin
  if Assigned(FKeysHash) then
    FreeAndNil(FKeysHash);
  if Assigned(FCodeKeys) then
    FreeAndNil(FCodeKeys);

  inherited Destroy;
end;

function TSubscribeContent.KeyToCodeInfo(key: integer): PCodeInfo;
var
  Code: integer;
begin
  Code := FKeysHash.ValueOf(key);
  if Code <> -1 then
    Result := PCodeInfo(Code)
  else
    Result := nil;
end;

procedure TSubscribeContent.Subscribe(StockList: PCodeInfos; StockCount: integer);
var
  i: integer;
  KeyIndex: Int64;
  QuoteRealTime: IQuoteRealTime;
begin
  // 创建空间
  SetLength(FStocks, StockCount);

  // 赋值
  Move(StockList^, FStocks[0], StockCount * SizeOf(TCodeInfo));
  QuoteRealTime := FSubscribe.FQuoteDataMngr.QuoteRealTime;
  if QuoteRealTime <> nil then
  begin
    // 建立 StocksHash 与SocksIndex
    FKeysHash.Clear;
    FCodeKeys.Clean;
    FKeysIndex := 0;
    QuoteRealTime.BeginRead;
    try
      for i := 0 to StockCount - 1 do
      begin
        KeyIndex := QuoteRealTime.CodeToKeyIndex[FStocks[i].m_cCodeType, CodeInfoToCode(@FStocks[i])];
        if KeyIndex >= 0 then
        begin
          FCodeKeys.Add(KeyIndex);
          FKeysHash.Add(KeyIndex, Int64(@FStocks[i]));
          StocksBit64Index(FKeysIndex, KeyIndex);
        end;
      end;
    finally
      QuoteRealTime.EndRead;
    end;
  end;
end;

{ TQuoteSubscribe }

constructor TQuoteSubscribe.Create(QuoteService: TQuoteService; QuoteDataMngr: TQuoteDataMngr;
  QuoteBusiness: TQuoteBusiness);
begin
  FContents := TList.Create;
  FContentsHash := TString64Hash.Create();
  FMessageList := TInterfaceList.Create;

  FQuoteService := QuoteService;
  FQuoteBusiness := QuoteBusiness;
  FQuoteDataMngr := QuoteDataMngr;
  FReadWriteSync := TMultiReadExclusiveWriteSynchronizer.Create;
end;

function TQuoteSubscribe.CreateDataObject(QuoteType: QuoteTypeEnum; Stock: PCodeInfo): IUnknown;
var
  Unknown: IUnknown;
begin
  Unknown := nil;
  case QuoteType of
    QuoteType_REALTIME, QuoteType_Level_REALTIME:
      begin
      end;
    QuoteType_HISTREND:
      begin // 分时走势
        Unknown := FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock];
        if Unknown = nil then
        begin
          Unknown := THisQuoteTrend.Create(FQuoteDataMngr, Stock);
          FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock] := Unknown;
        end;
      end;
    QuoteType_TREND:
      begin
        Unknown := FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock];
        if Unknown = nil then
        begin
          Unknown := TQuoteMultiTrend.Create(FQuoteDataMngr, Stock);
          FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock] := Unknown;
        end;
      end;
    QuoteType_STOCKTICK, QuoteType_LIMITTICK:
      begin // 个股分笔 限制 个股分笔
        Unknown := FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock];
        if Unknown = nil then
        begin
          Unknown := TQuoteStockTick.Create(FQuoteDataMngr, Stock);
          FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock] := Unknown;
        end;
      end;
    QuoteType_TECHDATA_MINUTE1, QuoteType_TECHDATA_MINUTE5, QuoteType_TECHDATA_MINUTE15, QuoteType_TECHDATA_MINUTE30,
      QuoteType_TECHDATA_MINUTE60, QuoteType_TECHDATA_DAY { ,
      QuoteType_TECHDATA_WEEK, QuoteType_TECHDATA_MONTH } :
      begin // 分析周期：1分钟 5分钟 日
        Unknown := FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock];
        if Unknown = nil then
        begin
          Unknown := TQuoteTechData.Create(FQuoteDataMngr, Stock, QuoteType);
          FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock] := Unknown;
        end;
      end;
    QuoteType_Level_TRANSACTION:
      begin
        Unknown := FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock];
        if Unknown = nil then
        begin
          Unknown := TQuoteLevelTransaction.Create(FQuoteDataMngr, Stock);
          FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock] := Unknown;
        end;
      end;
    QuoteType_Level_ORDERQUEUE:
      begin
        Unknown := FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock];
        if Unknown = nil then
        begin
          Unknown := TQuoteLevelOrderQueue.Create(FQuoteDataMngr, Stock);
          FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock] := Unknown;
        end;
      end;
    QuoteType_Level_SINGLEMA:
      begin
        Unknown := FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock];
        if Unknown = nil then
        begin
          Unknown := TQuoteLevelSINGLEMA.Create(FQuoteDataMngr, Stock);
          FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock] := Unknown;
        end;
      end;
    QuoteType_Level_TOTALMAX:
      begin
        Unknown := FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock];
        if Unknown = nil then
        begin
          Unknown := TQuoteLevelTOTALMAX.Create(FQuoteDataMngr, Stock);
          FQuoteDataMngr.QuoteDataObjs[QuoteType, Stock] := Unknown;
        end;
      end;
    QuoteType_MarketMonitor: // 短线精灵
      begin
        Unknown := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType, ''];
        if Unknown = nil then
        begin
          Unknown := TQuoteMarketMonitor.Create(FQuoteDataMngr);
          FQuoteDataMngr.QuoteDataObjsByKey[QuoteType, ''] := Unknown;
        end;
      end;
  end;
  Result := Unknown;
end;

destructor TQuoteSubscribe.Destroy;
begin
  if FMessageList <> nil then
  begin
    FMessageList.Free;
    FMessageList := nil;
  end;

  if FContentsHash <> nil then
  begin
    FContentsHash.Free;
    FContentsHash := nil;
  end;

  if FContents <> nil then
  begin
    FreeAndClean(FContents);
    FContents.Free;
    FContents := nil;
  end;

  if FReadWriteSync <> nil then
  begin
    FReadWriteSync.Free;
    FReadWriteSync := nil;
  end;

  inherited Destroy;
end;

procedure TQuoteSubscribe.MergeCodeInfo(QuoteType: QuoteTypeEnum; var outStocks: PCodeInfos; var outCount: integer);
var
  i: integer;
  StocksHash: TIntegerHash;
  Stocks: TIntegerList;
begin
  outStocks := nil;
  outCount := 0;
  Stocks := TIntegerList.Create;
  StocksHash := TIntegerHash.Create();
  try
    // 列出股票代码
    MergeStocks(QuoteType, Stocks, StocksHash);

    // 填充返回值
    outCount := Stocks.Count;
    if outCount > 0 then
    begin
      GetMemEx(Pointer(outStocks), SizeOf(TCodeInfo) * outCount);
      FillMemory(outStocks, SizeOf(TCodeInfo) * outCount, 0);
      for i := 0 to Stocks.Count - 1 do
      begin
        outStocks^[i] := PCodeInfo(Stocks[i])^;
      end;
    end;
  finally
    StocksHash.Free;
    Stocks.Free;
  end;
end;

procedure TQuoteSubscribe.MergeIncCode(QuoteType: QuoteTypeEnum; inStocks: PCodeInfos; inCount: integer;
  var outStocks: PCodeInfos; var outCount: integer);
var
  i, KeyIndex: integer;
  StocksHash: TIntegerHash;
  StocksList: TIntegerList;
  QuoteRealTime: IQuoteRealTime;
begin
  outStocks := nil;
  outCount := 0;
  StocksList := TIntegerList.Create;
  StocksHash := TIntegerHash.Create();
  try
    // 列出股票代码
    MergeStocks(QuoteType, StocksList, StocksHash);

    // 填充返回值
    QuoteRealTime := FQuoteDataMngr.QuoteRealTime;
    if QuoteRealTime <> nil then
    begin

      GetMemEx(Pointer(outStocks), SizeOf(TCodeInfo) * inCount);
      FillMemory(outStocks, SizeOf(TCodeInfo) * inCount, 0);

      outCount := 0;

      QuoteRealTime.BeginRead;
      try
        for i := 0 to inCount - 1 do
        begin
          KeyIndex := QuoteRealTime.CodeToKeyIndex[inStocks[i].m_cCodeType, CodeInfoToCode(@inStocks[i])];
          // 不存在
          if StocksHash.ValueOf(KeyIndex) = -1 then
          begin
            outStocks^[outCount] := inStocks^[i];
            inc(outCount);
          end;
        end;
      finally
        QuoteRealTime.EndRead;
      end;
    end;
  finally
    StocksHash.Free;
    StocksList.Free;
  end;
end;

procedure TQuoteSubscribe.MergeStocks(QuoteType: QuoteTypeEnum; Stocks: TIntegerList; StocksHash: TIntegerHash);
var
  i, v, key, index: integer;
  codeinfo: NativeInt;
  Content: TSubscribeContent;
begin
  // 开始读
  FReadWriteSync.BeginRead;
  try
    for i := 0 to FContents.Count - 1 do
    begin
      Content := TSubscribeContent(FContents[i]);
      if ((Content.QuoteType and QuoteType) <> 0) then
      begin
        for v := 0 to Content.CodeKeys.Count - 1 do
        begin
          key := Content.CodeKeys[v];
          index := StocksHash.ValueOf(key);
          if index < 0 then
          begin
            codeinfo := Int64(Content.KeyToCodeInfo(key));
            if codeinfo <> 0 then
            begin
              // 保存 CodeInfo
              Stocks.Add(codeinfo);
              // 建索引
              StocksHash.Add(key, 1);
            end;
          end;
        end;
      end;
    end;
  finally
    FReadWriteSync.EndRead;
  end;
end;

function TQuoteSubscribe.QuoteTypeToPeriod(QuoteType: QuoteTypeEnum): integer;
begin
  case QuoteType of
    QuoteType_TECHDATA_MINUTE1:
      Result := PERIOD_TYPE_MINUTE1;
    QuoteType_TECHDATA_MINUTE5:
      Result := PERIOD_TYPE_MINUTE5;
    QuoteType_TECHDATA_MINUTE15:
      Result := PERIOD_TYPE_MINUTE15;
    QuoteType_TECHDATA_MINUTE30:
      Result := PERIOD_TYPE_MINUTE30;
    QuoteType_TECHDATA_MINUTE60:
      Result := PERIOD_TYPE_MINUTE60;
    { QuoteType_TECHDATA_WEEK:
      result := PERIOD_TYPE_WEEK;
      QuoteType_TECHDATA_MONTH:
      result := PERIOD_TYPE_MONTH; }
  else
    Result := PERIOD_TYPE_DAY; // QuoteType_TECHDATA_DAY:
  end;
end;

procedure TQuoteSubscribe.ConnectMessage(const QuoteMessage: IQuoteMessage);
begin
  // 开始写
  FReadWriteSync.BeginWrite;
  try
    QuoteMessage.MsgCookie := FMessageList.Add(QuoteMessage);
  finally
    FReadWriteSync.EndWrite;
  end;
end;

procedure TQuoteSubscribe.DisconnectMessage(const QuoteMessage: IQuoteMessage);
begin
  // 开始读
  FReadWriteSync.BeginWrite;
  try
    // TInterfaceList 多线程 保护
    if (QuoteMessage.MsgCookie >= 0) and (QuoteMessage.MsgCookie < FMessageList.Count) and
      (FMessageList[QuoteMessage.MsgCookie] as IQuoteMessage = QuoteMessage) then
    begin
      FMessageList[QuoteMessage.MsgCookie] := nil;
    end;
  finally
    FReadWriteSync.EndWrite;
  end;

  // 去除所有定义 ???????
  if FQuoteService.Active then
  begin
    Subscribe(QuoteType_REALTIME, nil, 0, QuoteMessage.MsgCookie, 0); // 排名报价表
    Subscribe(QuoteType_REPORTSORT, nil, 0, QuoteMessage.MsgCookie, 0); // 排名报排名
    Subscribe(QuoteType_GENERALSORT, nil, 0, QuoteMessage.MsgCookie, 0); // 综合排名
    Subscribe(QuoteType_TREND, nil, 0, QuoteMessage.MsgCookie, 0); // 分时走势
    Subscribe(QuoteType_STOCKTICK, nil, 0, QuoteMessage.MsgCookie, 0); // 个股分笔
    Subscribe(QuoteType_LIMITTICK, nil, 0, QuoteMessage.MsgCookie, 0); // 个股分笔
    Subscribe(QuoteType_TECHDATA_MINUTE1, nil, 0, QuoteMessage.MsgCookie, 0);
    // 盘后分析
    Subscribe(QuoteType_TECHDATA_MINUTE5, nil, 0, QuoteMessage.MsgCookie, 0);
    // 盘后分析
    Subscribe(QuoteType_TECHDATA_DAY, nil, 0, QuoteMessage.MsgCookie, 0);
    // 盘后分析
    Subscribe(QuoteType_TECHDATA_MINUTE15, nil, 0, QuoteMessage.MsgCookie, 0);
    // 盘后分析
    Subscribe(QuoteType_TECHDATA_MINUTE30, nil, 0, QuoteMessage.MsgCookie, 0);
    // 盘后分析
    Subscribe(QuoteType_TECHDATA_MINUTE60, nil, 0, QuoteMessage.MsgCookie, 0);
    // 盘后分析
    // Subscribe(QuoteType_TECHDATA_WEEK, nil, 0, QuoteMessage.MsgCookie, 0);
    // 盘后分析
    // Subscribe(QuoteType_TECHDATA_MONTH, nil, 0, QuoteMessage.MsgCookie, 0);
    // 盘后分析

    Subscribe(QuoteType_Level_REALTIME, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2十档行情
    Subscribe(QuoteType_Level_TRANSACTION, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2逐笔成交
    Subscribe(QuoteType_Level_ORDERQUEUE, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2盘口数据
    Subscribe(QuoteType_Level_SINGLEMA, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2盘口数据
    Subscribe(QuoteType_Level_TOTALMAX, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2盘口数据

    // 取单列行情数据
    Subscribe(QuoteType_SingleColValue, nil, 0, QuoteMessage.MsgCookie, 0);
    // 市场精灵订阅 QuoteType_MarketMonitor
    Subscribe(QuoteType_Level_TOTALMAX, nil, 0, QuoteMessage.MsgCookie, 0);
  end;
end;

procedure TQuoteSubscribe.DoActiveMessage(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeyIndex: Int64);
var
  i, v: integer;
  Content: TSubscribeContent;
  QuoteMessage: IQuoteMessage;
begin
  // 开始读
  FReadWriteSync.BeginRead;
  try
    for i := 0 to FContents.Count - 1 do
    begin
      Content := TSubscribeContent(FContents[i]);
      // 判断 Content 类型
      // OutputDebugString(pchar(format('Content.Index:%d type %d',[i,Content.QuoteType])));
      if (Content.QuoteType and MaskType <> 0) then
      begin
        // keys=nil 表明,只有一个股票发生变化

        if Keys = nil then
        begin
          if KeyIndex = -1 then
          begin
            QuoteMessage := (FMessageList[Content.Cookie] as IQuoteMessage);
            if (QuoteMessage <> nil) and QuoteMessage.MsgActive then
            begin
              PostMessage(QuoteMessage.MsgHandle, WM_DataArrive, SendType, 0);
            end;
          end
          else if Content.KeysHash.ValueOf(KeyIndex) <> -1 then
          begin
            if (Content.Cookie >= 0) and (Content.Cookie < FMessageList.Count) then
            begin
              QuoteMessage := (FMessageList[Content.Cookie] as IQuoteMessage);
              if (QuoteMessage <> nil) and QuoteMessage.MsgActive then
              begin
                PostMessage(QuoteMessage.MsgHandle, WM_DataArrive, SendType, 0);
              end;
            end;
          end;
        end
        else if (Content.KeysIndex and KeyIndex <> 0) then
        begin // 多只股票
          // 循环验证 是否要发通知
          for v := 0 to Keys.Count - 1 do
          begin
            if Content.KeysHash.ValueOf(Keys[v]) <> -1 then
            begin
              if (Content.Cookie >= 0) and (Content.Cookie < FMessageList.Count) then
              begin
                QuoteMessage := (FMessageList[Content.Cookie] as IQuoteMessage);
                if (QuoteMessage <> nil) and QuoteMessage.MsgActive then
                begin
                  PostMessage(QuoteMessage.MsgHandle, WM_DataArrive, SendType, 0);
                end;
              end;
              break;
            end;
          end;
        end;
      end;
    end;
  finally
    FReadWriteSync.EndRead;
  end;
end;

procedure TQuoteSubscribe.DoActiveMessageCookie(SendType: QuoteTypeEnum; Cookie: integer);
var
  QuoteMessage: IQuoteMessage;
begin
  // 开始读
  FReadWriteSync.BeginRead;
  try
    if (Cookie >= 0) and (Cookie < FMessageList.Count) then
    begin
      QuoteMessage := (FMessageList[Cookie] as IQuoteMessage);
      if (QuoteMessage <> nil) and QuoteMessage.MsgActive then
      begin
        PostMessage(QuoteMessage.MsgHandle, WM_DataArrive, SendType, 0);
      end;
    end;
  finally
    FReadWriteSync.EndRead;
  end;
end;

procedure TQuoteSubscribe.DoResetMessage(ServerType: ServerTypeEnum);
var
  i: integer;
  QuoteMessage: IQuoteMessage;
begin
  // 开始读
  FReadWriteSync.BeginWrite;
  try
    // OutputDebugString(PWideChar('DoResetMessage BeginWrite'));
    // 清除所有订阅内容
    FContentsHash.Clear;
    FreeAndClean(FContents);

    for i := 0 to FMessageList.Count - 1 do
    begin
      QuoteMessage := FMessageList[i] as IQuoteMessage;
      if (QuoteMessage <> nil) and QuoteMessage.MsgActive then
        PostMessage(QuoteMessage.MsgHandle, WM_DataReset, ServerType, 0);
    end;
  finally
    // OutputDebugString(PWideChar('DoResetMessage EndWrite'));
    FReadWriteSync.EndWrite;
  end;
end;

procedure TQuoteSubscribe.FilterCode(Market, Market1: integer; inStocks: PCodeInfos; inCount: integer;
  var outStocks: PCodeInfos; var outCount: integer);
var
  i: integer;
begin
  GetMemEx(Pointer(outStocks), SizeOf(TCodeInfo) * inCount);
  FillMemory(outStocks, SizeOf(TCodeInfo) * inCount, 0);
  outCount := 0;
  for i := 0 to inCount - 1 do
  begin
    // 不存在
    if HSMarketType(inStocks^[i].m_cCodeType, Market) then
    begin
      outStocks^[outCount] := inStocks^[i];
      inc(outCount);
    end
    else if (Market1 <> 0) and HSMarketType(inStocks^[i].m_cCodeType, Market1) then
    begin
      outStocks^[outCount] := inStocks^[i];
      inc(outCount);
    end;
  end;
end;

procedure TQuoteSubscribe.SendAutoPush;
var
  Count, FilterCount: integer;
  CodeInfos, FilterStocks: PCodeInfos;
begin
  // 2. 报价牌+分时线+分笔 调阅推送  生成定义的代码列表
  MergeCodeInfo(QuoteType_REALTIME or QuoteType_TREND or QuoteType_STOCKTICK or QuoteType_HISTREND or QuoteType_LIMITTICK,
    CodeInfos, Count);
  try
    // 沪深 发送订阅请求
    FilterCode(STOCK_MARKET, OTHER_MARKET, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterStocks <> nil) then
        FQuoteBusiness.ReqAutoPush_Ext(stStockLevelI, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // 个股期权
    FilterCode(OPT_MARKET, 0, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterCount > 0) then
        FQuoteBusiness.ReqAutoPush_Ext(stStockLevelI, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // 期货 发送订阅请求
    FilterCode(FUTURES_MARKET, 0, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterCount > 0) then
        FQuoteBusiness.ReqAutoPush_Ext(stFutues, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // 港股 发送订阅请求
    FilterCode(HK_MARKET, 0, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterCount > 0) then
        FQuoteBusiness.ReqAutoPush_Ext(stStockHK, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // 美股 发送订阅请求
    FilterCode(US_MARKET, 0, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterCount > 0) then
      begin
        FQuoteBusiness.ReqAutoPush_Ext(stUSStock, FilterStocks, FilterCount);
        FQuoteBusiness.ReqDelayAutoPush_Ext(stUSStock, FilterStocks, FilterCount);
      end;
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // 银行间债券 发送订阅请求
    FilterCode(FOREIGN_MARKET, 0, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterCount > 0) then
        FQuoteBusiness.ReqAutoPush(stForeign, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;
  finally
    if CodeInfos <> nil then
      FreeMemEx(CodeInfos);
  end;
end;

procedure TQuoteSubscribe.SendLevelAutoPush_ORDERQUEUE;
var
  Count: integer;
  CodeInfos: PCodeInfos;
begin
  // 2. 报价牌+分时线+分笔 调阅推送  生成定义的代码列表
  MergeCodeInfo(QuoteType_Level_ORDERQUEUE, CodeInfos, Count);
  try
    // 发送订阅请求
    // if Count > 0  then begin
    FQuoteBusiness.ReqAutoPushLevelOrderQueue(CodeInfos, Count, '1');
    FQuoteBusiness.ReqAutoPushLevelOrderQueue(CodeInfos, Count, '2');
    // end;
  finally
    FreeMemEx(CodeInfos);
  end;
end;

procedure TQuoteSubscribe.SendLevelAutoPush_REALTIME;
var
  Count: integer;
  CodeInfos: PCodeInfos;
begin
  // 2. 报价牌+分时线+分笔 调阅推送  生成定义的代码列表
  MergeCodeInfo(QuoteType_Level_REALTIME, CodeInfos, Count);
  try
    // 发送订阅请求
    // if Count > 0  then
    FQuoteBusiness.ReqAutoPushLevelRealTime(CodeInfos, Count);
  finally
    FreeMemEx(CodeInfos);
  end;
end;

procedure TQuoteSubscribe.SendLevelAutoPush_TRANSACTION;
var
  Count: integer;
  CodeInfos: PCodeInfos;
begin
  // 2. 报价牌+分时线+分笔 调阅推送  生成定义的代码列表
  MergeCodeInfo(QuoteType_Level_TRANSACTION, CodeInfos, Count);
  try
    // 发送订阅请求
    // if Count > 0  then
    FQuoteBusiness.ReqAutoPushLevelTransaction(CodeInfos, Count);
  finally
    FreeMemEx(CodeInfos);
  end;
end;

procedure TQuoteSubscribe.SendSubscribe(QuoteType: QuoteTypeEnum; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant; Content: TSubscribeContent);

begin
  if Content = nil then
    Exit;

  case QuoteType of
    // 报价牌
    QuoteType_REALTIME:
      SubRealTime(Content, inStocks, inCount, Value);
    QuoteType_TREND: // 分时走势
      SubTrend(Content, inStocks, inCount, Value);
    QuoteType_LimitPrice:
      SubServerCalc(Content, inStocks, inCount, Value);
    // QuoteType_LimitPrice:
    // SubMultiTrend(Content, inStocks, inCount, Value);
    QuoteType_HISTREND:
      begin
        SubHisTrend(Content, inStocks, inCount, Value);
      end;
    QuoteType_STOCKTICK:
      SubStockTick(Content, inStocks, inCount, Value);

    QuoteType_LIMITTICK:
      SubLimitTick(Content, inStocks, inCount, Value);
    QuoteType_TECHDATA_DAY, QuoteType_TECHDATA_MINUTE1, QuoteType_TECHDATA_MINUTE5, QuoteType_TECHDATA_MINUTE15,
      QuoteType_TECHDATA_MINUTE30, QuoteType_TECHDATA_MINUTE60 { ,
      QuoteType_TECHDATA_WEEK, QuoteType_TECHDATA_MONTH } :
      SubTechData(QuoteType, Content, inStocks, inCount, Value);

    QuoteType_REPORTSORT:
      SubReportSort(Content, inStocks, inCount, Value);
    QuoteType_GENERALSORT:
      SubGeneralSort(Content, inStocks);
    // Level2十档行情查询
    QuoteType_Level_REALTIME:
      SubLevelRealTime(Content, inStocks, inCount, Value);

    // 逐笔成交查询
    QuoteType_Level_TRANSACTION:
      SubLevel_Transaction(Content, inStocks, inCount, Value);

    // 盘口数据查询
    QuoteType_Level_ORDERQUEUE:
      SubLevel_OrderQueue(Content, inStocks, inCount, Value);

    // 单笔撤单主推排名 累计撤单主推排名
    QuoteType_Level_SINGLEMA, QuoteType_Level_TOTALMAX:
      SubLevel_CancellationSort(QuoteType, Content, inStocks, inCount, Value);
    QuoteType_SingleColValue:
      SubSingleColValue(QuoteType, Content, inStocks, inCount, Value);
    QuoteType_MarketMonitor:
      SubMarketMonitor(Content, Value);
    QuoteType_DDEBigOrderRealTimeByOrder:
      SubDDEBigOrderRealTimeByOrder(Content, inStocks, inCount, Value);
  end;
end;

function TQuoteSubscribe.Subscribe(QuoteType: QuoteTypeEnum; Stocks: PCodeInfos; Count, Cookie: integer;
  Value: OleVariant): WordBool;
var
  index: integer;
  iContent: Int64;
  Content: TSubscribeContent;
begin
  Result := true;
  // 开始读
  FReadWriteSync.BeginWrite;
  try
    iContent := FContentsHash.ValueOf(FQuoteDataMngr.QuoteTypeToString(QuoteType) + inttostr(Cookie));
    // Stocks为空 = 取消订阅
    if Stocks = nil then
    begin
      if iContent <> -1 then
      begin
        Content := TSubscribeContent(iContent);
        // 删除 Hash
        FContentsHash.Remove(FQuoteDataMngr.QuoteTypeToString(QuoteType) + inttostr(Cookie));

        // 删除 Content
        Index := FContents.IndexOf(Content);
        if Index >= 0 then
          FContents.Delete(Index);

        if Content <> nil then
        begin
          FQuoteDataMngr.QuoteDataObjsByKey[QuoteType, inttostr(Content.Cookie)] := nil;
          Content.Free;
          Content := nil;
        end;
        SendSubscribe(QuoteType, Stocks, Count, Value, Content);
      end;
    end
    else
    begin
      if iContent = -1 then
      begin
        // 创建 对像 并添加到Hash里
        Content := TSubscribeContent.Create(self, Cookie, QuoteType);
        FContents.Add(Content);
        FContentsHash.Add(FQuoteDataMngr.QuoteTypeToString(QuoteType) + inttostr(Cookie), Int64(Content));
      end
      else
        Content := TSubscribeContent(iContent);
      SendSubscribe(QuoteType, Stocks, Count, Value, Content);
    end;
  finally
    FReadWriteSync.EndWrite;
  end;
end;

procedure TQuoteSubscribe.SubRealTime(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outCount, FilterCount: integer;
  outStocks, FilterStocks: PCodeInfos;
begin
  // 订阅增量
  MergeIncCode(QuoteType_REALTIME, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 沪深 发送订阅请求
      FilterCode(STOCK_MARKET, OTHER_MARKET, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stStockLevelI, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;
      // 个股期权 发送订阅请求
      FilterCode(OPT_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stStockLevelI, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;

      // 期货 发送订阅请求
      FilterCode(FUTURES_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stFutues, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;
      // 港股
      FilterCode(HK_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stStockHK, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;

      //美股
      FilterCode(US_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stUSStock, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;

      // 银行间证券
      FilterCode(FOREIGN_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stForeign, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;
    end;

  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 主推请求
  SendAutoPush;
end;

procedure TQuoteSubscribe.SubServerCalc(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outCount, FilterCount: integer;
  outStocks, FilterStocks: PCodeInfos;
begin
  // 订阅增量
  MergeIncCode(QuoteType_LimitPrice, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 沪深 发送订阅请求
      FilterCode(STOCK_MARKET, OTHER_MARKET, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqSeverCalculate(stStockLevelI, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;
      // // 个股期权 发送订阅请求
      // FilterCode(OPT_MARKET,0, outStocks, outCount,FilterStocks, FilterCount);
      // try
      // if (FilterCount > 0) and (FilterStocks <> nil) then
      // FQuoteBusiness.ReqRealTime_Ext(stStockLevelI, FilterStocks,FilterCount);
      // finally
      // if FilterStocks <> nil then
      // FreeMemEx(FilterStocks);
      // end;

      // 期货 发送订阅请求
      FilterCode(FUTURES_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqSeverCalculate(stFutues, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
end;

procedure TQuoteSubscribe.SubTrend(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i, j: integer;
  MiltiTrend: IQuoteMultiTrend;
begin
  // 订阅增量
  MergeIncCode(QuoteType_TREND, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 发送请求
      for i := 0 to outCount - 1 do
      begin
        // 创建分时对象
        MiltiTrend := CreateDataObject(QuoteType_TREND, @outStocks[i]) as IQuoteMultiTrend;
        // if MiltiTrend.Datas[0].Count = 0 then
        // begin
        // 银行间证券
        if HSMarketType(outStocks[i].m_cCodeType, FOREIGN_MARKET) then
        begin
          FQuoteBusiness.ReqIBTREND(ToServerType(outStocks[i].m_cCodeType), @outStocks[i])
        end
        else if IsStockMajorIndex(@outStocks[i]) then // 上证指数 或 深证成指
        begin
          FQuoteBusiness.ReqMILeadData(stStockLevelI, @outStocks[i]);
          FQuoteBusiness.ReqMITickData(stStockLevelI, @outStocks[i]);
        end
        else
        begin
          if HSMarketType(outStocks[i].m_cCodeType, STOCK_MARKET) then
          begin
            FQuoteBusiness.ReqhisTrend(stStockLevelI, @outStocks[i], 0, 99999);
            // FQuoteBusiness.ReqTrend_Ext(stStockLevelI,@outStocks[i]);
          end
          else
          begin
            if HSMarketType(outStocks[i].m_cCodeType, FUTURES_MARKET) then // 期货
              FQuoteBusiness.ReqTrend(ToServerType(outStocks[i].m_cCodeType), @outStocks[i])
            else
              FQuoteBusiness.ReqhisTrend(ToServerType(outStocks[i].m_cCodeType), @outStocks[i], 0, 99999); // 包含美股
          end;
          // 沪深市场 请求集合竞价数据
          if MiltiTrend.Datas[0].IsVAData then
            FQuoteBusiness.ReqVirtualAuction(stStockLevelI, @outStocks[i].m_cCodeType);
        end;
        // end;
      end;
    end;
    for i := 0 to inCount - 1 do
    begin
      MiltiTrend := CreateDataObject(QuoteType_TREND, @inStocks[i]) as IQuoteMultiTrend;
      if MiltiTrend.Count < Value then
      begin
        for j := MiltiTrend.Count to Value - 1 do
        begin
          FQuoteBusiness.ReqhisTrend(ToServerType(inStocks[i].m_cCodeType), @inStocks[i], -j, -j);
        end;
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 主推请求
  SendAutoPush;
end;

Procedure TQuoteSubscribe.SubHisTrend(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
  QuoteTrend: IQuoteTrendHis;
begin
  // 订阅增量
  MergeIncCode(QuoteType_HISTREND, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 发送请求
      for i := 0 to outCount - 1 do
      begin
        // 创建分时对象
        QuoteTrend := CreateDataObject(QuoteType_HISTREND, @outStocks[i]) as IQuoteTrendHis;
        QuoteTrend.ResetDate(Value);
        FQuoteBusiness.ReqhisTrend(ToServerType(outStocks[i].m_cCodeType), @outStocks[i], Value, Value);
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 主推请求
  // SendAutoPush;
end;

Procedure TQuoteSubscribe.SubStockTick(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin // 个股分笔
  // 订阅增量
  MergeIncCode(QuoteType_STOCKTICK, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 发送请求
      for i := 0 to outCount - 1 do
      begin
        // 创建分笔对象
        CreateDataObject(QuoteType_STOCKTICK, @outStocks[i]);
        FQuoteBusiness.ReqStockTick(ToServerType(outStocks[i].m_cCodeType), @outStocks[i]);
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 主推请求
  SendAutoPush;
end;

Procedure TQuoteSubscribe.SubTechData(QuoteType: QuoteTypeEnum; Content: TSubscribeContent; inStocks: PCodeInfos;
  inCount: integer; Value: OleVariant);
var
  TechData: IQuoteUpdate;
  iValue: Int64;
  sValue: WideString;
  oValue: OleVariant;
  i: integer;
begin
  // 发送订阅请求
  if (inCount > 0) and (inStocks <> nil) then
  begin
    // 发送请求
    for i := 0 to inCount - 1 do
    begin
      // 创建分时对象

      TechData := CreateDataObject(QuoteType, @inStocks[i]) as IQuoteUpdate;

      // 注意: 反复缩小K线, 或多周期同列会对数据反复请求
      // 这里做个处理 标志是否忙碌, 合并最大值请求K线
      if TechData <> nil then
      begin
        TechData.BeginWrite;
        try
          TechData.DataState(State_Tech_IsBusy, iValue, sValue, oValue);
          if iValue <> 1 then // 不忙碌 发送请求
            FQuoteBusiness.ReqTechData(ToServerType(inStocks[i].m_cCodeType), @inStocks[i], TechData,
              QuoteTypeToPeriod(QuoteType), Value)
            // 合并请求个数(最大值)请求K线
          else
            TechData.Update(Update_Tech_WaitCount, 0, Value);
        finally
          TechData.EndWrite;
        end;
      end;
    end;
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 主推请求
  SendAutoPush;
end;

Procedure TQuoteSubscribe.SubLimitTick(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin
  // 订阅增量
  MergeIncCode(QuoteType_LIMITTICK, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 发送请求
      for i := 0 to outCount - 1 do
      begin
        // 创建分笔对象
        CreateDataObject(QuoteType_LIMITTICK, @outStocks[i]);
        FQuoteBusiness.ReqLimitTick(ToServerType(outStocks[i].m_cCodeType), @outStocks[i], Value);
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 主推请求
  SendAutoPush;
end;

procedure TQuoteSubscribe.SubGeneralSort(Content: TSubscribeContent; inStocks: PCodeInfos);
var
  Unknown: IUnknown;
  ReqGeneralSort: PReqGeneralSortEx;
begin // 综合排名
  // 只做一个定时器来定时求情
  // 创建 排名报价表 对象
  Unknown := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_GENERALSORT, inttostr(Content.Cookie)];
  if Unknown = nil then
  begin
    Unknown := TQuoteGeneralSort.Create(FQuoteDataMngr);
    FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_GENERALSORT, inttostr(Content.Cookie)] := Unknown;
  end;
  (Unknown as IQuoteUpdate).Update(Update_GeneralSort_ReqGeneralSort, Int64(inStocks), 0);
  ReqGeneralSort := PReqGeneralSortEx(inStocks);
  FQuoteBusiness.ReqGeneralSortEx(ToServerType(ReqGeneralSort.m_cCodeType), Content.Cookie, ReqGeneralSort);
end;

procedure TQuoteSubscribe.SubReportSort(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  Unknown: IUnknown;
begin // 排名报价表
  // 只做一个定时器来定时求情
  // 创建 排名报价表 对象
  Unknown := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_REPORTSORT, inttostr(Content.Cookie)];
  if Unknown = nil then
  begin
    Unknown := TQuoteReportSort.Create(FQuoteDataMngr, inStocks, inCount, PReqReportSort(Int64(Value)));
    FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_REPORTSORT, inttostr(Content.Cookie)] := Unknown;
  end
  else
    (Unknown as IQuoteUpdate).Update(QuoteType_REPORTSORT, Int64(inStocks), 0);
  // 发送订阅请求
  FQuoteBusiness.ReqPeportSort(ToServerType(inStocks[0].m_cCodeType), inStocks, inCount, Content.Cookie,
    PReqReportSort(Int64(Value)));

end;

procedure TQuoteSubscribe.SubLevelRealTime(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount: integer;
begin
  // 订阅增量
  MergeIncCode(QuoteType_Level_REALTIME, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
      FQuoteBusiness.ReqLevelRealTime(outStocks, outCount);
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 Level2十档行情订阅
  SendLevelAutoPush_REALTIME;
end;

procedure TQuoteSubscribe.SubLevel_Transaction(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin
  // 订阅增量
  MergeIncCode(QuoteType_Level_TRANSACTION, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 发送请求
      for i := 0 to outCount - 1 do
      begin
        // 创建分笔对象
        CreateDataObject(QuoteType_Level_TRANSACTION, @outStocks[i]);
        FQuoteBusiness.ReqLevelTransaction(@outStocks[i], 45, 0);
      end;

    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 主推请求
  SendLevelAutoPush_TRANSACTION;
end;

procedure TQuoteSubscribe.SubLevel_OrderQueue(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin
  // 订阅增量
  MergeIncCode(QuoteType_Level_ORDERQUEUE, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 发送请求
      for i := 0 to outCount - 1 do
      begin
        // 创建分笔对象
        CreateDataObject(QuoteType_Level_ORDERQUEUE, @outStocks[i]);
        FQuoteBusiness.ReqLevelOrderQueue(@outStocks[i], '1');
        FQuoteBusiness.ReqLevelOrderQueue(@outStocks[i], '2');
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
  // 重新订阅 主推请求
  SendLevelAutoPush_ORDERQUEUE;
end;

procedure TQuoteSubscribe.SubLevel_CancellationSort(QuoteType: QuoteTypeEnum; Content: TSubscribeContent;
  inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
// 单笔撤单主推排名 累计撤单主推排名
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin
  MergeIncCode(QuoteType, inStocks, inCount, outStocks, outCount);
  try
    // 发送订阅请求
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // 发送请求
      for i := 0 to outCount - 1 do
      begin
        // 创建分笔对象
        CreateDataObject(QuoteType, @outStocks[i]);
        if QuoteType = QuoteType_Level_SINGLEMA then
        begin
          FQuoteBusiness.ReqLevelCancel(@outStocks[i], '1');
          FQuoteBusiness.ReqAutoPushLevelCancel(@outStocks[i], '1');
        end
        else
        begin
          FQuoteBusiness.ReqLevelCancel(@outStocks[i], '2');
          FQuoteBusiness.ReqAutoPushLevelCancel(@outStocks[i], '2');
        end;
      end;

    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // 更新 订阅
  Content.Subscribe(inStocks, inCount);
end;

procedure TQuoteSubscribe.SubSingleColValue(QuoteType: QuoteTypeEnum; Content: TSubscribeContent; inStocks: PCodeInfos;
  inCount: integer; Value: OleVariant);
var
  Unknown: IUnknown;
  Inf: IQuoteColValue;
  FilterCount: integer;
  FilterStocks: PCodeInfos;
begin // 单列数据
  if (inCount = 0) or (inStocks = nil) or (Content = nil) then
    Exit;
  Unknown := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_SingleColValue, inttostr(Content.Cookie)];
  if Unknown = nil then
  begin
    Unknown := TQuoteSingleColValue.Create(FQuoteDataMngr);
    FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_SingleColValue, inttostr(Content.Cookie)] := Unknown;
  end;
  Inf := Unknown as IQuoteColValue;
  // if Inf.ColCode <> Value then
  // begin
  (Inf as IQuoteUpdate).Update(UPDATE_COLVULUE_CLEAR, 0, 0);
  (Inf as IQuoteUpdate).Update(UPDATE_COLVELUE_COL_CODE, Value, 0);
  // end;
  // 沪深 发送订阅请求
  FilterCode(STOCK_MARKET, OTHER_MARKET, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stStockLevelI, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;
  // 个股期权 发送订阅请求
  FilterCode(OPT_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stStockLevelI, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;

  // 期货 发送订阅请求
  FilterCode(FUTURES_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stFutues, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;
  // 港股
  FilterCode(HK_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stStockHK, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;

  // 美股
  FilterCode(US_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(US_MARKET, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;

  // 银行间证券
  FilterCode(FOREIGN_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stForeign, FilterStocks, FilterCount, Value, Content.Cookie);
    // FQuoteBusiness.ReqRealTime_Ext(stForeign, FilterStocks, FilterCount);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;
end;

procedure TQuoteSubscribe.SubMarketMonitor(Content: TSubscribeContent; Value: OleVariant);
begin
  CreateDataObject(QuoteType_MarketMonitor, nil);
  FQuoteBusiness.ReqAutoPushMarketEvent(stStockLevelI);
end;

procedure TQuoteSubscribe.SubDDEBigOrderRealTimeByOrder(Content: TSubscribeContent; inStocks: PCodeInfos;
  inCount: integer; Value: OleVariant);
var
  Unknown: IUnknown;
  Inf: IQuoteColValue;
  FilterCount, outCount, i: integer;
  outStocks, FilterStocks: PCodeInfos;
begin
  if Content = nil then
    Exit;
  // 订阅增量
  FilterCode(STOCK_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if FilterCount = 0 then
      Exit;

    MergeIncCode(QuoteType_DDEBigOrderRealTimeByOrder, FilterStocks, FilterCount, outStocks, outCount);
    try // 发送订阅请求
      if (outCount > 0) and (outStocks <> nil) then
      begin
        // 发送请求
        // for i := 0 to outCount - 1 do begin
        FQuoteBusiness.ReqHDA_TradeClassify_ByOrder(@outStocks[0], outCount, HDA_CLASSIFY_VIEW_ORDER);
        // end;

        // 更新 订阅
        Content.Subscribe(inStocks, inCount);
        // 重新订阅 主推请求
        // SendAutoPush_DDEBigOrderRealTimeByOrder;
      end;
    finally
      if outStocks <> nil then
        FreeMemEx(outStocks);
    end;
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;
end;

procedure TQuoteSubscribe.SendAutoPush_DDEBigOrderRealTimeByOrder;
var
  Count: integer;
  CodeInfos: PCodeInfos;
  CRC: integer;
begin
  // 2. 报价牌+分时线+分笔 调阅推送  生成定义的代码列表
  MergeCodeInfo(QuoteType_DDEBigOrderRealTimeByOrder, CodeInfos, Count);
  try
    // 发送订阅请求
    // if Count > 0  then begin
    // CRC := StocksCRC(CodeInfos, Count);
    // if CRC <> FDDE_BIGORDER_REALTIME_BYORDER_CRC then begin
    FQuoteBusiness.ReqAutoPushHDA_TradeClassify_ByOrder(CodeInfos, HDA_CLASSIFY_VIEW_ORDER, Count);
    // FDDE_BIGORDER_REALTIME_BYORDER_CRC := CRC;
    // end;
    // end;
  finally
    FreeMemEx(CodeInfos);
  end;
end;

end.
