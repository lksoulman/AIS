unit ServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
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

  // GF ��������ӿ�
  TGFServiceImpl = class(TSyncAsyncImpl)
  private
  protected
    // �ļ�����
    FFile: string;
    // �ǲ����Ѿ���¼
    FIsLogin: Boolean;
    // ���ӷ�������ַ
    FServerUrl: string;
    // ����ʱ��
    FHeartBeatTime: Integer;
    // �����ȼ��̸߳���
    FHighThreadCount: Integer;
    // �����̸߳���
    FWorkThreadCount: Integer;
    // ���ýӿ�
    FConfig: IConfig;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // GF ����ӿ�
    FGFDataManager: IGFDataManager;
    // ���ݷ����¼�
    FGFDataMngrEvents: TGFDataMngrEvents;

    // ���ô���
    procedure DoSetProxy; virtual;
    // ���� GFDataManager
    procedure DoInitGFDataManager; virtual;
    // �ͷ� GFDataManager
    procedure DoUnInitGFDataManager; virtual;
    // GF ��� Debug ��־
    procedure DoWriteDebug(const AValue: AnsiString);
    // ��¼
    procedure DoUserLogin(AErrorCode: Integer; const AValue: AnsiString); virtual;
    // GF ��� Error ��־
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
        // WorkCount ��������  HighCount �����ȼ�
        FGFDataManager.ThreadCount(FWorkThreadCount, FHighThreadCount);
        // ���� GF �¼�
        FGFDataMngrEvents := TGFDataMngrEvents.Create(nil);
        FGFDataMngrEvents.OnWriteDebug := DoWriteDebug;
        FGFDataMngrEvents.OnWriteError := DoWriteError;
        FGFDataMngrEvents.OnUserLogin := DoUserLogin;
        FGFDataMngrEvents.ConnectTo(FGFDataManager);
        // ���� GF ����ʱ��
        FGFDataManager.HeartBeatSetting(FHeartBeatTime);
        // ����
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
