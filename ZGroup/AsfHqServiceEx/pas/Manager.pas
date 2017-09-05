unit Manager;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, Classes, SysUtils, Windows, Messages, ActiveX, AxCtrls, QuoteMngr_TLB, StdVcl,
  QuoteService, IOCPClient, QuoteSubscribe, QuoteDataMngr, QuoteBusiness, QuoteConst, QuoteStruct,
  QuoteDataObject, Dialogs, QuoteLibrary;

type
  TQuoteManager = class(TAutoObject, IConnectionPointContainer, IQuoteManager)
  private
    FConnectionPoints: TConnectionPoints;
    FEventIID: TGUID;

    FHandle: THandle;
    FQuoteService: TQuoteService;
    FQuoteDataMngr: TQuoteDataMngr;
    FQuoteSubscribe: TQuoteSubscribe;
    FQuoteBusiness: TQuoteBusiness;
    FCheckSerialNumOk: boolean;

    procedure WndProc(var Message: TMessage);
    procedure InitWorkPath(const AppPath: string);

    procedure DoEventConnected(const IP: string; Port: word; ServerType: ServerTypeEnum);

    procedure DoEventDisconnected(const IP: string; Port: word; ServerType: ServerTypeEnum);
    procedure DoEventWriteLog(const Log: string);
    procedure DoEventProgress(const Msg: string; Max, Value: Integer);
    procedure DoHandleEvent(eData: PEventData);
    procedure CheckSerialNum;
  protected
    function Get_Connected(ServerType: ServerTypeEnum): WordBool; safecall;
    procedure LevelSetting(const User, Pass: WideString); safecall;
    procedure SendKeepActiveTime(ServerType: ServerTypeEnum); safecall;
    function KeepActiveRecvTime(ServerType: ServerTypeEnum): Double; safecall;
    procedure ConnectServerInfo(ServerType: ServerTypeEnum; var IP: WideString; var Port: word); safecall;
    procedure SetWorkPath(const APath: WideString); safecall;
    property ConnectionPoints: TConnectionPoints read FConnectionPoints implements IConnectionPointContainer;
    procedure ConnectionEnum(var EnumConnections: IEnumConnections);

    function Get_Active: WordBool; safecall;
    procedure ClearSetting; safecall;
    function ConcurrentSetting(Value: word): WordBool; safecall;
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    function Proxy1Setting(ProxyKind: ProxyKindEnum; const ProxyIP: WideString; ProxyPort: word;
      const ProxyUser, ProxyPWD: WideString): WordBool; safecall;
    function Proxy2Setting(ProxyKind: ProxyKindEnum; const ProxyIP: WideString; ProxyPort: word;
      const ProxyUser, ProxyPWD: WideString): WordBool; safecall;
    function QueryData(QuoteType: QuoteTypeEnum; CodeInfo: Int64): IUnknown; safecall;

    function ServerSetting(const IP: WideString; Port: word; ServerType: ServerTypeEnum): WordBool; safecall;
    procedure StartService; safecall;
    procedure StopService; safecall;
    function Subscribe(QuoteType: QuoteTypeEnum; Stocks: Int64; Count, Cookie: Integer; Value: OleVariant)
      : WordBool; safecall;
    procedure Connect(ServerType: ServerTypeEnum); safecall;
    procedure Disconnect(ServerType: ServerTypeEnum); safecall;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ, IOCPMemory, U_SerialUtils, md5, U_Des;

procedure TQuoteManager.ConnectionEnum(var EnumConnections: IEnumConnections);
var
  Container: IConnectionPointContainer;
  CP: IConnectionPoint;
begin
  EnumConnections := nil;
  OleCheck(QueryInterface(IConnectionPointContainer, Container));
  if Container <> nil then
  begin
    OleCheck(Container.FindConnectionPoint(FEventIID, CP));
    if CP <> nil then
      CP.EnumConnections(EnumConnections);
  end;
end;

function TQuoteManager.Get_Active: WordBool;
begin
  if FQuoteService <> nil then
    result := FQuoteService.Active
  else
    result := false;
end;

procedure TQuoteManager.Initialize;
begin
  // WriteLogx('Initialize');
  inherited Initialize;

  // 创建 事件
  FEventIID := DIID_IQuoteManagerEvents;
  FConnectionPoints := TConnectionPoints.Create(self);
  FConnectionPoints.CreateConnectionPoint(FEventIID, ckMulti, nil);
  // 去掉验证.
  // CheckSerialNum;
  // if not FCheckSerialNumOk then exit;

  FHandle := Classes.AllocateHWnd(WndProc);

  FQuoteService := TQuoteService.Create(FHandle);
  FQuoteDataMngr := TQuoteDataMngr.Create(FQuoteService);

  FQuoteBusiness := TQuoteBusiness.Create(FQuoteService, FQuoteDataMngr);
  // 业务分支
  FQuoteService.OnHandleBusiness := FQuoteBusiness.DoHandleBusiness;
  // 心跳包
  FQuoteService.OnKeepActive := FQuoteBusiness.ReqKeepActive;

  FQuoteSubscribe := TQuoteSubscribe.Create(FQuoteService, FQuoteDataMngr, FQuoteBusiness);
  // 到达通知
  FQuoteBusiness.OnActiveMessage := FQuoteSubscribe.DoActiveMessage;
  // 初始化通知事件
  FQuoteBusiness.OnResetMessage := FQuoteSubscribe.DoResetMessage;
  // 到达通知
  FQuoteBusiness.OnActiveMessageCookie := FQuoteSubscribe.DoActiveMessageCookie;

end;

procedure TQuoteManager.InitWorkPath(const AppPath: string);
// 建立目录
  procedure BuildPath(Path: string);
  begin
    if (Path <> '') and not DirectoryExists(Path) then
    begin
      BuildPath(ExtractFileDir(Path));
      CreateDir(Path);
    end;
  end;

begin
  BuildPath(AppPath + PATH_Setting);
  BuildPath(AppPath + PATH_Block);
  BuildPath(AppPath + PATH_UserBlock);
  BuildPath(AppPath + PATH_Data);

  BuildPath(AppPath + PATH_Data_SH_Day);
  BuildPath(AppPath + PATH_Data_SH_min1);
  BuildPath(AppPath + PATH_Data_SH_min5);

  BuildPath(AppPath + PATH_Data_SZ_Day);
  BuildPath(AppPath + PATH_Data_SZ_min1);
  BuildPath(AppPath + PATH_Data_SZ_min5);
end;

destructor TQuoteManager.Destroy;
begin
  if FConnectionPoints <> nil then
  begin
    FConnectionPoints.Free;
    FConnectionPoints := nil;
  end;
  if FQuoteSubscribe <> nil then
  begin
    FQuoteSubscribe.Free;
    FQuoteSubscribe := nil;
  end;

  if FQuoteDataMngr <> nil then
  begin
    FQuoteDataMngr.Free;
    FQuoteDataMngr := nil;

  end;

  if FQuoteBusiness <> nil then
  begin
    FQuoteBusiness.Free;
    FQuoteBusiness := nil;

  end;

  if FQuoteService <> nil then
  begin
    FQuoteService.Free;
    FQuoteService := nil;
  end;

  if FHandle <> 0 then
  begin
    Classes.DeallocateHWnd(FHandle);
    FHandle := 0;
  end;

  inherited Destroy;
end;

procedure TQuoteManager.CheckSerialNum;
var
  DllPath: string;
  VolumeSerialNumber: DWord;
  Number, FileNumber: AnsiString;
  Strings: TStringList;
begin
  FCheckSerialNumOk := true;
  exit;

  FCheckSerialNumOk := false;
  SetLength(DllPath, MAX_PATH);
  GetModuleFileName(HInstance, PChar(DllPath), MAX_PATH);
  DllPath := ExtractFilePath(PChar(DllPath));

  if FileExists(DllPath + '\QuoteMngr.sn') then
  begin

    Strings := TStringList.Create;
    try
      Strings.LoadFromFile(DllPath + '\QuoteMngr.sn');
      if Strings.Count > 0 then
        FileNumber := AnsiString(Strings[0])
      else
        FileNumber := AnsiString('');
    finally
      Strings.Free;
    end;

    // 获取序列号
    VolumeSerialNumber := GetSysDriveSerialNum;
    Number := AnsiString(Copy(IntToHex(VolumeSerialNumber, 0), 1, 4) + '-' + Copy(IntToHex(VolumeSerialNumber, 0), 5, 4));
    // 验证串
    Number := MD5S(EncryStrHex(Number, MD5S('Hundsun@1' + Number)));

    FCheckSerialNumOk := Number = FileNumber;

  end;

  if not FCheckSerialNumOk then
    Showmessage('机器绑定验证错误!请与技术人员联系！');

end;

procedure TQuoteManager.ClearSetting;
begin
  if FQuoteService <> nil then
    FQuoteService.ClearSetting;
end;

function TQuoteManager.ConcurrentSetting(Value: word): WordBool;
begin
  if FQuoteService <> nil then
    result := FQuoteService.ConcurrentSetting(Value)
  else
    result := false;
end;

procedure TQuoteManager.ConnectMessage(const QuoteMessage: IQuoteMessage);
begin
  if FQuoteSubscribe <> nil then
    FQuoteSubscribe.ConnectMessage(QuoteMessage)
end;

procedure TQuoteManager.DisconnectMessage(const QuoteMessage: IQuoteMessage);
begin
  if FQuoteSubscribe <> nil then
    FQuoteSubscribe.DisconnectMessage(QuoteMessage)
end;

procedure TQuoteManager.DoEventConnected(const IP: string; Port: word; ServerType: ServerTypeEnum);
var
  EC: IEnumConnections;
  ConnectData: TConnectData;
  Fetched: Cardinal;
begin
  // 击活事件
  if (FQuoteService <> nil) and FQuoteService.Active then
    try
      ConnectionEnum(EC);
      if EC <> nil then
      begin
        while EC.Next(1, ConnectData, @Fetched) = S_OK do
          if ConnectData.pUnk <> nil then
            (ConnectData.pUnk as IQuoteManagerEvents).OnConnected(IP, Port, ServerType);
      end;
    except

    end;
end;

procedure TQuoteManager.DoEventDisconnected(const IP: string; Port: word; ServerType: ServerTypeEnum);
var
  EC: IEnumConnections;
  ConnectData: TConnectData;
  Fetched: Cardinal;
begin
  // 击活事件
  if (FQuoteService <> nil) and FQuoteService.Active then
    try
      ConnectionEnum(EC);
      if EC <> nil then
      begin
        while EC.Next(1, ConnectData, @Fetched) = S_OK do
          if ConnectData.pUnk <> nil then
            (ConnectData.pUnk as IQuoteManagerEvents).OnDisconnected(IP, Port, ServerType);
      end;
    except

    end;
end;

procedure TQuoteManager.DoEventProgress(const Msg: string; Max, Value: Integer);
var
  EC: IEnumConnections;
  ConnectData: TConnectData;
  Fetched: Cardinal;
begin
  if (FQuoteService <> nil) and FQuoteService.Active then
    try
      // 击活事件
      ConnectionEnum(EC);
      if EC <> nil then
      begin
        while EC.Next(1, ConnectData, @Fetched) = S_OK do
          if ConnectData.pUnk <> nil then
            (ConnectData.pUnk as IQuoteManagerEvents).OnProgress(Msg, Max, Value);
      end;
    except

    end;
end;

procedure TQuoteManager.DoEventWriteLog(const Log: string);
var
  EC: IEnumConnections;
  ConnectData: TConnectData;
  Fetched: Cardinal;
begin

  if Log = '' then
    exit;

  if (FQuoteService <> nil) and FQuoteService.Active then
    try
      // 击活事件
      ConnectionEnum(EC);
      if EC <> nil then
      begin
        while EC.Next(1, ConnectData, @Fetched) = S_OK do
          if ConnectData.pUnk <> nil then
            (ConnectData.pUnk as IQuoteManagerEvents).OnWriteLog(Log);
      end;
    except
    end;
end;

procedure TQuoteManager.DoHandleEvent(eData: PEventData);
var
  ServerIp: string;
  ServerPort: word;
begin
  if (FQuoteService <> nil) and FQuoteService.Active then
    case eData^.EventType of

      etWriteLog:
        begin
          // WriteLogx('etWriteLog'+AnsiString(eData^.SValue));
          DoEventWriteLog(string(PChar(eData^.SValue)));
        end;
      etProgress:
        begin
          // WriteLogx('etProgress');
          // DoEventProgress(eData^.SValue, edata^.Flag, edata^.DataLen);
        end;
      etConnected:
        begin
          // WriteLogx('etConnected');
          // 触发连接事件
          FQuoteService.ConnectServerInfo(eData^.Flag, ServerIp, ServerPort);
          DoEventConnected(ServerIp, ServerPort, eData^.Flag);

          case eData^.Flag of
            stStockLevelI:
              begin
                FQuoteBusiness.ReqUserLogin;
              end;
            stForeign:
              begin
                FQuoteBusiness.ReqForeignUserLogin;
              end;
            stStockLevelII:
              begin
                // 业务流程 用户登陆
                FQuoteBusiness.ReqLevelUserLogin;
              end;
            stFutues:
              begin
                FQuoteBusiness.ReqFutuesUserLogin;
              end;
            stStockHK:
              begin
                FQuoteBusiness.ReqHKUserLogin;
              end;
            stDDE:
              FQuoteBusiness.ReqDDEUserLogin;
            stUSStock:
              FQuoteBusiness.ReqUSStockUserLogin;
          end;
        end;

      etLogin:
        begin // 登陆成功
          // WriteLogx('etLogin');
          // 获取初始信息
          FQuoteBusiness.ReqInitialInfo(stStockLevelI);
        end;
      // etInited:
      // FQuoteBusiness.ReqBlockData(eData.Flag);
      etLoginHK:
        begin // 登陆成功
          // WriteLogx('etLoginHK');
          // 获取初始信息
          FQuoteBusiness.ReqInitialInfo(stStockHK);
        end;
      etLoginLevel:
        begin
          // WriteLogx('etLoginLevel');
          // 获取初始信息
          // 登陆成功
          // FQuoteService.BusinessLogin[stStockLevelII] := 2;

          FQuoteService.ConnectServerInfo(stStockLevelII, ServerIp, ServerPort);
          FQuoteService.WriteDebug(('level2登陆成功! ' + ServerIp + ':' + inttostr(ServerPort)));
        end;
      etLoginDDE:
        begin
          // WriteLogx('etLoginLevel');
          // 获取初始信息
          // 登陆成功
          // FQuoteService.BusinessLogin[stStockLevelII] := 2;

          FQuoteService.ConnectServerInfo(stDDE, ServerIp, ServerPort);
          FQuoteService.WriteDebug(('DDE登陆成功! ' + ServerIp + ':' + inttostr(ServerPort)));
        end;

      etLoginUSStock:
        begin
          FQuoteBusiness.ReqInitialInfo(stUSStock);
        end;

      etLoginForeign:
        begin
          // WriteLogx('etLoginForeign');
          // 获取初始信息
          FQuoteBusiness.ReqInitialInfo(stForeign);
          FQuoteBusiness.ReqForeignBASEINFO(stForeign);
        end;

      etLoginFutues:
        begin
          // WriteLogx('etLoginFutues');
          // 获取初始信息
          FQuoteBusiness.ReqInitialInfo(stFutues);
        end;

      etAnsKeepActive:
        begin
          // WriteLogx('etAnsKeepActive');
          FQuoteService.EventAnsKeepActive(eData^.Flag);
        end;

      etDisconnected:
        begin
          // WriteLogx('etDisconnected');
          // 触发连接事件
          FQuoteService.ConnectServerInfo(eData^.Flag, ServerIp, ServerPort);
          DoEventDisconnected(ServerIp, ServerPort, eData^.Flag);
        end;

      etConnectServerError:
        begin // 连接服务器失败
          // WriteLogx('etConnectServerError');
          // 触发连接事件
          FQuoteService.ConnectServerInfo(eData^.Flag, ServerIp, ServerPort);
          // 触发连接事件
          DoEventDisconnected(ServerIp, ServerPort, 99900);
        end;
    end;
  // WriteLogx('DoHandleEvent ok');
end;

function TQuoteManager.Proxy1Setting(ProxyKind: ProxyKindEnum; const ProxyIP: WideString; ProxyPort: word;
  const ProxyUser, ProxyPWD: WideString): WordBool;
begin
  if FQuoteService <> nil then
    result := FQuoteService.Proxy1Setting(TProxyKind(ProxyKind), ProxyIP, ProxyPort, ProxyUser, ProxyPWD)
  else
    result := false;
end;

function TQuoteManager.Proxy2Setting(ProxyKind: ProxyKindEnum; const ProxyIP: WideString; ProxyPort: word;
  const ProxyUser, ProxyPWD: WideString): WordBool;
begin
  if FQuoteService <> nil then
    result := FQuoteService.Proxy2Setting(TProxyKind(ProxyKind), ProxyIP, ProxyPort, ProxyUser, ProxyPWD)
  else
    result := false;
end;

function TQuoteManager.QueryData(QuoteType: QuoteTypeEnum; CodeInfo: Int64): IUnknown;

begin
  if FQuoteDataMngr <> nil then
  begin
    // 如果是排序,取单列行情数据 CodeInfo就是cookie
    if (QuoteType = QuoteType_REPORTSORT) or (QuoteType = QuoteType_GENERALSORT) or (QuoteType = QuoteType_SingleColValue)
    then
      result := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType, inttostr(CodeInfo)]
    else if QuoteType = QuoteType_MarketMonitor then // 短线精灵
      result := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType, '']
      // else if QuoteType = QuoteType_SingleColValue then   //如果是取单列行情的话 CodeInfo就是cookie
      // result := FQuoteDataMngr.QuoteDataObjsByKey[QuoteType, inttostr(CodeInfo)]
    else
      result := FQuoteDataMngr.QuoteDataObjs[QuoteType, PCodeInfo(CodeInfo)]
  end
  else
    result := nil;
end;

function TQuoteManager.ServerSetting(const IP: WideString; Port: word; ServerType: ServerTypeEnum): WordBool;

begin
  if FQuoteService <> nil then
    result := FQuoteService.ServerSetting(IP, Port, ServerType)
  else
    result := false;
end;

procedure TQuoteManager.StartService;
begin
  // 创建工作目录
  InitWorkPath(FQuoteDataMngr.AppPath);
  if FQuoteService <> nil then
    FQuoteService.StartService;
end;

procedure TQuoteManager.StopService;
begin
  if FQuoteService <> nil then
    FQuoteService.StopService;
end;

function TQuoteManager.Subscribe(QuoteType: QuoteTypeEnum; Stocks: Int64; Count, Cookie: Integer; Value: OleVariant)
  : WordBool;
begin
  if FQuoteSubscribe <> nil then
    result := FQuoteSubscribe.Subscribe(QuoteType, PCodeInfos(Stocks), Count, Cookie, Value)
  else
    result := false;
end;

procedure TQuoteManager.WndProc(var Message: TMessage);
var
  eData: PEventData;
begin
  // 连接成功
  if (Message.Msg = WM_HandleEvent) and (FQuoteService <> nil) and FQuoteService.Active then
  begin

    eData := FQuoteService.GetEventData;
    if eData <> nil then
      try
        DoHandleEvent(eData);
      finally
        if (eData.Data <> nil) then
          FreeMemEx(eData.Data);
        if (eData^.SValue <> nil) then
          FreeMemEx(eData^.SValue);

        FreeMemEx(eData);
      end;
  end;
end;

procedure TQuoteManager.Connect(ServerType: ServerTypeEnum);
begin
  if FQuoteService <> nil then
    FQuoteService.Connect(ServerType);
end;

procedure TQuoteManager.Disconnect(ServerType: ServerTypeEnum);
begin
  if FQuoteService <> nil then
    FQuoteService.Disconnect(ServerType);
end;

function TQuoteManager.Get_Connected(ServerType: ServerTypeEnum): WordBool;
begin
  if FQuoteService <> nil then
    result := FQuoteService.Active and FQuoteService.Connected(ServerType)
  else
    result := false;
end;

procedure TQuoteManager.LevelSetting(const User, Pass: WideString);
begin
  if (FQuoteService <> nil) then
  begin
    FQuoteDataMngr.LevelUser := User;
    FQuoteDataMngr.LevelPass := Pass;
  end;
end;

procedure TQuoteManager.SendKeepActiveTime(ServerType: ServerTypeEnum);
begin
  if (FQuoteService <> nil) and FQuoteService.Active and Get_Connected(ServerType) then
  begin
    FQuoteService.SendKeepActiveCount(ServerType);
  end;
end;

function TQuoteManager.KeepActiveRecvTime(ServerType: ServerTypeEnum): Double;
begin
  // if (FQuoteService <> nil) and FQuoteService.Active and Get_Connected(ServerType)  then begin
  // result := FQuoteService.KeepActiveRecvTime(ServerType);
  // end else  result  := 0;
end;

procedure TQuoteManager.ConnectServerInfo(ServerType: ServerTypeEnum; var IP: WideString; var Port: word);
var
  _IP: string;
begin
  IP := '';
  Port := 0;
  if (FQuoteService <> nil) and FQuoteService.Active and Get_Connected(ServerType) then
  begin
    FQuoteService.ConnectServerInfo(ServerType, _IP, Port);
    IP := _IP;
  end;
end;

procedure TQuoteManager.SetWorkPath(const APath: WideString);
begin
  FQuoteDataMngr.AppPath := APath;
end;

initialization

TAutoObjectFactory.Create(ComServer, TQuoteManager, Class_QuoteManager, ciMultiInstance, tmApartment);

end.
