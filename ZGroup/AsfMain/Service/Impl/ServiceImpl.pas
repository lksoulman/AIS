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
  Config,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  SyncAsyncImpl,
  GFDataMngr_TLB,
  GFDataMngrEvents;

type

  // GF 基础服务接口
  TGFServiceImpl = class(TSyncAsyncImpl)
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
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;
  end;

implementation

uses
  Utils,
  DllComLib,
  ProxyInfo,
  FastLogLevel,
  AsfSdkExport;

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

procedure TGFServiceImpl.SyncBlockExecute;
begin

end;

procedure TGFServiceImpl.AsyncNoBlockExecute;
begin

end;

function TGFServiceImpl.Dependences: WideString;
begin

end;

procedure TGFServiceImpl.DoSetProxy;
begin
  if (FGFDataManager <> nil)
    and (FConfig.GetProxyInfo <> nil) then begin
    FGFDataManager.ProxySetting(FConfig.GetProxyInfo.GetProxyKindEnum, FConfig.GetProxyInfo.GetIP, FConfig.GetProxyInfo.GetPort,
      FConfig.GetProxyInfo.GetUserName, FConfig.GetProxyInfo.GetPassword, ''{LProxyInfo.NTLM}, FConfig.GetProxyInfo.GetDomain);
  end;
end;

procedure TGFServiceImpl.DoInitGFDataManager;
begin
  if FConfig <> nil then begin
    FFile := DLL_NAME;
    if FConfig.GetDllComLib <> nil then begin
      FGFDataManager := FConfig.GetDllComLib.CreateInterface(FFile, StringToGUID(GUID_GFDATAMANAGER)) as IGFDataManager;
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
        FastSysLog(llError, Format('[%s][DoInitGFDataManager] LDllComLib.CreateInterface FGFDataManager is nil.', [Self.ClassName]));
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
        FastSysLog(llError, Format('[%s][DoUnInitGFDataManager] FGFDataManager.StopService is exception, exception is %s.', [Self.ClassName, Ex.Message]));
      end;
    end;
  end;
end;

procedure TGFServiceImpl.DoWriteDebug(const AValue: AnsiString);
begin
  if FAppContext = nil then Exit;
  FastSysLog(llDEBUG, Format('[%s][DoWriteDebug] %s', [Self.ClassName, Utils.ReplaceEnterNewLine(AValue, ' ')]));
end;

procedure TGFServiceImpl.DoUserLogin(AErrorCode: Integer; const AValue: AnsiString);
begin

end;

procedure TGFServiceImpl.DoWriteError(const AUrl, ASql: AnsiString; ACode: Integer; const AValue: AnsiString);
begin
  if FAppContext = nil then Exit;
  FastSysLog(llERROR, Format('[%s][DoWriteError] Url(%s) Sql(%s) ErrorCode(%d) Value(%s)',[Self.ClassName, AUrl, Utils.ReplaceEnterNewLine(ASql, ' '), ACode, Utils.ReplaceEnterNewLine(AValue, ' ')]));
end;

end.
