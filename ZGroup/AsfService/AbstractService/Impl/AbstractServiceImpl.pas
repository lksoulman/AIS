unit AbstractServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Abstract Service Interface implementation
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  GFData,
  Windows,
  Classes,
  SysUtils,
  WaitMode,
  ShareMgr,
  Executors,
  GFDataImpl,
  AppContext,
  HttpContext,
  GFDataUpdate,
  SyncAsyncImpl,
  ExecutorThread,
  HttpContextPool;

type

  // Abstract Service Interface Implementation
  TAbstractServiceImpl = class(TSyncAsyncImpl)
  private
  protected
    // Server Url
    FServerUrl: string;
    // Init Logined
    FInitLogined: Boolean;
    // Executor Count
    FExecutorCount: Integer;
    // Priority Executor Count
    FPriorityExecutorCount: Integer;
    // Heart Beat Time
    FHeartBeatInterval: Cardinal;
    // Last Heart Beat Time
    FLastHeartBeatTick: Cardinal;

    // Share Manager
    FShareMgr: IShareMgr;
    // Handler Executors
    FExecutors: TExecutors;
    // Priority Handler Executors
    FPriorityExecutors: TExecutors;
    // Keep Alive Heart Beat Thread
    FKeepAliveHeartBeatThread: TExecutorThread;

    // Keep Alive Heart Beat
    procedure DoKeepAliveHeartBeat; virtual;
    // Call back Keep Alive Heart Beat GFData
    procedure DoKeepAliveHeartBeatGFData(AGFData: IGFData); virtual;
    // Heart Beat Thread Execute
    procedure DoKeepAliveHeartBeatThreadExecute(AObject: TObject); virtual;

    // Create GFData
    function DoCreateGFData: IGFData;
    // No Login Default Post
    function DoNoLoginDefaultPost(AGFData: IGFData): Boolean;
    // Synchronous Post
    function DoSyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
    // Asynchronous Post
    function DoAsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
    // Priority Synchronous Post
    function DoPrioritySyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
    // Priority Asynchronous Post
    function DoPriorityAsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
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
  end;

implementation

uses
  Vcl.Forms,
  LogLevel,
  GFDataSet,
  ErrorCode,
  ShareMgrImpl;

{ TAbstractServiceImpl }

constructor TAbstractServiceImpl.Create;
begin
  inherited;
  FInitLogined := False;
  FExecutorCount := 6;
  FPriorityExecutorCount := 2;
  FLastHeartBeatTick := 0;
  FHeartBeatInterval := 1000 * 60 * 10;
  FShareMgr := TShareMgrImpl.Create as IShareMgr;
  FExecutors := TExecutors.Create(FShareMgr);
  FPriorityExecutors := TExecutors.Create(FShareMgr);
  FKeepAliveHeartBeatThread := TExecutorThread.Create;
  FKeepAliveHeartBeatThread.ThreadMethod := DoKeepAliveHeartBeatThreadExecute;
end;

destructor TAbstractServiceImpl.Destroy;
begin
//  FKeepAliveHeartBeatThread.Free;
  FPriorityExecutors.Free;
  FExecutors.Free;
  FShareMgr := nil;
  inherited;
end;

procedure TAbstractServiceImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  FShareMgr.Initialize(AContext);
end;

procedure TAbstractServiceImpl.UnInitialize;
begin
  FKeepAliveHeartBeatThread.ShutDown;
  FPriorityExecutors.ShutDown;
  FExecutors.ShutDown;
  FShareMgr.UnInitialize;
  inherited UnInitialize;
end;

procedure TAbstractServiceImpl.SyncBlockExecute;
begin
  FExecutors.SetFixedThread(FExecutorCount);
  FPriorityExecutors.SetFixedThread(FPriorityExecutorCount);
  FExecutors.Start;
  FPriorityExecutors.Start;
  FKeepAliveHeartBeatThread.StartEx;
end;

procedure TAbstractServiceImpl.AsyncNoBlockExecute;
begin

end;

function TAbstractServiceImpl.Dependences: WideString;
begin
  Result := '';
end;

procedure TAbstractServiceImpl.DoKeepAliveHeartBeat;
var
  LIndicator: string;
begin
  LIndicator := Format('UPDATE_SESSION_EXPIRE("%s", "pc")', [FShareMgr.GetHardDiskIdMD5]);
  DoAsyncPost(LIndicator, DoKeepAliveHeartBeatGFData, 0);
end;

procedure TAbstractServiceImpl.DoKeepAliveHeartBeatGFData(AGFData: IGFData);
begin
  FLastHeartBeatTick := GetTickCount;
  if FAppContext <> nil then begin
    FAppContext.SysLog(llDEBUG, Format('[%s][DoKeepAliveHeartBeatThreadExecute] Update LastHeartBeatTick %d', [Self.ClassName, FLastHeartBeatTick]));
  end;
end;

procedure TAbstractServiceImpl.DoKeepAliveHeartBeatThreadExecute(AObject: TObject);
var
  LResult: Cardinal;
  LTick, LInterval: Cardinal;
begin
  while not FKeepAliveHeartBeatThread.IsTerminated do begin
    Application.ProcessMessages;

    LResult := FKeepAliveHeartBeatThread.WaitForEx(3000);
    case LResult of
      WAIT_TIMEOUT:
        begin
          if FKeepAliveHeartBeatThread.IsTerminated then Exit;

          if FShareMgr.GetIsLogined then begin
            LTick := GetTickCount;
            LInterval := LTick - FLastHeartBeatTick;
            if LInterval > FHeartBeatInterval  then begin
              DoKeepAliveHeartBeat;
              if FAppContext <> nil then begin
                FAppContext.SysLog(llDEBUG, Format('[%s][DoKeepAliveHeartBeatThreadExecute] DoKeepAliveHeartBeat %d', [Self.ClassName, LTick]));
              end;
            end;
          end;
        end;
    end;
  end;
end;

function TAbstractServiceImpl.DoCreateGFData: IGFData;
begin
  Result := TGFDataImpl.Create as IGFData;
end;

function TAbstractServiceImpl.DoNoLoginDefaultPost(AGFData: IGFData): Boolean;
begin
  Result := True;
  if FInitLogined then begin
    (AGFData as IGFDataUpdate).SetErrorCode(ErrorCode_Service_Response_NoLogin);
  end else begin
    (AGFData as IGFDataUpdate).SetErrorCode(ErrorCode_Service_Response_Need_ReLogin);
  end;
end;

function TAbstractServiceImpl.DoSyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
var
  LContext: THttpContext;
begin
  Result := DoCreateGFData;
  LContext := THttpContext(FShareMgr.GetHttpContextPool.Allocate);
  if LContext <> nil then begin
    LContext.WaitMode := wmBlocking;
    LContext.Indicator := AIndicator;
    LContext.GFDataUpdate := Result as IGFDataUpdate;
    FExecutors.Submit(LContext);
    LContext.SetWaitStart(AWaitTime);
    FShareMgr.GetHttpContextPool.DeAllocate(LContext);
  end;
end;

function TAbstractServiceImpl.DoAsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
var
  LContext: THttpContext;
begin
  Result := DoCreateGFData;
  LContext := THttpContext(FShareMgr.GetHttpContextPool.Allocate);
  if LContext <> nil then begin
    LContext.DataEvent := AEvent;
    LContext.WaitMode := wmNoBlocking;
    LContext.Indicator := AIndicator;
    LContext.GFDataUpdate := Result as IGFDataUpdate;
    LContext.GFDataUpdate.SetKey(AKey);
    FExecutors.Submit(LContext);
  end;
end;

function TAbstractServiceImpl.DoPrioritySyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
var
  LContext: THttpContext;
begin
  Result := DoCreateGFData;
  LContext := THttpContext(FShareMgr.GetHttpContextPool.Allocate);
  if LContext <> nil then begin
    LContext.WaitMode := wmBlocking;
    LContext.Indicator := AIndicator;
    LContext.GFDataUpdate := Result as IGFDataUpdate;
    FPriorityExecutors.Submit(LContext);
    LContext.SetWaitStart(AWaitTime);
    FShareMgr.GetHttpContextPool.DeAllocate(LContext);
  end;
end;

function TAbstractServiceImpl.DoPriorityAsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
var
  LContext: THttpContext;
begin
  Result := DoCreateGFData;
  LContext := THttpContext(FShareMgr.GetHttpContextPool.Allocate);
  if LContext <> nil then begin
    LContext.DataEvent := AEvent;
    LContext.WaitMode := wmNoBlocking;
    LContext.Indicator := AIndicator;
    LContext.GFDataUpdate := Result as IGFDataUpdate;
    LContext.GFDataUpdate.SetKey(AKey);
    FPriorityExecutors.Submit(LContext);
  end;
end;

end.
