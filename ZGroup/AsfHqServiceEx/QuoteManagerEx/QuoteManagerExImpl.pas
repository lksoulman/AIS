unit QuoteManagerExImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-27
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  ComObj,
  ActiveX,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonLock,
  QuoteMngr_TLB,
  SyncAsyncImpl,
  QuoteManagerEx,
  ExecutorThread,
  QuoteCodeInfosEx,
  CommonRefCounter,
//  HqServerTypeInfo,
  QuoteManagerEvents,
  Generics.Collections;

type

  // 行情接口
  TQuoteManagerExImpl = class(TSyncAsyncImpl, IQuoteManagerEx)
  private
    // 线程共享锁
    FLock: TCSLock;
     // 是不是激活
    FActive: Boolean;
    // Com 库接口
    FTypeLib: ITypeLib;
    // 是不是有港股实时权限
    FIsHasHKReal: Boolean;
    // 是不是有 LevelII 权限
    FIsHasLevelII: Boolean;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 行情管理接口
    FQuoteManager: IQuoteManager;
    // 实时接口
    FQuoteRealTime: IQuoteRealTime;
    // 服务器类型个数
    FServerTypes: TServerTypeEnumDynArray;
    // 行情服务器类型信息
//    FHqServerTypeInfo: IHqServerTypeInfo;
    // 监控服务器连接线程
    FMonitorServerThread: TExecutorThread;
    // 行情事件
    FQuoteManagerEvent: TQuoteManagerEvents;
  protected
    // 设置代理
    procedure DoSetProxy;
    // 初始化Lib
    procedure DoInitTypeLib;
    // 初始化行情管理接口
    procedure DoInitQuoteManager;
    // 释放行情管理接口
    procedure DoUnInitQuoteManager;
    // 初始化连接所有服务器
    procedure DoInitConnectServers;
    // 连接所有服务器
    procedure DoConnectServers;
    // 断开所有服务器连接
    procedure DoDisConnectServers;
    // 初始化监控线程
    procedure DoInitMonitorThread;
    // 停止监控线程
    procedure DoUnInitMonitorThread;
    // 通过概念指数名称建立内码和订阅的代码的对应关系
    procedure DoUpdateConceptCodes(Sender: TObject);
    // 写日志信息
    procedure DoWriteLog(const ALog: WideString);
    //
    procedure DoProgress(const AMsg: WideString; AMax, AValue: Integer);
    // 当连接上时
    procedure DoConnected(const AIP: WideString; APort: Word; AServerType: ServerTypeEnum);
    // 当断开连接时
    procedure DoDisconnected(const AIP: WideString; APort: Word; AServerType: ServerTypeEnum);
    // 监控服务器连接线程执行方法
    procedure DoMonitorServerThreadExecute(AObject: TObject);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize Resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing Resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Dependency Interface
    function Dependences: WideString; override;

    { IQuoteManagerEx }

    // 获取是不是激活
    function GetActive: WordBool; safecall;
    // 获取
    function GetTypeLib: ITypeLib; safecall;
    // 获取是不是港股实时
    function GetIsHKReal: Boolean; safecall;
    // 获取是不是 Level2
    function GetIsLevel2(AInnerCode: Integer): Boolean; safecall;
    // 连接消息客户端
    procedure ConnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    // 取消消息客户端的连接
    procedure DisconnectMessage(const QuoteMessage: IQuoteMessage); safecall;
    // 获取行情服务器类型对应的名称
    function GetServerTypeName(AServerType: ServerTypeEnum): WideString; safecall;
    // 获取行情服务器连接状态
    function GetServerTypeConnected(AServerTypes: TServerTypeEnumDynArray): WordBool; safecall;
    // 获取 InnerCode 对应的 CodeInfo
    function GetCodeInfoByInnerCode(AInnerCode: Int64; APCodeInfo: Int64): Boolean; safecall;
    // 获取 InnerCodes 对应的 CodeInfos
    function GetCodeInfosByInnerCodes(AInnerCodes: Int64; ACount: Integer): IQuoteCodeInfosEx; safecall;
    // CodeInfo 转 InnerCode
    procedure CodeInfo2InnerCode(ACodeInfos: Int64; Count: Integer; AInnerCodes: Int64); safecall;
    // 获取行情数据
    function QueryData(AQuoteType: QuoteTypeEnum; APCodeInfo: Int64): IUnknown; safecall;
    // 订阅数据
    function Subscribe(AQuoteType: QuoteTypeEnum; APCodeInfos: Int64; ACount: Integer; ACookie: Integer; AValue: OleVariant): WordBool; safecall;
  end;

implementation

uses
  Cfg,
  Forms,
  Manager,
  LogLevel,
  ProxyInfo,
  QuoteConst,
  QuoteStruct,
  QuoteCodeInfosExImpl;

{ TQuoteManagerExImpl }

constructor TQuoteManagerExImpl.Create;
begin
  inherited;
  FActive := False;
  FLock := TCSLock.Create;
  FMonitorServerThread := TExecutorThread.Create;
  FMonitorServerThread.ThreadMethod := DoMonitorServerThreadExecute;
end;

destructor TQuoteManagerExImpl.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TQuoteManagerExImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
//  FPermissionMgr := FAppContext.GetPermissionMgr as IPermissionMgr;
//  if FPermissionMgr <> nil then begin
//    FIsHasHKReal := FPermissionMgr.IsHasHKReal;
//    FIsHasLevelII := FPermissionMgr.IsHasLevelII;
//  end else begin
//    FIsHasHKReal := False;
//    FIsHasLevelII := False;
//  end;
//  if FAppContext.GetSecurityMgr <> nil then begin
//    FSecurityHqAdapter := FAppContext.GetSecurityMgr as ISecurityHqAdapter;
//  end;
  DoInitConnectServers;
  DoInitQuoteManager;
  DoConnectServers;
  DoInitMonitorThread;
  FActive := True;
end;

procedure TQuoteManagerExImpl.UnInitialize;
begin
  if FMonitorServerThread.IsStart then begin
    FMonitorServerThread.ShutDown;
  end;
  DoUnInitMonitorThread;
  DoDisConnectServers;
  DoUnInitQuoteManager;
  FAppContext := nil;
end;

procedure TQuoteManagerExImpl.SyncBlockExecute;
begin
  FMonitorServerThread.StartEx;
end;

procedure TQuoteManagerExImpl.AsyncNoBlockExecute;
begin

end;

function TQuoteManagerExImpl.Dependences: WideString;
begin
  Result := '';
end;

function TQuoteManagerExImpl.GetActive: WordBool;
begin
  Result := True;
end;

function TQuoteManagerExImpl.GetTypeLib: ITypeLib;
begin
  Result := FTypeLib;
end;

function TQuoteManagerExImpl.GetIsHKReal: Boolean;
begin
  Result := False;
//  if FPermissionMgr <> nil then begin
//    Result := FPermissionMgr.IsHasHKReal;
//  end;
end;

function TQuoteManagerExImpl.GetIsLevel2(AInnerCode: Integer): Boolean;
var
  LCodeInfo: TCodeInfo;
begin
  Result := False;
//  if FPermissionMgr <> nil then begin
//    Result := FPermissionMgr.IsHasLevelII;
//    if Result then begin
//      if GetCodeInfoByInnerCode(Int64(@AInnerCode), Int64(@LCodeInfo)) then begin
//        Result := HSMarketBourseType(LCodeInfo.m_cCodeType, STOCK_MARKET, SH_BOURSE)
//          or HSMarketBourseType(LCodeInfo.m_cCodeType, STOCK_MARKET, SZ_BOURSE);
//      end;
//    end;
//  end;
end;

procedure TQuoteManagerExImpl.ConnectMessage(const QuoteMessage: IQuoteMessage);
begin
  FQuoteManager.ConnectMessage(QuoteMessage);
end;

procedure TQuoteManagerExImpl.DisconnectMessage(const QuoteMessage: IQuoteMessage);
begin
  FQuoteManager.DisconnectMessage(QuoteMessage);
end;

function TQuoteManagerExImpl.GetServerTypeName(AServerType: ServerTypeEnum): WideString;
begin
  Result := '';
//  if FHqServerTypeInfo <> nil then begin
//    Result := FHqServerTypeInfo.GetHqServerTypeNameByEnum(AServerType);
//  end;
end;

function TQuoteManagerExImpl.GetServerTypeConnected(AServerTypes: TServerTypeEnumDynArray): WordBool; safecall;
var
  LCount: Integer;
begin
  Result := True;
  LCount := Length(FServerTypes);
  SetLength(AServerTypes, LCount);
  CopyMemory(@AServerTypes[0], @FServerTypes[0], LCount);
end;

function TQuoteManagerExImpl.GetCodeInfoByInnerCode(AInnerCode: Int64; APCodeInfo: Int64): Boolean;
var
  LTmp: Int64;
  LCodeInfoStr: string;
  LPCodeInfo: PCodeInfo;
begin
  Result := False;
  if APCodeInfo = 0 then Exit;

//  if FSecurityHqAdapter <> nil then begin
//    LTmp := 0;
//    FillMemory(PCodeInfo(APCodeInfo), SizeOf(TCodeInfo), 0);
//    LCodeInfoStr := FSecurityHqAdapter.GetCodeInfoStr(AInnerCode);
//    if LCodeInfoStr <> '' then begin
//      FQuoteRealTime.GetCodeInfoByKeyStr(LCodeInfoStr, LTmp);
//      LPCodeInfo := PCodeInfo(LTmp);
//      if LPCodeInfo <> nil then begin
//        PCodeInfo(APCodeInfo)^ := LPCodeInfo^;
//        Result := True;
//      end;
//    end;
//  end;
end;

function TQuoteManagerExImpl.GetCodeInfosByInnerCodes(AInnerCodes: Int64; ACount: Integer): IQuoteCodeInfosEx;
var
  LTmp: Int64;
  LIndex: Integer;
  LCodeInfoStr: string;
  LPCodeInfo: PCodeInfo;
  LPInnerCode: PInteger;
  LQuoteCodeInfosExImpl: TQuoteCodeInfosExImpl;
begin
  LQuoteCodeInfosExImpl := TQuoteCodeInfosExImpl.Create;
  LQuoteCodeInfosExImpl.SetCapacity(ACount);
//  if FSecurityHqAdapter <> nil then begin
//    LPInnerCode := PInteger(AInnerCodes);
//    for LIndex := 0 to ACount - 1 do begin
//      LPCodeInfo := nil;
//      LCodeInfoStr := FSecurityHqAdapter.GetCodeInfoStr(LPInnerCode^);
//      if LCodeInfoStr <> '' then begin
//        FQuoteRealTime.GetCodeInfoByKeyStr(LCodeInfoStr, LTmp);
//        LPCodeInfo := PCodeInfo(LTmp);
//        if LPCodeInfo <> nil then begin
//          LQuoteCodeInfosExImpl.Add(LPInnerCode^, LPCodeInfo);
//        end;
//      end;
//      Inc(LPInnerCode);
//    end;
//  end;
  Result := LQuoteCodeInfosExImpl as IQuoteCodeInfosEx;
end;

procedure TQuoteManagerExImpl.CodeInfo2InnerCode(ACodeInfos: Int64; Count: Integer; AInnerCodes: Int64);
var
  LIndex: Integer;
  LPInnerCode: PInteger;
  LPCodeInfo: PCodeInfo;
begin
  LPInnerCode := PInteger(AInnerCodes);
  LPCodeInfo := PCodeInfo(ACodeInfos);
  for LIndex := 0 to Count - 1 do begin
//    LPInnerCode^ := FSecurityHqAdapter.GetInnerCode(CodeInfoKey(LPCodeInfo));
//    Inc(LPInnerCode);
//    Inc(LPCodeInfo);
  end;
end;

function TQuoteManagerExImpl.QueryData(AQuoteType: QuoteTypeEnum; APCodeInfo: Int64): IUnknown;
begin
  Result := FQuoteManager.QueryData(AQuoteType, APCodeInfo);
end;

function TQuoteManagerExImpl.Subscribe(AQuoteType: QuoteTypeEnum; APCodeInfos: Int64; ACount: Integer; ACookie: Integer; AValue: OleVariant): WordBool;
begin
  Result := FQuoteManager.Subscribe(AQuoteType, APCodeInfos, ACount, ACookie, AValue);
end;

procedure TQuoteManagerExImpl.DoSetProxy;
begin
  if FAppContext.GetCfg <> nil then begin
//    if (FAppContext.GetConfig as IConfig).GetProxyInfo.GetUse then begin
//      FQuoteManager.Proxy1Setting((FAppContext.GetConfig as IConfig).GetProxyInfo.GetProxyKindEnum,
//                                (FAppContext.GetConfig as IConfig).GetProxyInfo.GetIP,
//                                (FAppContext.GetConfig as IConfig).GetProxyInfo.GetPort,
//                                (FAppContext.GetConfig as IConfig).GetProxyInfo.GetUserName,
//                                (FAppContext.GetConfig as IConfig).GetProxyInfo.GetPassword);
//    end;
  end;
end;

procedure TQuoteManagerExImpl.DoInitTypeLib;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LModule: HMODULE;
  LFileName: string;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  LModule := HInstance;
  SetLength(LFileName, MAX_PATH);
  GetModuleFileName(LModule, PChar(LFileName), MAX_PATH);
  try
    OLEcheck(LoadTypeLibEx(PChar(LFileName), REGKIND_NONE, FTypeLib));
  except
    on Ex: Exception do begin
//      FastSysLog(llError, Format('[TQuoteManagerExImpl][DoInitTypeLib] Load data is exception, exception is %s.', [Ex.Message]));
    end;
  end;

{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
//  FastHQLog(llSLOW, Format('[TQuoteManagerExImpl][DoInitTypeLib] Execute use time is %d ms.', [LTick]), LTick);
{$ENDIF}
end;

procedure TQuoteManagerExImpl.DoInitQuoteManager;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FQuoteManager := TQuoteManager.Create;
//    FQuoteManager.SetWorkPath((FAppContext.GetConfig as IConfig).GetCacheHQPath);
    FQuoteManagerEvent := TQuoteManagerEvents.Create(nil);
    FQuoteManagerEvent.ConnectTo(FQuoteManager);
    FQuoteManagerEvent.OnConnected := DoConnected;
    FQuoteManagerEvent.OnDisconnected := DoDisconnected;
    FQuoteManagerEvent.OnWriteLog := DoWriteLog;
    FQuoteManagerEvent.OnProgress := DoProgress;
    FQuoteManager.ClearSetting;
    FQuoteManager.ConcurrentSetting(1);
    DoSetProxy;
    FQuoteManager.StartService;

    FQuoteRealTime := FQuoteManager.QueryData(QuoteType_REALTIME, 0) as IQuoteRealTime;
    FQuoteRealTime.OnUpdateConceptCodes := DoUpdateConceptCodes;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
//    FastHQLog(llSLOW, Format('[TQuoteManagerExImpl][DoInitQuoteManager] Execute use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TQuoteManagerExImpl.DoUnInitQuoteManager;
begin
  if FQuoteManagerEvent <> nil then begin
    FQuoteManagerEvent.DisConnect;
    FQuoteManagerEvent.Free;
    FQuoteManagerEvent := nil;
  end;
  if FQuoteManager <> nil then begin
    FQuoteManager.StopService;
    FQuoteManager := nil;
  end;
end;

procedure TQuoteManagerExImpl.DoInitConnectServers;
var
  LPort: Word;
  LServer, LIP: string;
  LStringList: TStringList;
  LIndex, LServerIndex, LPos, LCount: Integer;
//  LHqServerTypeItem: PHqServerTypeItem;
begin
//  if FHqServerTypeInfo = nil then Exit;
//
//  LStringList := TStringList.Create;
//  try
//    LCount := 0;
//    SetLength(FServerTypes, FHqServerTypeInfo.GetHqServerTypeItemCount);
//    for LIndex := 0 to FHqServerTypeInfo.GetHqServerTypeItemCount - 1 do begin
//      LHqServerTypeItem := FHqServerTypeInfo.GetHqServerTypeItem(LIndex);
//      if LHqServerTypeItem <> nil then begin
//        case LHqServerTypeItem.FTypeEnum of
//          stStockLevelI:
//            LHqServerTypeItem.FIsUsed := not FIsHasLevelII;
//          stStockLevelII:
//            LHqServerTypeItem.FIsUsed := FIsHasLevelII;
//          stHKDelay:
//            LHqServerTypeItem.FIsUsed := not FIsHasHKReal;
//          stStockHK:
//            LHqServerTypeItem.FIsUsed := FIsHasHKReal;
//        end;
//        LHqServerTypeItem.FLastHeartBeatTime := 0;
//        LHqServerTypeItem.FServers := (FAppContext.GetConfig as IConfig).GetServers(LHqServerTypeItem.FName);
//
//        LStringList.DelimitedText := LHqServerTypeItem.FServers;
//        for LServerIndex := 0 to LStringList.Count - 1 do begin
//          LServer := Trim(LStringList.Strings[LServerIndex]);
//          LPos := Pos(':', LServer);
//          if LPos >= 1 then begin
//            LIP := Trim(Copy(LServer, 1, LPos - 1));
//            LPort := StrToIntDef(trim(Copy(LServer, LPos + 1, 16)), 0);
//            FQuoteManager.ServerSetting(LIP, LPort, LHqServerTypeItem.FTypeEnum);
//          end;
//        end;
//
//        if LHqServerTypeItem.FIsUsed then begin
//          FServerTypes[LCount] := LHqServerTypeItem.FTypeEnum;
//          Inc(LCount);
//        end;
//      end;
//    end;
//    SetLength(FServerTypes, LCount);
//  finally
//    LStringList.Free;
//  end;
end;

procedure TQuoteManagerExImpl.DoConnectServers;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LIndex, LIntervalTick: Integer;
//  LHqServerTypeItem: PHqServerTypeItem;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}
//    if FHqServerTypeInfo = nil then Exit;

//    FHqServerTypeInfo.Lock;
//    try
//       for LIndex := 0 to FHqServerTypeInfo.GetHqServerTypeItemCount - 1 do begin
//        LHqServerTypeItem := FHqServerTypeInfo.GetHqServerTypeItem(LIndex);
//        if (LHqServerTypeItem <> nil)
//          and LHqServerTypeItem.FIsUsed then begin
//
//          // 连接断开的直接重连
//          if LHqServerTypeItem.FServerStatus = ssDisConnected then begin
//            FQuoteManager.Connect(LHqServerTypeItem.FTypeEnum);
//            LHqServerTypeItem.FServerStatus := ssConnecting;
//            LHqServerTypeItem.FLastHeartBeatTime := GetTickCount;
//          end else if (LHqServerTypeItem.FServerStatus = ssConnecting) then begin
//            LIntervalTick := GetTickCount - LHqServerTypeItem.FLastHeartBeatTime;
//            if LIntervalTick > 10000 then begin         // 10秒检测一下正在连接是不是超时
//              FQuoteManager.Connect(LHqServerTypeItem.FTypeEnum);
//            end;
//          end else if LHqServerTypeItem.FServerStatus = ssInit then begin
//            FQuoteManager.Connect(LHqServerTypeItem.FTypeEnum);
//            LHqServerTypeItem.FServerStatus := ssConnecting;
//            LHqServerTypeItem.FLastHeartBeatTime := GetTickCount;
//            FastHQLog(llWARN, Format('[TQuoteManagerExImpl][DoConnectServers] [%s] HqServer Init Connecting.', [LHqServerTypeItem.FName]));
//          end else begin
//            LIntervalTick := GetTickCount - LHqServerTypeItem.FLastHeartBeatTime;
//            if LIntervalTick > 90000 then begin        // 一分半钟发一次心跳
//              if FQuoteManager.Connected[LHqServerTypeItem.FTypeEnum] then begin
//                FQuoteManager.SendKeepActiveTime(LHqServerTypeItem.FTypeEnum);
//                FQuoteManager.Connect(LHqServerTypeItem.FTypeEnum);
//                LHqServerTypeItem.FLastHeartBeatTime := GetTickCount;
//              end;
//            end;
//          end;
//        end;
//      end;
//    finally
//      FHqServerTypeInfo.UnLock;
//    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
//    FastHQLog(llSLOW, Format('[TQuoteManagerExImpl][DoConnectServers] Execute use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TQuoteManagerExImpl.DoDisConnectServers;
var
  LIndex: Integer;
//  LHqServerTypeItem: PHqServerTypeItem;
begin
//  try
//    for LIndex := 0 to FHqServerTypeInfo.GetHqServerTypeItemCount - 1 do begin
//      LHqServerTypeItem := FHqServerTypeInfo.GetHqServerTypeItem(LIndex);
//      if (LHqServerTypeItem <> nil)
//        and LHqServerTypeItem.FIsUsed
//        and (LHqServerTypeItem.FServerStatus in [ssConnecting, ssConnected]) then begin
//        FQuoteManager.Disconnect(LHqServerTypeItem.FTypeEnum);
//      end;
//    end;
//  finally
//    FHqServerTypeInfo.UnLock;
//  end;
end;

procedure TQuoteManagerExImpl.DoInitMonitorThread;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  FMonitorServerThread.StartEx;

{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
//  FastHQLog(llSLOW, Format('[TQuoteManagerExImpl][DoConnectServers] Execute use time is %d ms.', [LTick]), LTick);
{$ENDIF}
end;

procedure TQuoteManagerExImpl.DoUnInitMonitorThread;
begin
  FMonitorServerThread.ShutDown;
end;

procedure TQuoteManagerExImpl.DoUpdateConceptCodes(Sender: TObject);
begin

end;

procedure TQuoteManagerExImpl.DoWriteLog(const ALog: WideString);
begin
//  FastHQLog(llWARN, Format('[TQuoteManagerExImpl][DoWriteLog] [%s] HqServer Connected.',[ALog]));
end;

procedure TQuoteManagerExImpl.DoProgress(const AMsg: WideString; AMax, AValue: Integer);
begin
//  FastHQLog(llWARN, Format('[TQuoteManagerExImpl][DoProgress] [%s][%d][%d] .',[AMsg, AMax, AValue]));
end;

procedure TQuoteManagerExImpl.DoConnected(const AIP: WideString; APort: Word; AServerType: ServerTypeEnum);
var
  LServerName: string;
//  LHqServerTypeItem: PHqServerTypeItem;
begin
//  FHqServerTypeInfo.Lock;
//  try
//    LHqServerTypeItem := FHqServerTypeInfo.GetHqServerTypeItemByEnum(AServerType);
//    if LHqServerTypeItem <> nil then begin
//      LServerName := LHqServerTypeItem.FName;
//      LHqServerTypeItem.FServerStatus := ssConnected;
//    end else begin
//      LServerName := '';
//    end;
//  finally
//    FHqServerTypeInfo.UnLock;
//  end;
//  FastHQLog(llWARN, Format('[TQuoteManagerExImpl][DoConnected] [%s][%s][%d] HqServer Connected.',[LServerName, AIP, APort]));
end;

procedure TQuoteManagerExImpl.DoDisconnected(const AIP: WideString; APort: Word; AServerType: ServerTypeEnum);
var
  LServerName: string;
//  LHqServerTypeItem: PHqServerTypeItem;
begin
//  FHqServerTypeInfo.Lock;
//  try
//    LHqServerTypeItem := FHqServerTypeInfo.GetHqServerTypeItemByEnum(AServerType);
//    if LHqServerTypeItem <> nil then begin
//      LServerName := LHqServerTypeItem.FName;
//      LHqServerTypeItem.FServerStatus := ssDisConnected;
//    end else begin
//      LServerName := '';
//    end;
//  finally
//    FHqServerTypeInfo.UnLock;
//  end;
//  FastHQLog(llWARN, Format('[TQuoteManagerExImpl][DoDisconnected] [%s][%s][%d] HqServer DisConnected.',[LServerName, AIP, APort]));
end;

procedure TQuoteManagerExImpl.DoMonitorServerThreadExecute(AObject: TObject);
var
  LThread: TExecutorThread;
begin
  LThread := TExecutorThread(AObject);
  while not LThread.IsTerminated do begin
    // 线程 500ms 轮询检查连接
    Sleep(500);
    if LThread.IsTerminated then Exit;
//    Application.ProcessMessages;
    DoConnectServers;
  end;
end;

end.
