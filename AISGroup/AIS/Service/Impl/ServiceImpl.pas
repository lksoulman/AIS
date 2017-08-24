unit ServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Config,
  SyncAsync,
  AppContext,
  GFDataMngr_TLB,
  GFDataMngrEvents;

type

  // GF 基础服务接口
  TGFServiceImpl = class(TInterfacedObject, ISyncAsync)
  private
  protected
    // 文件名称
    FFile: string;
    // 是不是已经登录
    FIsLogin: Boolean;
    // 连接服务器地址
    FServerUrl: string;
    // 心跳时间
    FHeartBeatTime: Integer;
    // 高优先级线程个数
    FHighThreadCount: Integer;
    // 工作线程个数
    FWorkThreadCount: Integer;
    // 配置接口
    FConfig: IConfig;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // GF 服务接口
    FGFDataManager: IGFDataManager;
    // 数据服务事件
    FGFDataMngrEvents: TGFDataMngrEvents;

    // 设置代理
    procedure DoSetProxy; virtual;
    // 创建 GFDataManager
    procedure DoInitGFDataManager; virtual;
    // 释放 GFDataManager
    procedure DoUnInitGFDataManager; virtual;
    // GF 输出 Debug 日志
    procedure DoWriteDebug(const AValue: AnsiString);
    // 登录
    procedure DoUserLogin(AErrorCode: Integer; const AValue: AnsiString); virtual;
    // GF 输出 Error 日志
    procedure DoWriteError(const AUrl, ASql: AnsiString; ACode: Integer; const AValue: AnsiString);
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ISyncAsync }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // 释放不需要的资源
    procedure UnInitialize; virtual; safecall;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; virtual; safecall;
    // 同步执行方法
    procedure SyncExecute; virtual; safecall;
    // 异步执行方法
    procedure AsyncExecute; virtual; safecall;
  end;

implementation

uses
  Utils,
  DllComLib,
  ProxyInfo,
  FastLogLevel;

const

  DLL_NAME = 'Services.dll';
  GUID_GFDATAMANAGER = '{440B8170-DAD9-4591-9F25-D73EB019BCF7}';

{ TGFServiceImpl }

constructor TGFServiceImpl.Create;
begin
  inherited;
  FIsLogin := False;
  FHeartBeatTime := 30000;
  FHighThreadCount := 1;
  FWorkThreadCount := 1;
end;

destructor TGFServiceImpl.Destroy;
begin

  inherited;
end;

procedure TGFServiceImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FConfig := FAppContext.GetConfig as IConfig;
  DoInitGFDataManager;
end;

procedure TGFServiceImpl.UnInitialize;
begin
  DoUnInitGFDataManager;
  FConfig := nil;
  FAppContext := nil;
end;

function TGFServiceImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TGFServiceImpl.SyncExecute;
begin

end;

procedure TGFServiceImpl.AsyncExecute;
begin

end;

procedure TGFServiceImpl.DoSetProxy;
var
  LProxyInfo: IProxyInfo;
begin
  LProxyInfo := FConfig.GetProxyInfo;
  if LProxyInfo <> nil then begin
    if FGFDataManager <> nil then begin
      FGFDataManager.ProxySetting(LProxyInfo.GetProxyKindEnum, LProxyInfo.GetIP, LProxyInfo.GetPort,
        LProxyInfo.GetUserName, LProxyInfo.GetPassword, ''{LProxyInfo.NTLM}, LProxyInfo.GetDomain);
    end;
  end;
end;

procedure TGFServiceImpl.DoInitGFDataManager;
var
  LDllComLib: TDllComLib;
begin
  if FConfig <> nil then begin
    FFile := DLL_NAME;
    LDllComLib := FConfig.GetDllComLib;
    if LDllComLib <> nil then begin
      FGFDataManager := LDllComLib.CreateInterface(FFile, StringToGUID(GUID_GFDATAMANAGER)) as IGFDataManager;
      if FGFDataManager <> nil then begin
        // WorkCount 正常程数  HighCount 高优先级
        FGFDataManager.ThreadCount(FWorkThreadCount, FHighThreadCount);
        // 设置 GF 事件
        FGFDataMngrEvents := TGFDataMngrEvents.Create(nil);
        FGFDataMngrEvents.OnWriteDebug := DoWriteDebug;
        FGFDataMngrEvents.OnWriteError := DoWriteError;
        FGFDataMngrEvents.OnUserLogin := DoUserLogin;
        FGFDataMngrEvents.ConnectTo(FGFDataManager);
        // 设置 GF 心跳时间
        FGFDataManager.HeartBeatSetting(FHeartBeatTime);
        // 启动
        FGFDataManager.StartService;
      end else begin
        FAppContext.AppLog(llError, Format('[%s][DoInitGFDataManager] LDllComLib.CreateInterface FGFDataManager is nil.', [Self.ClassName]));
      end;
    end;
  end;
end;

procedure TGFServiceImpl.DoUnInitGFDataManager;
begin
  if FGFDataManager <> nil then
  begin
    try
      FGFDataManager.StopService;
      FGFDataManager := nil;
    except
      on Ex: Exception do begin
        FAppContext.AppLog(llError, Format('[%s][DoUnInitGFDataManager] FGFDataManager.StopService is exception, exception is %s.', [Self.ClassName, Ex.Message]));
      end;
    end;
  end;
end;

procedure TGFServiceImpl.DoWriteDebug(const AValue: AnsiString);
begin
  if FAppContext = nil then Exit;
  FAppContext.AppLog(llDEBUG, Format('[%s][DoWriteDebug] %s', [Self.ClassName, Utils.ReplaceEnterNewLine(AValue, ' ')]));
end;

procedure TGFServiceImpl.DoUserLogin(AErrorCode: Integer; const AValue: AnsiString);
begin

end;

procedure TGFServiceImpl.DoWriteError(const AUrl, ASql: AnsiString; ACode: Integer; const AValue: AnsiString);
begin
  if FAppContext = nil then Exit;
  FAppContext.AppLog(llERROR, Format('[%s][DoWriteError] Url(%s) Sql(%s) ErrorCode(%d) Value(%s)',[Self.ClassName, AUrl, Utils.ReplaceEnterNewLine(ASql, ' '), ACode, Utils.ReplaceEnterNewLine(AValue, ' ')]));
end;

end.
