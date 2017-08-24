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
  Windows,
  Classes,
  SysUtils,
  Config,
  SyncAsync,
  AppContext,
  GFDataMngr_TLB,
  GFDataMngrEvents;

type

  // GF ��������ӿ�
  TGFServiceImpl = class(TInterfacedObject, ISyncAsync)
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
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISyncAsync }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; virtual; safecall;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; virtual; safecall;
    // ͬ��ִ�з���
    procedure SyncExecute; virtual; safecall;
    // �첽ִ�з���
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
