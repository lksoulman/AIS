unit ManagerEx;

interface

uses
  Winapi.Windows, System.SysUtils, Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom,
  Xml.XMLDoc, System.IniFiles, Generics.Collections, System.Math, System.Classes,
  System.StrUtils, System.Types, Winapi.ActiveX, System.Win.ComObj,
  Manager, QuoteMngr_Tlb, QuoteManagerEvents, AppControllerInf, QuoteConst,
  QuoteManagerExInf, WNDataSetInf, QuoteStruct;

type
  ServerStatusEnum = (ssInit, ssDisconnect, ssConnecting, ssConnected);
  PServerInfo = ^TServerInfo;

  TServerInfo = packed record
    Name: string;
    ServerType: ServerTypeEnum;
    Server: string;
  end;

  PServerTypeEnum = ^ServerTypeEnum;
  TQuoteManagerEx = class;

  TQuoteCodeInfos = class(TInterfacedObject, IQuoteCodeInfosEx)
  protected
    FPCodeInfArray: TArray<PCodeInfo>;
    FInnerCodeArray: TArray<Integer>;
    FCount: Integer;
    FCapacity: Integer;
    { IQuoteCodeInfosEx }
    function Count: Integer; safecall;
    function GetCodeInfo(Index: Integer): Int64; safecall;
    function GetInnerCode(Index: Integer): Integer; safecall;
  public
    Destructor Destroy; override;

    procedure Clear;
    procedure SetCapacity(Count: Integer);
    procedure Add(p: PCodeInfo; InnerCode: Integer);

  End;

  TDaemonThread = class(Tthread)
  type
    ServerTimeInfo = packed record
      ServerType: ServerTypeEnum;
      ServerStatus: ServerStatusEnum;
      ATime: TDateTime;
    end;
  private
    FManagerEx: TQuoteManagerEx;
    FConnectList: TThreadList<ServerTimeInfo>;
    // FServerTypeList: TList<ServerTimeInfo>;
  protected
    procedure Execute(); override;
  public
    // procedure DisConnect(AServerType: ServerTypeEnum);
    procedure AddServerType(AServerType: ServerTypeEnum);
    procedure UpdateServerStatus(AServerType: ServerTypeEnum; AStatus: ServerStatusEnum);
    procedure UpdateConnectingToDisconnect;
    Constructor Create();
    destructor Destroy(); override;
    property ManagerEx: TQuoteManagerEx read FManagerEx write FManagerEx;
  end;

  TQuoteManagerEx = class(TInterfacedObject, IQuoteManagerEx, IExtensibility)
  protected
    FQuoteManager: IQuoteManager;
    FQuoteRealTime: IQuoteRealTime;
    FQuoteEvent: TQuoteManagerEvents;
    FController: IGilAppController;
    // FSuffixMap: THashedStringList;
    FCodeInfoHash: TDictionary<string, Integer>;
    FkeyStrHash: TDictionary<Integer, string>;
    FNameToInnerCodeHash: TDictionary<string, Integer>;
    FInnerCodeToNameHash: TDictionary<Integer, string>;
    FMaket20CodeAgent: TDictionary<Integer, string>;

    FServerInfoList: TList<PServerInfo>;
    FSQL { , FInnerCodeSQL } : string;
    FIsLevel2Right: Boolean;
    FLevel2User: string;
    FLevel2Pass: string;
    FIsHKReal: Boolean;
    FHKDelayServer: string;
    FTypeLib: ITypeLib;
    FDaemonThread: TDaemonThread;
    FCritical: TRTLCriticalSection;
    FNeedInitCodeInfo: Boolean;

    procedure Lock();
    procedure UnLock();
    procedure LoadConfig();
    procedure InitHSCodeAgentByINI();
    procedure InitCodeInfo();
    procedure InitNameToCodeInfo(ANBBM, AZQSC, AZQLB: Integer; AName: string); virtual;
    procedure SetQuoteServer();
    procedure ConnectQuoteServer();
    procedure DisconnectQuoteServer();
    procedure CodeInfoDoNotify(Sender: TObject; const Item: PCodeInfo; Action: System.Generics.Collections.TCollectionNotification);
    procedure ServerInfoDoNotify(Sender: TObject; const Item: PServerInfo; Action: System.Generics.Collections.TCollectionNotification);
    procedure DoNotify(Sender: TObject; const Item: Pointer; Action: System.Generics.Collections.TCollectionNotification);
    procedure ConnectServer(AServerType: ServerTypeEnum);
    // procedure GetCodeInfos(NBBMs: string;
    // hash: TDictionary<Integer, PCodeInfo>);
    { QuoteMessageEvent }
    procedure DoConnected(const IP: WideString; Port: Word; ServerType: ServerTypeEnum);
    procedure DoDisconnected(const IP: WideString; Port: Word; ServerType: ServerTypeEnum);
    procedure DoWriteLog(const Log: WideString);
    procedure DoProgress(const Msg: WideString; Max, Value: Integer);
    //通过概念指数名称建立内码和订阅的代码的对应关系
    procedure DoUpdateConceptCodes(Sender: TObject);
    { IExtensibility }
    procedure OnConnection(const GilAppController: IGilAppController; NotifySvr: INotifyServices; AHandle: THandle);
      virtual; safecall;
    procedure OnDisconnection; virtual; safecall;
    procedure OnChangeLanguage; virtual; safecall;

    { IQuoteManagerProxy }
    function Get_Active: WordBool; safecall;
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    function Subscribe(QuoteType: QuoteTypeEnum; pCodeInfos: Int64; Count: Integer; Cookie: Integer; Value: OleVariant)
      : WordBool; safecall;
    function QueryData(QuoteType: QuoteTypeEnum; PCodeInfo: Int64): IUnknown; safecall;
    procedure ConnectServerInfo(ServerType: ServerTypeEnum; var IP: WideString; var Port: Word); safecall;
    function Get_Connected(ServerType: ServerTypeEnum): WordBool; safecall;
    Function Get_QuoteTypeCount(): Integer; safecall;
    procedure Get_AllQuoteType(QuoteTypes: Int64; Count: Integer); safecall;
    Function Get_QuoteTypeName(ServerType: ServerTypeEnum): WideString; safecall;
    Function IsLevel2(InnerCode: Integer): Boolean; safecall;
    Function IsHKReal(): Boolean; safecall;
    Function GetTypeLib(): ITypeLib; safecall;
    Function GetCodeInfoByInnerCodes(InnerCodes: Int64; Count: Integer): IQuoteCodeInfosEx; SafeCall;
    Function GetCodeInfoByInnerCode(InnerCode: Int64; CodeInfo: Int64): Boolean; safecall;
    // Function GetCodeInfoBySecuCode(SecuCode: WideString; CodeInfo: Int64)
    // : Boolean; safecall;
    procedure CodeInfo2InnerCode(CodeInfos: Int64; Count: Integer; InnerCodes: Int64); safecall;
    procedure SetNeedInitCodeInfo(ANeedInit: Boolean); safecall;
    procedure UpdateConnectingToDisconnect; safecall;

    procedure OutLog(ALogLevel: LogLevel; ALog: WideString);
  public
    Destructor Destroy; override;

    property NeedInitCodeInfo: Boolean read FNeedInitCodeInfo write FNeedInitCodeInfo;
  end;

function getQuoteManagerEx(Name: WideString): IInterface; stdcall;
function ProxyTypeToProxyKindEnum(proxy: ProxyType): ProxyKindEnum;

implementation

function ProxyTypeToProxyKindEnum(proxy: ProxyType): ProxyKindEnum;
begin
  case proxy of
    ptHTTPProxy:
      Result := ProxyKind_HTTPProxy;
    ptSocks4:
      Result := ProxyKind_SOCKS4Proxy;
    ptSocks5:
      Result := ProxyKind_SOCKS5Proxy;
    ptNoProxy:
      Result := ProxyKind_NoProxy;
  else
    raise Exception.Create('未知的代理类型。');

  end;
end;

function getQuoteManagerEx(Name: WideString): IInterface;
begin
  Result := nil;
  if CompareStr(Name, 'QuoteMngr.QuoteManagerEx') = 0 then
    Result := TQuoteManagerEx.Create;
end;

{ TQuoteCodeInfos }
function TQuoteCodeInfos.Count: Integer;
begin
  Result := FCount;
end;

function TQuoteCodeInfos.GetCodeInfo(Index: Integer): Int64;
begin
  Result := Int64(FPCodeInfArray[Index]);
end;

function TQuoteCodeInfos.GetInnerCode(Index: Integer): Integer;
begin
  Result := FInnerCodeArray[Index];
end;

procedure TQuoteCodeInfos.Clear;
begin
  FCount := 0;
  FCapacity := 0;
  SetCapacity(0);
end;

procedure TQuoteCodeInfos.SetCapacity(Count: Integer);
begin
  FCapacity := Count;
  SetLength(FPCodeInfArray, Count);
  SetLength(FInnerCodeArray, Count);
end;

procedure TQuoteCodeInfos.Add(p: PCodeInfo; InnerCode: Integer);
begin
  FInnerCodeArray[FCount] := InnerCode;
  FPCodeInfArray[FCount] := p;
  inc(FCount);
end;

Destructor TQuoteCodeInfos.Destroy;
begin
  Clear;
  inherited;
end;

{ TDaemonThread }
Const
  ActiveInterval = 1.0 / 24 / 120;

procedure TDaemonThread.Execute();
var
  i: Integer;
  list: TList<ServerTimeInfo>;
  d: ServerTimeInfo;
begin
  while not Terminated do
  begin
    if FManagerEx.NeedInitCodeInfo then
    begin
      FManagerEx.NeedInitCodeInfo := False;
      if Terminated then
        Exit;
      FManagerEx.InitCodeInfo;
    end;
    for i := 0 to 100 do
    begin
      sleep(20);
      if Terminated then
        Exit;
    end;
    if Terminated then
      Break;

    list := FConnectList.LockList;
    try
      for i := 0 to list.Count - 1 do
      begin
        if Terminated then
          Exit;

        if (list[i].ServerStatus = ssDisconnect) or // 已断开
          ((list[i].ServerStatus = ssConnecting) and (Now - list[i].ATime > 1 / 24 / 30)) // 连接2分钟还未连接数 重连
        then
        begin
          d := list[i];
          d.ServerStatus := ssConnecting;
          d.ATime := Now;
          list[i] := d;
          FManagerEx.FQuoteManager.Connect(list[i].ServerType);
        end
        else if list[i].ServerStatus = ssConnected then
        begin
          if abs(Now - list[i].ATime) > ActiveInterval then // 一分半钟执行一次
          begin
            if FManagerEx.Get_Connected(list[i].ServerType) then
            begin
              FManagerEx.FQuoteManager.SendKeepActiveTime(list[i].ServerType);
            end;
            d := list[i];
            d.ATime := Now;
            list[i] := d;
          end;
        end;
      end;
    finally
      FConnectList.UnlockList;
    end;
  end;

  if Terminated then
    FManagerEx.OutLog(llWarn, '[TDaemonThread] 守护线程已终止');
end;

{ procedure TDaemonThread.DisConnect(AServerType: ServerTypeEnum);
  var
  d: ServerTimeInfo;
  i: Integer;
  list: TList<ServerTimeInfo>;
  begin
  list := FConnectList.LockList;
  try
  for i := 0 to list.Count - 1 do
  begin
  if list[i].ServerType = AServerType then
  Exit;
  end;
  d.ServerType := AServerType;
  d.ATime := now;
  list.Add(d);
  finally
  FConnectList.UnlockList;
  end;
  end; }

procedure TDaemonThread.AddServerType(AServerType: ServerTypeEnum);
var
  d: ServerTimeInfo;
begin
  d.ServerType := AServerType;
  d.ATime := Now;
  d.ServerStatus := ssInit;
  FConnectList.Add(d);
end;

procedure TDaemonThread.UpdateConnectingToDisconnect;
var
  LSTInfo: ServerTimeInfo;
  i: Integer;
  LList: TList<ServerTimeInfo>;
begin
  LList := FConnectList.LockList;
  try
    for i := 0 to LList.Count - 1 do
    begin
      if LList[i].ServerStatus = ssConnecting then
      begin
        LSTInfo := LList[i];
        LSTInfo.ServerStatus := ssDisconnect;
        LSTInfo.ATime := Now;
        LList[i] := LSTInfo;
      end;
    end;
  finally
    FConnectList.UnlockList;
  end;
end;

procedure TDaemonThread.UpdateServerStatus(AServerType: ServerTypeEnum; AStatus: ServerStatusEnum);
var
  d: ServerTimeInfo;
  i: Integer;
  list: TList<ServerTimeInfo>;
begin
  list := FConnectList.LockList;
  try
    for i := 0 to list.Count - 1 do
    begin
      if list[i].ServerType = AServerType then
      begin
        d := list[i];
        d.ServerStatus := AStatus;
        d.ATime := Now;
        list[i] := d;
        Break;
      end;
    end;
  finally
    FConnectList.UnlockList;
  end;
end;

Constructor TDaemonThread.Create();
begin
  FConnectList := TThreadList<ServerTimeInfo>.Create;
  // FServerTypeList := TList<ServerTimeInfo>.Create;
  // self.FreeOnTerminate := True;
  inherited Create(True);
end;

destructor TDaemonThread.Destroy();
begin
  FManagerEx := nil;
  freeandnil(FConnectList);
  // freeandnil(FServerTypeList);
  inherited;
end;

{ TQuoteManagerProxy }

procedure TQuoteManagerEx.Lock();
begin
  EnterCriticalSection(FCritical);
end;

procedure TQuoteManagerEx.UnLock();
begin
  LeaveCriticalSection(FCritical);
end;

procedure TQuoteManagerEx.UpdateConnectingToDisconnect;
begin
  FDaemonThread.UpdateConnectingToDisconnect;
end;

procedure TQuoteManagerEx.LoadConfig();
var
  Xml: IXMLDocument;
  xmlNode, XmlNodeChild: IXMLNode;
  i: Integer;
  p: PServerInfo;
  AHKIndex: Integer;
begin
  Xml := TXMLDocument.Create(nil);
  try
    Xml.Active := True;
    Xml.LoadFromFile(FController.GetConfigPath + 'QuoteConfig.xml');
    xmlNode := Xml.ChildNodes[1];
    XmlNodeChild := xmlNode.ChildNodes.FindNode('Servers');
    // FIsLevel2Right := XmlNodeChild.GetAttributeNS('IsLevel2', '');
    // FLevel2User := XmlNodeChild.GetAttributeNS('Level2User', '');
    // FLevel2Pass := XmlNodeChild.GetAttributeNS('Level2Pass', '');
    // FIsHKReal := Boolean(XmlNodeChild.GetAttributeNS('IsHKReal', ''));
    AHKIndex := -1;
    for i := 0 to XmlNodeChild.ChildNodes.Count - 1 do
    begin
      if XmlNodeChild.ChildNodes.Get(i).NodeType = ntComment then
        Continue;
      // 港股延时行情服务器
      if XmlNodeChild.ChildNodes[i].Attributes['type'] = 6 then
      begin
        FHKDelayServer := FController.GetWebIP(String(XmlNodeChild.ChildNodes[i].Attributes['ipKey']));
        if not(FIsHKReal)then
        begin
          if (AHKIndex >= 0) and (AHKIndex < FServerInfoList.Count) then
          begin
            FServerInfoList[AHKIndex].Name := XmlNodeChild.ChildNodes[i].Attributes['name'];
          end;
        end;
        Continue;
      end
      else if XmlNodeChild.ChildNodes[i].Attributes['type'] = 4 then
      begin
        AHKIndex := FServerInfoList.Count;
      end;
      New(p);
      p.Name := XmlNodeChild.ChildNodes[i].Attributes['name'];
      p.ServerType := XmlNodeChild.ChildNodes[i].Attributes['type'];
      p.Server := FController.GetWebIP(String(XmlNodeChild.ChildNodes[i].Attributes['ipKey']));
      FServerInfoList.Add(p);
    end;
    // XmlNodeChild := xmlNode.ChildNodes.FindNode('CodeInfo');
    FSQL := 'select A.NBBM,A.GPDM,A.Suffix,A.ZQJC,ifnull( A.ZQSC,0) as ZQSC,A.oZQLB,A.GSDM,B.CodeByAgent AS HSCode from'#13#10 +
      'ZQZB A LEFT JOIN HSCODE B ON A.NBBM=B.InnerCode'#13#10 +
      'WHERE  (A.ZQSC IN (83,90,81,10,13,15,19,20,72,89,76,77,78,79)  and A.SSZT in (1, 3))'#13#10 +
      'OR (A.ZQSC = 84 and A.oZQLB = 4 and A.SSZT = 1)'#13#10 +
      'OR (A.oZQLB in (930,920) and ifnull(A.SSZT,0) in (1,0))'#13#10 + 'OR ( A.oZQLB = 1 and A.SSZT = 9)';
    // FSQL := 'select A.NBBM,A.GPDM,ifnull( A.ZQSC,0) as ZQSC,A.oZQLB,A.GSDM,B.CodeByAgent AS HSCode from '#13#10
    // +'ZQZB A LEFT JOIN HSCODE B ON A.NBBM=B.InnerCode and (A.ZQSC IN (83,90,81,10,13,15,19,20,72,89) or '+
    // '(A.oZQLB in (910,920)) or ' + ' (A.ZQSC = 84 and A.oZQLB = 4)) and A.SSZT = 1';

    // <!--getByInnerCode>select A.NBBM as NBBM,A.GPDM as GPDM,A.ZQSC as ZQSC,A.oZQLB as oZQLB,A.GSDM as GSDM,B.CodeByAgent AS
    // HSCode from ZQZB A  left join HSCODE B ON A.NBBM=B.InnerCode where A.NBBM IN (!InnerCodes)
    // 三板,上证,深证,上海期货,大连期货,郑州期货,中金,香港联交所,银行间市场,其他市场
    // FInnerCodeSQL := XmlNodeChild.ChildValues['getByInnerCode'];
    // XmlNodeChild := xmlNode.ChildNodes.FindNode('sufixMap');
    // for i := 0 to XmlNodeChild.ChildNodes.Count - 1 do
    // begin
    // FSuffixMap.Add(XmlNodeChild.ChildNodes[i].NodeValue);
    // end;
  finally
    xmlNode := nil;
    XmlNodeChild := nil;
    Xml.Active := False;
    Xml := nil;
  end;
  // XmlNodeChild.
end;

procedure TQuoteManagerEx.InitHSCodeAgentByINI();
var
  ini: TiniFile;
  Alist: TstringList;
  i, NBBM: Integer;
begin
  ini := TiniFile.Create(FController.GetConfigPath + '\CodeAgent\CodeAgent.ini');
  Alist := TstringList.Create;
  try
    // 读取市场为20的证券交易代码代理
    ini.ReadSection('20', Alist);
    for i := 0 to Alist.Count - 1 do
    begin
      NBBM := strtointdef(Alist[i], 0);
      if NBBM > 0 then
      begin
        FMaket20CodeAgent.AddOrSetValue(NBBM, ini.ReadString('20', Alist[i], ''));
      end;
    end;
  finally
    Alist.Free;
    ini.Free;
  end;
end;

procedure TQuoteManagerEx.InitCodeInfo();
var
  DataSet: IWNDataSet;
  Code, Key, Suffix: string;
begin
  DataSet := FController.CacheQueryData('', FSQL);
  if DataSet <> nil then
  begin
    self.Lock;
    try
      DataSet.First;
      FkeyStrHash.Clear;
      FCodeInfoHash.Clear;
      FNameToInnerCodeHash.Clear;
      FInnerCodeToNameHash.Clear;

      while not DataSet.Eof do
      begin
        Suffix := DataSet.FieldByName('Suffix').AsString;
        // B.GPDM,A.ZQSC,A.oZQLB,A.oNBBM,A.HSCode
        if (Suffix = 'CSI') then // 中证指数
          Code := ''
        else if DataSet.FieldByName('oZQLB').AsInteger = 110 then // 个股期权
          Code := DataSet.FieldByName('GSDM').AsString
        else
        begin
          if DataSet.FieldByName('ZQSC').AsString = '20' then // 中金所
          begin
            if not FMaket20CodeAgent.TryGetValue(DataSet.FieldByName('NBBM').AsInteger, Code) then
              Code := '';
          end
          else if (DataSet.FieldByName('ZQSC').AsString = '83') then // 根据恒生提供的转换规则，对沪深指数中以‘000’开头的指数代码做转化
          begin
            if (Pos('000', string(DataSet.FieldByName('GPDM').AsString)) = 1) and
              (DataSet.FieldByName('oZQLB').AsInteger = 4) then
            begin
              if (DataSet.FieldByName('GPDM').AsString = '000001') then
                Code := '1A0001'
              else if (DataSet.FieldByName('GPDM').AsString = '000002') then
                Code := '1A0002'
              else if (DataSet.FieldByName('GPDM').AsString = '000003') then
                Code := '1A0003'
              else
                Code := ReplaceStr(DataSet.FieldByName('GPDM').AsString, '000', '1B0');
            end
            else
              Code := DataSet.FieldByName('HSCode').AsString;
          end
          else
          begin
            Code := DataSet.FieldByName('HSCode').AsString;
          end;
        end;

        if trim(Code) = '' then
          Code := DataSet.FieldByName('GPDM').AsString;
        Key := GetKeyByZQLB(DataSet.FieldByName('ZQSC').AsInteger, DataSet.FieldByName('oZQLB').AsInteger, Code, Suffix);
        if(not FkeyStrHash.ContainsKey(DataSet.FieldByName('NBBM').AsInteger))then
        begin
          FkeyStrHash.AddOrSetValue(DataSet.FieldByName('NBBM').AsInteger, Key);
          // outputDEbugString(pchar(Key));
          FCodeInfoHash.AddOrSetValue(Key, DataSet.FieldByName('NBBM').AsInteger);
          InitNameToCodeInfo(DataSet.FieldByName('NBBM').AsInteger, DataSet.FieldByName('ZQSC').AsInteger,
            DataSet.FieldByName('oZQLB').AsInteger, DataSet.FieldByName('ZQJC').AsString);
        end;
        DataSet.Next;
      end;
    finally
      self.UnLock;
    end;
    DoUpdateConceptCodes(nil);
    DataSet := nil;
  end
  else
  begin
    OutLog(llFatal, Format('[QuoteMng]取证券CodeInfo失败:%s', [FSQL]));
  end;
  // OutputDebugString(pchar(Format('InitCodeInfo:%d ms', [GetTickCount - tick])));
end;

procedure TQuoteManagerEx.InitNameToCodeInfo(ANBBM, AZQSC, AZQLB: Integer; AName: string);
var
  AAnsiName: AnsiString;
begin
  case AZQSC of
    0, 84:
      begin
        case AZQLB of
          930:
            begin
              AAnsiName := AnsiString(AName);
              AAnsiName := StringReplace(AAnsiName, '(', '（', [rfReplaceAll]);
              AAnsiName := StringReplace(AAnsiName, ')', '）', [rfReplaceAll]);
              AAnsiName := LeftStr(AAnsiName, 16);
              FInnerCodeToNameHash.AddOrSetValue(ANBBM, AAnsiName);
              FNameToInnerCodeHash.AddOrSetValue(AAnsiName, ANBBM);
            end;
        end;
      end;
  end;
end;

procedure TQuoteManagerEx.SetNeedInitCodeInfo(ANeedInit: Boolean);
begin
  FNeedInitCodeInfo := ANeedInit;
end;

procedure TQuoteManagerEx.SetQuoteServer();
var
  i, j, Port, Index: Integer;
  Strings: TstringList;
  IP: string;
begin
  if FIsLevel2Right then
    FQuoteManager.LevelSetting(FLevel2User, FLevel2Pass);

  Strings := TstringList.Create;
  try
    for i := 0 to FServerInfoList.Count - 1 do
    begin
      Strings.Clear;
      Strings.Delimiter := ';';
      // 港股延时
      if (not FIsHKReal) and (FServerInfoList[i].ServerType = stStockHK) then
      begin
        Strings.DelimitedText := FHKDelayServer;
      end
      else
        Strings.DelimitedText := FServerInfoList[i].Server;
      for j := 0 to Strings.Count - 1 do
      begin
        Index := Pos(':', Strings[j]);
        IP := trim(Copy(Strings[j], 1, Index - 1));
        Port := strtointdef(trim(Copy(Strings[j], Index + 1, 16)), 0);
        if (IP <> '') and (Port <> 0) then
        begin
          FQuoteManager.ServerSetting(IP, Port, FServerInfoList[i].ServerType);
        end
        else
          OutLog(llFatal, Format('[QuoteMng]%s 行情服务器地址错误:%s .', [FServerInfoList[i].Name, Strings[j]]));
      end;
    end;
  finally
    Strings.Free;
  end;
end;

procedure TQuoteManagerEx.ConnectQuoteServer();
var
  i: Integer;
begin
  for i := 0 to FServerInfoList.Count - 1 do
  begin
    case FServerInfoList[i].ServerType of
      // stStockLevelI:FQuoteManager.Connect();
      stStockLevelII:
        if FIsLevel2Right then
        begin
          ConnectServer(FServerInfoList[i].ServerType);
        end;
      // stFutues:;
      // stStockHK:
      // if FIsHKReal then
      // ConnectServer(stStockHK);
      // stForeign:;
      // stHKDelay:
      // if not FIsHKReal then
      // //FQuoteManager.Connect(stStockHK);
      // ConnectServer(stStockHK);
      // stDDE:;
    else
      ConnectServer(FServerInfoList[i].ServerType);
    end;
  end;
end;

procedure TQuoteManagerEx.ConnectServer(AServerType: ServerTypeEnum);
begin
  FDaemonThread.AddServerType(AServerType);
  FQuoteManager.Connect(AServerType);
  FDaemonThread.UpdateServerStatus(AServerType, ssConnecting);
end;

procedure TQuoteManagerEx.DisconnectQuoteServer();
var
  i: Integer;
begin
  for i := 0 to FServerInfoList.Count - 1 do
  begin
    FQuoteManager.DisConnect(FServerInfoList[i].ServerType);
  end;
end;

procedure TQuoteManagerEx.CodeInfoDoNotify(Sender: TObject; const Item: PCodeInfo; Action: System.Generics.Collections.TCollectionNotification);
begin
  DoNotify(Sender, Item, Action);
end;

procedure TQuoteManagerEx.ServerInfoDoNotify(Sender: TObject; const Item: PServerInfo; Action: System.Generics.Collections.TCollectionNotification);
begin
  DoNotify(Sender, Item, Action);
end;

procedure TQuoteManagerEx.DoNotify(Sender: TObject; const Item: Pointer; Action: System.Generics.Collections.TCollectionNotification);
begin
  if Action = cnRemoved then
  begin
    Dispose(Item);
  end;
end;

procedure TQuoteManagerEx.DoConnected(const IP: WideString; Port: Word; ServerType: ServerTypeEnum);
begin
  OutLog(llWarn, Format('[QuoteMng] -%s 连接服务器成功: -%s :%d', [Get_QuoteTypeName(ServerType), IP, Port]));
  FDaemonThread.UpdateServerStatus(ServerType, ssConnected);
end;

procedure TQuoteManagerEx.DoDisconnected(const IP: WideString; Port: Word; ServerType: ServerTypeEnum);
begin
  if not FQuoteManager.Active then
    Exit;
  OutLog(llWarn, Format('[QuoteMng] -%s -%s :%d 服务器断开连接,重连.', [Get_QuoteTypeName(ServerType), IP, Port]));
  FDaemonThread.UpdateServerStatus(ServerType, ssDisconnect);
end;

procedure TQuoteManagerEx.DoWriteLog(const Log: WideString);
begin
  OutLog(llWarn, Format('[QuoteMng] %s ', [Log]));
end;

procedure TQuoteManagerEx.DoProgress(const Msg: WideString; Max, Value: Integer);
begin
  OutLog(llWarn, Format('[QuoteMng] %s %d/%d ', [Msg, Value, Max]));
end;

procedure TQuoteManagerEx.DoUpdateConceptCodes(Sender: TObject);
var
  AName, APreName, APreKey, AKey: string;
  ANBBM: Integer;
  tmpValue: Int64;
  ACodeInfo: PCodeInfo;
  AEnum: TDictionary<Integer, string>.TPairEnumerator;
begin
  AEnum := FInnerCodeToNameHash.GetEnumerator;
  while (AEnum.MoveNext) do
  begin
    AName := AEnum.Current.Value;
    if(FQuoteRealTime.GetCodeInfoByName(AName, tmpValue))then
    begin
      ACodeInfo := PCodeInfo(tmpValue);
      AKey := CodeInfoKey(ACodeInfo);

      APreKey := FkeyStrHash[AEnum.Current.Key];
      if(AKey <> APreKey)and(FCodeInfoHash.TryGetValue(APreKey, ANBBM))then
      begin
        if(FInnerCodeToNameHash.TryGetValue(ANBBM, APreName))and(APreName = AName)then
          FCodeInfoHash.Remove(APreKey);
      end;
      FCodeInfoHash.AddOrSetValue(AKey, AEnum.Current.Key);
      FkeyStrHash.AddOrSetValue(AEnum.Current.Key, AKey);
    end;
  end;
end;

{ IExtensibility }
procedure TQuoteManagerEx.OnConnection(const GilAppController: IGilAppController; NotifySvr: INotifyServices;
  AHandle: THandle);
var
  i: Integer;
  p: PProxyRec;
  ADataSet: IWNDataSet;
begin
  FMaket20CodeAgent := TDictionary<Integer, string>.Create(50);
  FController := GilAppController;
  FQuoteManager := TQuoteManager.Create;
  FQuoteManager.SetWorkPath(GilAppController.GetSettingPath + 'Quote\');
  FQuoteEvent := TQuoteManagerEvents.Create(nil);
  FQuoteEvent.ConnectTo(FQuoteManager);
  FQuoteEvent.OnConnected := DoConnected;
  FQuoteEvent.OnDisconnected := DoDisconnected;
  FQuoteEvent.OnWriteLog := DoWriteLog;
  FQuoteEvent.OnProgress := DoProgress;
  FQuoteManager.ClearSetting;
  FQuoteManager.ConcurrentSetting(1);
  InitializeCriticalSection(FCritical);
  // FSuffixMap := THashedStringList.Create;

  // FQuoteManager.ServerSetting();

  FCodeInfoHash := TDictionary<String, Integer>.Create(40000);
  FkeyStrHash := TDictionary<Integer, string>.Create(40000);
  FNameToInnerCodeHash := TDictionary<String, Integer>.Create(1000);
  FInnerCodeToNameHash := TDictionary<Integer, string>.Create(1000);
  // FCodeInfoHash.OnValueNotify := CodeInfoDoNotify;
  FServerInfoList := TList<PServerInfo>.Create();
  FServerInfoList.OnNotify := ServerInfoDoNotify;
  InitHSCodeAgentByINI();

  FIsHKReal := False;
  ADataSet := FController.GFQueryHighDataBlocking(0, 'USER_QX_HK()', 0, 3000);
  if (ADataSet <> nil) and (ADataSet.RecordCount > 0) then
  begin
    ADataSet.First;
    if not ADataSet.Fields(0).IsNull then
      FIsHKReal := ADataSet.Fields(0).AsInteger > 0;
  end
  else
    OutLog(llError, '[QuoteMng] HK实时权限获取失败，ADataSet存在=' + BoolToStr(Assigned(ADataSet), True));
  LoadConfig();

  ADataSet := FController.GFQueryHighDataBlocking(0, 'USER_LEVEL2_INFO()', 0, 3000);
  if (ADataSet <> nil) and (ADataSet.RecordCount > 0) then
  begin
    FIsLevel2Right := True;
    ADataSet.First;
    FLevel2User := ADataSet.Fields(0).AsString;
    FLevel2Pass := ADataSet.Fields(1).AsString;
  end
  else
    OutLog(llError, '[QuoteMng] L2权限获取失败，ADataSet存在=' + BoolToStr(Assigned(ADataSet), True));

//  FIsLevel2Right := True;
//  FLevel2User := '803100069';
//  FLevel2Pass := '888888';

  SetQuoteServer;
  p := FController.GetProxyInfo;
  if (p <> nil) and (p.mtype <> ptNoProxy) then
  begin
    FQuoteManager.Proxy1Setting(ProxyTypeToProxyKindEnum(p.mtype), p.mIP, p.mPort, p.User, p.Pwd);
  end;
  FQuoteManager.StartService();
  FDaemonThread := TDaemonThread.Create;
  FDaemonThread.FManagerEx := self;
  ConnectQuoteServer();
  // InitCodeInfo();
  FQuoteRealTime := FQuoteManager.QueryData(QuoteType_REALTIME, 0) as IQuoteRealTime;
  FQuoteRealTime.OnUpdateConceptCodes := DoUpdateConceptCodes;
  // for i := 0 to FServerInfoList.Count - 1 do
  // FDaemonThread.AddServerType(FServerInfoList[i].ServerType);
  FNeedInitCodeInfo := True;
  FDaemonThread.Start;
end;

procedure TQuoteManagerEx.OnDisconnection;
begin
  freeandnil(FMaket20CodeAgent);
  if FDaemonThread <> nil then
  begin
    FDaemonThread.Terminate;
    WaitForSingleObject(FDaemonThread.Handle, INFINITE);
    freeandnil(FDaemonThread);
  end;
  DeleteCriticalSection(FCritical);
  FQuoteRealTime := nil;
  freeandnil(FkeyStrHash);
  freeandnil(FCodeInfoHash);
  freeandnil(FNameToInnerCodeHash);
  freeandnil(FInnerCodeToNameHash);
  
  if Assigned(FQuoteEvent) then
  begin
    FQuoteEvent.DisConnect;
    freeandnil(FQuoteEvent);
  end;
  FTypeLib := nil;
  if Assigned(FQuoteManager) then
  begin
    // FQuoteManager.Disconnect();
    FQuoteManager.StopService;
    DisconnectQuoteServer();
    FQuoteManager := nil;
  end;
  // freeandnil(FSuffixMap);
  FController := nil;
  freeandnil(FServerInfoList);

  // FQuoteManager.
end;

procedure TQuoteManagerEx.OutLog(ALogLevel: LogLevel; ALog: WideString);
var
  tmpLog: string;
begin
  tmpLog := '[TQuoteManagerEx]:' + ALog;
{$IFDEF DEBUG}
  OutputDebugString(pchar(tmpLog));
{$ENDIF}
  if Assigned(FController) then
  begin
    FController.GetLogWriter.Log(ALogLevel, tmpLog);
  end;
end;

procedure TQuoteManagerEx.OnChangeLanguage;
begin

end;

{ IQuoteManagerProxy }
function TQuoteManagerEx.Get_Active: WordBool;
begin
  Result := FQuoteManager.Active;
end;

procedure TQuoteManagerEx.ConnectMessage(const QuoteMessage: IQuoteMessage);
begin
  FQuoteManager.ConnectMessage(QuoteMessage);
  if QuoteMessage <> nil then
    QuoteMessage.MsgActive := True;
end;

procedure TQuoteManagerEx.DisconnectMessage(const QuoteMessage: IQuoteMessage);
begin
  FQuoteManager.DisconnectMessage(QuoteMessage);
  if QuoteMessage <> nil then
    QuoteMessage.MsgActive := False;
end;

function TQuoteManagerEx.Subscribe(QuoteType: QuoteTypeEnum; pCodeInfos: Int64; Count: Integer; Cookie: Integer;
  Value: OleVariant): WordBool;
begin
  Result := FQuoteManager.Subscribe(QuoteType, pCodeInfos, Count, Cookie, Value);
end;

function TQuoteManagerEx.QueryData(QuoteType: QuoteTypeEnum; PCodeInfo: Int64): IUnknown;
begin
  Result := FQuoteManager.QueryData(QuoteType, PCodeInfo);
end;

procedure TQuoteManagerEx.ConnectServerInfo(ServerType: ServerTypeEnum; var IP: WideString; var Port: Word);
begin
  FQuoteManager.ConnectServerInfo(ServerType, IP, Port);
end;

function TQuoteManagerEx.Get_Connected(ServerType: ServerTypeEnum): WordBool;
begin
  Result := FQuoteManager.Connected[ServerType];
end;

Function TQuoteManagerEx.Get_QuoteTypeCount(): Integer;
begin
  Result := FServerInfoList.Count;
end;

procedure TQuoteManagerEx.Get_AllQuoteType(QuoteTypes: Int64; Count: Integer);
var
  i: Integer;
  tmp: Integer;
  p: PServerTypeEnum;
begin
  tmp := min(Count - 1, FServerInfoList.Count - 1);
  p := PServerTypeEnum(QuoteTypes);
  for i := 0 to tmp do
  begin
    p^ := FServerInfoList[i].ServerType;
    inc(p);
  end;
end;

Function TQuoteManagerEx.Get_QuoteTypeName(ServerType: ServerTypeEnum): WideString;
var
  i: Integer;
begin
  for i := 0 to FServerInfoList.Count - 1 do
  begin
    if FServerInfoList[i].ServerType = ServerType then
    begin
      Result := FServerInfoList[i].Name;
    end;
  end;
end;

function TQuoteManagerEx.IsLevel2(InnerCode: Integer): Boolean;
var
  IsHS: Boolean;
  CodeInfo: TCodeInfo;
begin
  if InnerCode = 0 then
    Exit(FIsLevel2Right);
  Result := False;
  // if not FCodeInfoHash.TryGetValue(InnerCode,p) then Exit;
  if GetCodeInfoByInnerCode(Int64(@InnerCode), Int64(@CodeInfo)) then
  begin
    // 上海证券交所,深圳证券交易所上市交易的证券有Level2
    IsHS := HSMarketBourseType(CodeInfo.m_cCodeType, STOCK_MARKET, SH_BOURSE) or
      HSMarketBourseType(CodeInfo.m_cCodeType, STOCK_MARKET, SZ_BOURSE);
    Result := FIsLevel2Right and IsHS;
  end;
end;

Function TQuoteManagerEx.IsHKReal(): Boolean;
begin
  Result := FIsHKReal;
end;

Function TQuoteManagerEx.GetTypeLib(): ITypeLib;
var
  AModule: HMODULE;
  Name: string;
begin
  if FTypeLib = nil then
  begin
    AModule := HInstance;
    SetLength(name, MAX_PATH);
    GetModuleFileName(AModule, pchar(name), MAX_PATH);
    OLEcheck(LoadTypeLibEx(pchar(name), REGKIND_NONE, FTypeLib));
  end;
  Result := FTypeLib;
end;

Function TQuoteManagerEx.GetCodeInfoByInnerCodes(InnerCodes: Int64; Count: Integer): IQuoteCodeInfosEx;
var
  QCInfos: TQuoteCodeInfos;
  pInnerCode: PInteger;
  i: Integer;
  p: PCodeInfo;
  tmp: Int64;
  tmpStr: string;
begin
  // OutputDebugString(pchar(Format('TQuoteManagerEx.GetCodeInfoByInnerCodes begin:%.3f',
  // [GetTickCount / 1000])));

  QCInfos := TQuoteCodeInfos.Create();
  Result := QCInfos;
  if Count = 0 then
    Exit;
  QCInfos.SetCapacity(Count);
  pInnerCode := PInteger(InnerCodes);
  self.Lock;
  try
    for i := 0 to Count - 1 do
    begin
      p := nil;
      if FkeyStrHash.TryGetValue(pInnerCode^, tmpStr) then
      begin
        tmp := 0;
        FQuoteRealTime.GetCodeInfoByKeyStr(tmpStr, tmp);
        p := PCodeInfo(tmp);
        end;
      QCInfos.Add(p, pInnerCode^);
      inc(pInnerCode);
    end;
  finally
    self.UnLock;
  end;
  // OutputDebugString
  // (pchar(Format('TQuoteManagerEx.GetCodeInfoByInnerCodes End:%.3f',
  // [GetTickCount / 1000])));
end;

{ procedure TQuoteManagerEx.GetCodeInfos(NBBMs: string;
  hash: TDictionary<Integer, PCodeInfo>);
  var
  p: PCodeInfo;
  tmp: Int64;
  KeyStr: String;
  DataSet: IWNDataSet;
  function GetCode(const SecuCode, HSCode: String): string;
  begin
  if HSCode <> '' then
  Result := HSCode
  else
  Result := SecuCode;
  end;

  var
  Code: string;
  begin
  // if not FCodeInfoHash.TryGetValue(ANBBM,Result) then
  // begin
  DataSet := FController.CacheQueryData('', StringReplace(FInnerCodeSQL,
  '!InnerCodes', NBBMs, [rfReplaceAll]));
  if DataSet <> nil then
  begin
  while not DataSet.Eof do
  begin
  // NBBM,GPDM,ZQSC,oZQLB,oNBBM
  if DataSet.FieldByName('oZQLB').AsInteger = 110 then // 个股期权
  Code := DataSet.FieldByName('GSDM').AsString
  else
  Code := GetCode(DataSet.FieldByName('GPDM').AsString,
  DataSet.FieldByName('HSCode').AsString);
  Code := GetKeyByZQLB(DataSet.FieldByName('ZQSC').AsInteger,
  DataSet.FieldByName('oZQLB').AsInteger, Code);
  if FQuoteRealTime.GetCodeInfoByKeyStr(Code, tmp) then
  begin
  hash.AddOrSetValue(DataSet.FieldByName('NBBM').AsInteger,
  PCodeInfo(tmp));
  end
  else
  begin
  // hash.AddOrSetValue(DataSet.FieldByName('NBBM').AsInteger,nil);
  OutLog(llWarn,
  Format('证券没有CodeInfo,InnerCode=%d,Key=%s.',
  [DataSet.FieldByName('NBBM').AsInteger, Code]));
  end;
  DataSet.Next;
  end;
  DataSet := nil;
  end;
  end; }

Function TQuoteManagerEx.GetCodeInfoByInnerCode(InnerCode: Int64; CodeInfo: Int64): Boolean;
var
  p: PCodeInfo;
  tempStr: string;
  tmp: Int64;
begin
  Result := False;
  self.Lock;
  try
    if CodeInfo = 0 then
      Exit;
    try
      FillMemory(PCodeInfo(CodeInfo), SizeOf(TCodeInfo), 0);
      if FkeyStrHash.TryGetValue(PInteger(InnerCode)^, tempStr) then
      begin
        tmp := 0;
        FQuoteRealTime.GetCodeInfoByKeyStr(tempStr, tmp);
        p := PCodeInfo(tmp);
        if p <> nil then
        begin
          PCodeInfo(CodeInfo)^ := p^;
          Result := True;
        end;
      end;
    finally
    end;
  finally
    self.UnLock;
  end;
end;

{ Function TQuoteManagerEx.GetCodeInfoBySecuCode(SecuCode: WideString;
  CodeInfo: Int64): Boolean;
  procedure getCodeSuffix(SecuCode: string; var Code, Suffix: string);
  var
  Index: Integer;
  begin
  Suffix := '';
  Index := Pos('.', SecuCode);
  if Index > 0 then
  begin
  Code := Copy(SecuCode, 1, Index - 1);
  Suffix := Copy(SecuCode, Index + 1, length(SecuCode));
  end
  else
  Code := SecuCode;
  end;

  var
  Key, Code, Suffix, MapSuffix: string;
  p: Int64;
  begin
  Result := False;
  if not FkeyStrHash.TryGetValue(SecuCode, Key) then
  begin
  getCodeSuffix(SecuCode, Code, Suffix);
  MapSuffix := FSuffixMap.Values[Suffix];
  if MapSuffix <> '' then
  begin
  Key := Code + '_' + MapSuffix;
  end
  else
  Key := Code + '_' + Suffix;
  end;

  if FQuoteRealTime.GetCodeInfoByKeyStr(Key, Int64(p)) then
  begin
  PCodeInfo(CodeInfo)^ := PCodeInfo(p)^;
  Result := True;
  end;
  end; }

procedure TQuoteManagerEx.CodeInfo2InnerCode(CodeInfos: Int64; Count: Integer; InnerCodes: Int64);
var
  p: PInteger;
  i: Integer;
  pC: PCodeInfo;
  tmp: Integer;
begin
  p := PInteger(InnerCodes);
  pC := PCodeInfo(CodeInfos);
  self.Lock;
  try
    for i := 0 to Count - 1 do
    begin
      tmp := 0;
      FCodeInfoHash.TryGetValue(CodeInfoKey(pC), tmp);
      p^ := tmp;
      inc(p);
      inc(pC);
    end;
  finally
    self.UnLock;
  end;
end;

Destructor TQuoteManagerEx.Destroy;
begin
  inherited;
end;

end.
