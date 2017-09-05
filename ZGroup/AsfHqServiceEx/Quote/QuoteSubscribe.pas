unit QuoteSubscribe;

interface

uses Windows, Classes, SysUtils, QuoteService, QuoteLibrary, QuoteMngr_TLB,
  QuoteConst, QuoteStruct, IOCPMemory, IniFiles, QuoteBusiness, QuoteDataObject,
  QuoteDataMngr, QDOMarketMonitor, QDOSingleColValue;

type

  TQuoteSubscribe = class;

  // ��������
  TSubscribeContent = class
  private
    FSubscribe: TQuoteSubscribe;
    FCookie: integer;
    FStocks: array of TCodeInfo;
    // �����RealTime��鵽��key
    FCodeKeys: TIntegerList;
    // ���� key �� Stocks��ϵ
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

  // ���Ķ��� ���̶߳���
  TQuoteSubscribe = class
  private
    // ��д��
    FReadWriteSync: TMultiReadExclusiveWriteSynchronizer;
    FQuoteService: TQuoteService;
    FQuoteDataMngr: TQuoteDataMngr;
    FQuoteBusiness: TQuoteBusiness;
    FMessageList: TInterfaceList;
    FContents: TList;
    FContentsHash: TString64Hash;
    function QuoteTypeToPeriod(QuoteType: QuoteTypeEnum): integer;
    // ���Ͷ���
    procedure SendSubscribe(QuoteType: QuoteTypeEnum; inStocks: PCodeInfos; inCount: integer; Value: OleVariant;
      Content: TSubscribeContent);
    // ������������
    procedure SendAutoPush;
    procedure SendLevelAutoPush_REALTIME;
    procedure SendLevelAutoPush_TRANSACTION;
    procedure SendLevelAutoPush_ORDERQUEUE;

    // �ϲ���һ��,ȡ����Ʊ����
    procedure MergeStocks(QuoteType: QuoteTypeEnum; Stocks: TIntegerList; StocksHash: TIntegerHash);
    // �ϲ���Ʊ�б�
    procedure MergeCodeInfo(QuoteType: QuoteTypeEnum; var outStocks: PCodeInfos; var outCount: integer);
    // �ϲ���Ʊ, ��������
    procedure MergeIncCode(QuoteType: QuoteTypeEnum; inStocks: PCodeInfos; inCount: integer; var outStocks: PCodeInfos;
      var outCount: integer);

    procedure FilterCode(Market, Market1: integer; inStocks: PCodeInfos; inCount: integer; var outStocks: PCodeInfos;
      var outCount: integer);

    function CreateDataObject(QuoteType: QuoteTypeEnum; Stock: PCodeInfo): IUnknown;

  protected
    procedure SubRealTime(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    procedure SubServerCalc(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
    // procedure SubMultiTrend(Content: TSubscribeContent; inStocks: PCodeInfos;
    // inCount: integer; Value: OleVariant); // ���Ķ�����ʷ��ʱ
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

    // ע����Ϣ����
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage);
    // ȡ����Ϣ����
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage);
    // ��������
    function Subscribe(QuoteType: QuoteTypeEnum; Stocks: PCodeInfos; Count, Cookie: integer; Value: OleVariant): WordBool;
  end;

implementation

{ TSubscribeContent }

constructor TSubscribeContent.Create(Subscribe: TQuoteSubscribe; Cookie: integer; QuoteType: QuoteTypeEnum);
begin
  FSubscribe := Subscribe;
  FCookie := Cookie;
  FQuoteType := QuoteType;
  FKeysHash := TIntegerHash.Create; // ��256���ռ�
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
  // �����ռ�
  SetLength(FStocks, StockCount);

  // ��ֵ
  Move(StockList^, FStocks[0], StockCount * SizeOf(TCodeInfo));
  QuoteRealTime := FSubscribe.FQuoteDataMngr.QuoteRealTime;
  if QuoteRealTime <> nil then
  begin
    // ���� StocksHash ��SocksIndex
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
      begin // ��ʱ����
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
      begin // ���ɷֱ� ���� ���ɷֱ�
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
      begin // �������ڣ�1���� 5���� ��
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
    QuoteType_MarketMonitor: // ���߾���
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
    // �г���Ʊ����
    MergeStocks(QuoteType, Stocks, StocksHash);

    // ��䷵��ֵ
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
    // �г���Ʊ����
    MergeStocks(QuoteType, StocksList, StocksHash);

    // ��䷵��ֵ
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
          // ������
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
  // ��ʼ��
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
              // ���� CodeInfo
              Stocks.Add(codeinfo);
              // ������
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
  // ��ʼд
  FReadWriteSync.BeginWrite;
  try
    QuoteMessage.MsgCookie := FMessageList.Add(QuoteMessage);
  finally
    FReadWriteSync.EndWrite;
  end;
end;

procedure TQuoteSubscribe.DisconnectMessage(const QuoteMessage: IQuoteMessage);
begin
  // ��ʼ��
  FReadWriteSync.BeginWrite;
  try
    // TInterfaceList ���߳� ����
    if (QuoteMessage.MsgCookie >= 0) and (QuoteMessage.MsgCookie < FMessageList.Count) and
      (FMessageList[QuoteMessage.MsgCookie] as IQuoteMessage = QuoteMessage) then
    begin
      FMessageList[QuoteMessage.MsgCookie] := nil;
    end;
  finally
    FReadWriteSync.EndWrite;
  end;

  // ȥ�����ж��� ???????
  if FQuoteService.Active then
  begin
    Subscribe(QuoteType_REALTIME, nil, 0, QuoteMessage.MsgCookie, 0); // �������۱�
    Subscribe(QuoteType_REPORTSORT, nil, 0, QuoteMessage.MsgCookie, 0); // ����������
    Subscribe(QuoteType_GENERALSORT, nil, 0, QuoteMessage.MsgCookie, 0); // �ۺ�����
    Subscribe(QuoteType_TREND, nil, 0, QuoteMessage.MsgCookie, 0); // ��ʱ����
    Subscribe(QuoteType_STOCKTICK, nil, 0, QuoteMessage.MsgCookie, 0); // ���ɷֱ�
    Subscribe(QuoteType_LIMITTICK, nil, 0, QuoteMessage.MsgCookie, 0); // ���ɷֱ�
    Subscribe(QuoteType_TECHDATA_MINUTE1, nil, 0, QuoteMessage.MsgCookie, 0);
    // �̺����
    Subscribe(QuoteType_TECHDATA_MINUTE5, nil, 0, QuoteMessage.MsgCookie, 0);
    // �̺����
    Subscribe(QuoteType_TECHDATA_DAY, nil, 0, QuoteMessage.MsgCookie, 0);
    // �̺����
    Subscribe(QuoteType_TECHDATA_MINUTE15, nil, 0, QuoteMessage.MsgCookie, 0);
    // �̺����
    Subscribe(QuoteType_TECHDATA_MINUTE30, nil, 0, QuoteMessage.MsgCookie, 0);
    // �̺����
    Subscribe(QuoteType_TECHDATA_MINUTE60, nil, 0, QuoteMessage.MsgCookie, 0);
    // �̺����
    // Subscribe(QuoteType_TECHDATA_WEEK, nil, 0, QuoteMessage.MsgCookie, 0);
    // �̺����
    // Subscribe(QuoteType_TECHDATA_MONTH, nil, 0, QuoteMessage.MsgCookie, 0);
    // �̺����

    Subscribe(QuoteType_Level_REALTIME, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2ʮ������
    Subscribe(QuoteType_Level_TRANSACTION, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2��ʳɽ�
    Subscribe(QuoteType_Level_ORDERQUEUE, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2�̿�����
    Subscribe(QuoteType_Level_SINGLEMA, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2�̿�����
    Subscribe(QuoteType_Level_TOTALMAX, nil, 0, QuoteMessage.MsgCookie, 0);
    // Level2�̿�����

    // ȡ������������
    Subscribe(QuoteType_SingleColValue, nil, 0, QuoteMessage.MsgCookie, 0);
    // �г����鶩�� QuoteType_MarketMonitor
    Subscribe(QuoteType_Level_TOTALMAX, nil, 0, QuoteMessage.MsgCookie, 0);
  end;
end;

procedure TQuoteSubscribe.DoActiveMessage(MaskType, SendType: QuoteTypeEnum; Keys: TIntegerList; const KeyIndex: Int64);
var
  i, v: integer;
  Content: TSubscribeContent;
  QuoteMessage: IQuoteMessage;
begin
  // ��ʼ��
  FReadWriteSync.BeginRead;
  try
    for i := 0 to FContents.Count - 1 do
    begin
      Content := TSubscribeContent(FContents[i]);
      // �ж� Content ����
      // OutputDebugString(pchar(format('Content.Index:%d type %d',[i,Content.QuoteType])));
      if (Content.QuoteType and MaskType <> 0) then
      begin
        // keys=nil ����,ֻ��һ����Ʊ�����仯

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
        begin // ��ֻ��Ʊ
          // ѭ����֤ �Ƿ�Ҫ��֪ͨ
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
  // ��ʼ��
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
  // ��ʼ��
  FReadWriteSync.BeginWrite;
  try
    // OutputDebugString(PWideChar('DoResetMessage BeginWrite'));
    // ������ж�������
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
    // ������
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
  // 2. ������+��ʱ��+�ֱ� ��������  ���ɶ���Ĵ����б�
  MergeCodeInfo(QuoteType_REALTIME or QuoteType_TREND or QuoteType_STOCKTICK or QuoteType_HISTREND or QuoteType_LIMITTICK,
    CodeInfos, Count);
  try
    // ���� ���Ͷ�������
    FilterCode(STOCK_MARKET, OTHER_MARKET, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterStocks <> nil) then
        FQuoteBusiness.ReqAutoPush_Ext(stStockLevelI, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // ������Ȩ
    FilterCode(OPT_MARKET, 0, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterCount > 0) then
        FQuoteBusiness.ReqAutoPush_Ext(stStockLevelI, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // �ڻ� ���Ͷ�������
    FilterCode(FUTURES_MARKET, 0, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterCount > 0) then
        FQuoteBusiness.ReqAutoPush_Ext(stFutues, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // �۹� ���Ͷ�������
    FilterCode(HK_MARKET, 0, CodeInfos, Count, FilterStocks, FilterCount);
    try
      if (FilterCount > 0) then
        FQuoteBusiness.ReqAutoPush_Ext(stStockHK, FilterStocks, FilterCount);
    finally
      if FilterStocks <> nil then
        FreeMemEx(FilterStocks);
    end;

    // ���� ���Ͷ�������
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

    // ���м�ծȯ ���Ͷ�������
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
  // 2. ������+��ʱ��+�ֱ� ��������  ���ɶ���Ĵ����б�
  MergeCodeInfo(QuoteType_Level_ORDERQUEUE, CodeInfos, Count);
  try
    // ���Ͷ�������
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
  // 2. ������+��ʱ��+�ֱ� ��������  ���ɶ���Ĵ����б�
  MergeCodeInfo(QuoteType_Level_REALTIME, CodeInfos, Count);
  try
    // ���Ͷ�������
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
  // 2. ������+��ʱ��+�ֱ� ��������  ���ɶ���Ĵ����б�
  MergeCodeInfo(QuoteType_Level_TRANSACTION, CodeInfos, Count);
  try
    // ���Ͷ�������
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
    // ������
    QuoteType_REALTIME:
      SubRealTime(Content, inStocks, inCount, Value);
    QuoteType_TREND: // ��ʱ����
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
    // Level2ʮ�������ѯ
    QuoteType_Level_REALTIME:
      SubLevelRealTime(Content, inStocks, inCount, Value);

    // ��ʳɽ���ѯ
    QuoteType_Level_TRANSACTION:
      SubLevel_Transaction(Content, inStocks, inCount, Value);

    // �̿����ݲ�ѯ
    QuoteType_Level_ORDERQUEUE:
      SubLevel_OrderQueue(Content, inStocks, inCount, Value);

    // ���ʳ����������� �ۼƳ�����������
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
  // ��ʼ��
  FReadWriteSync.BeginWrite;
  try
    iContent := FContentsHash.ValueOf(FQuoteDataMngr.QuoteTypeToString(QuoteType) + inttostr(Cookie));
    // StocksΪ�� = ȡ������
    if Stocks = nil then
    begin
      if iContent <> -1 then
      begin
        Content := TSubscribeContent(iContent);
        // ɾ�� Hash
        FContentsHash.Remove(FQuoteDataMngr.QuoteTypeToString(QuoteType) + inttostr(Cookie));

        // ɾ�� Content
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
        // ���� ���� ����ӵ�Hash��
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
  // ��������
  MergeIncCode(QuoteType_REALTIME, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ���� ���Ͷ�������
      FilterCode(STOCK_MARKET, OTHER_MARKET, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stStockLevelI, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;
      // ������Ȩ ���Ͷ�������
      FilterCode(OPT_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stStockLevelI, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;

      // �ڻ� ���Ͷ�������
      FilterCode(FUTURES_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stFutues, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;
      // �۹�
      FilterCode(HK_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stStockHK, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;

      //����
      FilterCode(US_MARKET, 0, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqRealTime_Ext(stUSStock, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;

      // ���м�֤ȯ
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
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� ��������
  SendAutoPush;
end;

procedure TQuoteSubscribe.SubServerCalc(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outCount, FilterCount: integer;
  outStocks, FilterStocks: PCodeInfos;
begin
  // ��������
  MergeIncCode(QuoteType_LimitPrice, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ���� ���Ͷ�������
      FilterCode(STOCK_MARKET, OTHER_MARKET, outStocks, outCount, FilterStocks, FilterCount);
      try
        if (FilterCount > 0) and (FilterStocks <> nil) then
          FQuoteBusiness.ReqSeverCalculate(stStockLevelI, FilterStocks, FilterCount);
      finally
        if FilterStocks <> nil then
          FreeMemEx(FilterStocks);
      end;
      // // ������Ȩ ���Ͷ�������
      // FilterCode(OPT_MARKET,0, outStocks, outCount,FilterStocks, FilterCount);
      // try
      // if (FilterCount > 0) and (FilterStocks <> nil) then
      // FQuoteBusiness.ReqRealTime_Ext(stStockLevelI, FilterStocks,FilterCount);
      // finally
      // if FilterStocks <> nil then
      // FreeMemEx(FilterStocks);
      // end;

      // �ڻ� ���Ͷ�������
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
  // ���� ����
  Content.Subscribe(inStocks, inCount);
end;

procedure TQuoteSubscribe.SubTrend(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i, j: integer;
  MiltiTrend: IQuoteMultiTrend;
begin
  // ��������
  MergeIncCode(QuoteType_TREND, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ��������
      for i := 0 to outCount - 1 do
      begin
        // ������ʱ����
        MiltiTrend := CreateDataObject(QuoteType_TREND, @outStocks[i]) as IQuoteMultiTrend;
        // if MiltiTrend.Datas[0].Count = 0 then
        // begin
        // ���м�֤ȯ
        if HSMarketType(outStocks[i].m_cCodeType, FOREIGN_MARKET) then
        begin
          FQuoteBusiness.ReqIBTREND(ToServerType(outStocks[i].m_cCodeType), @outStocks[i])
        end
        else if IsStockMajorIndex(@outStocks[i]) then // ��ָ֤�� �� ��֤��ָ
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
            if HSMarketType(outStocks[i].m_cCodeType, FUTURES_MARKET) then // �ڻ�
              FQuoteBusiness.ReqTrend(ToServerType(outStocks[i].m_cCodeType), @outStocks[i])
            else
              FQuoteBusiness.ReqhisTrend(ToServerType(outStocks[i].m_cCodeType), @outStocks[i], 0, 99999); // ��������
          end;
          // �����г� ���󼯺Ͼ�������
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
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� ��������
  SendAutoPush;
end;

Procedure TQuoteSubscribe.SubHisTrend(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
  QuoteTrend: IQuoteTrendHis;
begin
  // ��������
  MergeIncCode(QuoteType_HISTREND, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ��������
      for i := 0 to outCount - 1 do
      begin
        // ������ʱ����
        QuoteTrend := CreateDataObject(QuoteType_HISTREND, @outStocks[i]) as IQuoteTrendHis;
        QuoteTrend.ResetDate(Value);
        FQuoteBusiness.ReqhisTrend(ToServerType(outStocks[i].m_cCodeType), @outStocks[i], Value, Value);
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� ��������
  // SendAutoPush;
end;

Procedure TQuoteSubscribe.SubStockTick(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin // ���ɷֱ�
  // ��������
  MergeIncCode(QuoteType_STOCKTICK, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ��������
      for i := 0 to outCount - 1 do
      begin
        // �����ֱʶ���
        CreateDataObject(QuoteType_STOCKTICK, @outStocks[i]);
        FQuoteBusiness.ReqStockTick(ToServerType(outStocks[i].m_cCodeType), @outStocks[i]);
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� ��������
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
  // ���Ͷ�������
  if (inCount > 0) and (inStocks <> nil) then
  begin
    // ��������
    for i := 0 to inCount - 1 do
    begin
      // ������ʱ����

      TechData := CreateDataObject(QuoteType, @inStocks[i]) as IQuoteUpdate;

      // ע��: ������СK��, �������ͬ�л�����ݷ�������
      // ������������ ��־�Ƿ�æµ, �ϲ����ֵ����K��
      if TechData <> nil then
      begin
        TechData.BeginWrite;
        try
          TechData.DataState(State_Tech_IsBusy, iValue, sValue, oValue);
          if iValue <> 1 then // ��æµ ��������
            FQuoteBusiness.ReqTechData(ToServerType(inStocks[i].m_cCodeType), @inStocks[i], TechData,
              QuoteTypeToPeriod(QuoteType), Value)
            // �ϲ��������(���ֵ)����K��
          else
            TechData.Update(Update_Tech_WaitCount, 0, Value);
        finally
          TechData.EndWrite;
        end;
      end;
    end;
  end;
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� ��������
  SendAutoPush;
end;

Procedure TQuoteSubscribe.SubLimitTick(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin
  // ��������
  MergeIncCode(QuoteType_LIMITTICK, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ��������
      for i := 0 to outCount - 1 do
      begin
        // �����ֱʶ���
        CreateDataObject(QuoteType_LIMITTICK, @outStocks[i]);
        FQuoteBusiness.ReqLimitTick(ToServerType(outStocks[i].m_cCodeType), @outStocks[i], Value);
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� ��������
  SendAutoPush;
end;

procedure TQuoteSubscribe.SubGeneralSort(Content: TSubscribeContent; inStocks: PCodeInfos);
var
  Unknown: IUnknown;
  ReqGeneralSort: PReqGeneralSortEx;
begin // �ۺ�����
  // ֻ��һ����ʱ������ʱ����
  // ���� �������۱� ����
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
begin // �������۱�
  // ֻ��һ����ʱ������ʱ����
  // ���� �������۱� ����
  Unknown := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_REPORTSORT, inttostr(Content.Cookie)];
  if Unknown = nil then
  begin
    Unknown := TQuoteReportSort.Create(FQuoteDataMngr, inStocks, inCount, PReqReportSort(Int64(Value)));
    FQuoteDataMngr.QuoteDataObjsByKey[QuoteType_REPORTSORT, inttostr(Content.Cookie)] := Unknown;
  end
  else
    (Unknown as IQuoteUpdate).Update(QuoteType_REPORTSORT, Int64(inStocks), 0);
  // ���Ͷ�������
  FQuoteBusiness.ReqPeportSort(ToServerType(inStocks[0].m_cCodeType), inStocks, inCount, Content.Cookie,
    PReqReportSort(Int64(Value)));

end;

procedure TQuoteSubscribe.SubLevelRealTime(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount: integer;
begin
  // ��������
  MergeIncCode(QuoteType_Level_REALTIME, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
      FQuoteBusiness.ReqLevelRealTime(outStocks, outCount);
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� Level2ʮ�����鶩��
  SendLevelAutoPush_REALTIME;
end;

procedure TQuoteSubscribe.SubLevel_Transaction(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin
  // ��������
  MergeIncCode(QuoteType_Level_TRANSACTION, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ��������
      for i := 0 to outCount - 1 do
      begin
        // �����ֱʶ���
        CreateDataObject(QuoteType_Level_TRANSACTION, @outStocks[i]);
        FQuoteBusiness.ReqLevelTransaction(@outStocks[i], 45, 0);
      end;

    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� ��������
  SendLevelAutoPush_TRANSACTION;
end;

procedure TQuoteSubscribe.SubLevel_OrderQueue(Content: TSubscribeContent; inStocks: PCodeInfos; inCount: integer;
  Value: OleVariant);
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin
  // ��������
  MergeIncCode(QuoteType_Level_ORDERQUEUE, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ��������
      for i := 0 to outCount - 1 do
      begin
        // �����ֱʶ���
        CreateDataObject(QuoteType_Level_ORDERQUEUE, @outStocks[i]);
        FQuoteBusiness.ReqLevelOrderQueue(@outStocks[i], '1');
        FQuoteBusiness.ReqLevelOrderQueue(@outStocks[i], '2');
      end;
    end;
  finally
    if outStocks <> nil then
      FreeMemEx(outStocks);
  end;
  // ���� ����
  Content.Subscribe(inStocks, inCount);
  // ���¶��� ��������
  SendLevelAutoPush_ORDERQUEUE;
end;

procedure TQuoteSubscribe.SubLevel_CancellationSort(QuoteType: QuoteTypeEnum; Content: TSubscribeContent;
  inStocks: PCodeInfos; inCount: integer; Value: OleVariant);
// ���ʳ����������� �ۼƳ�����������
var
  outStocks: PCodeInfos;
  outCount, i: integer;
begin
  MergeIncCode(QuoteType, inStocks, inCount, outStocks, outCount);
  try
    // ���Ͷ�������
    if (outCount > 0) and (outStocks <> nil) then
    begin
      // ��������
      for i := 0 to outCount - 1 do
      begin
        // �����ֱʶ���
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
  // ���� ����
  Content.Subscribe(inStocks, inCount);
end;

procedure TQuoteSubscribe.SubSingleColValue(QuoteType: QuoteTypeEnum; Content: TSubscribeContent; inStocks: PCodeInfos;
  inCount: integer; Value: OleVariant);
var
  Unknown: IUnknown;
  Inf: IQuoteColValue;
  FilterCount: integer;
  FilterStocks: PCodeInfos;
begin // ��������
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
  // ���� ���Ͷ�������
  FilterCode(STOCK_MARKET, OTHER_MARKET, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stStockLevelI, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;
  // ������Ȩ ���Ͷ�������
  FilterCode(OPT_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stStockLevelI, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;

  // �ڻ� ���Ͷ�������
  FilterCode(FUTURES_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stFutues, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;
  // �۹�
  FilterCode(HK_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(stStockHK, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;

  // ����
  FilterCode(US_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if (FilterCount > 0) and (FilterStocks <> nil) then
      FQuoteBusiness.ReqSingleHQColValue(US_MARKET, FilterStocks, FilterCount, Value, Content.Cookie);
  finally
    if FilterStocks <> nil then
      FreeMemEx(FilterStocks);
  end;

  // ���м�֤ȯ
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
  // ��������
  FilterCode(STOCK_MARKET, 0, inStocks, inCount, FilterStocks, FilterCount);
  try
    if FilterCount = 0 then
      Exit;

    MergeIncCode(QuoteType_DDEBigOrderRealTimeByOrder, FilterStocks, FilterCount, outStocks, outCount);
    try // ���Ͷ�������
      if (outCount > 0) and (outStocks <> nil) then
      begin
        // ��������
        // for i := 0 to outCount - 1 do begin
        FQuoteBusiness.ReqHDA_TradeClassify_ByOrder(@outStocks[0], outCount, HDA_CLASSIFY_VIEW_ORDER);
        // end;

        // ���� ����
        Content.Subscribe(inStocks, inCount);
        // ���¶��� ��������
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
  // 2. ������+��ʱ��+�ֱ� ��������  ���ɶ���Ĵ����б�
  MergeCodeInfo(QuoteType_DDEBigOrderRealTimeByOrder, CodeInfos, Count);
  try
    // ���Ͷ�������
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
