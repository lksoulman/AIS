unit Executors;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executors
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  WaitMode,
  ShareMgr,
  CommonQueue,
  ExecutorThread,
  CommonRefCounter,
  Generics.Collections;

type

  // Executors
  TExecutors = class(TAutoObject)
  private
    // Is Start
    FIsStart: Boolean;
    // Is Shutdown
    FIsShutDown: Boolean;
    // Windows Handle
    FWindowHandle: THandle;
    // Share Manager
    FShareMgr: IShareMgr;
    // Work Thread Count
    FWorkerThreadCount: Integer;
    // Moniter Thread
    FMonitorThread: TExecutorThread;
    // Work Threads
    FWorkerThreads: TList<TExecutorThread>;
    // Submit Handler Queue
    FSubmitQueue: TSafeSemaphoreQueue<TObject>;
    // Finish Handler Queue
    FFinishQueue: TSafeSemaphoreQueue<TObject>;
  protected
    // Clean Queue
    procedure DoCleanQueue(AQueue: TSafeSemaphoreQueue<TObject>);
    // Init Windows Message
    procedure DoInitWindowMessage;
    // Un Init Windows Message
    procedure DoUnInitWindowMessage;
    // Start
    procedure DoStart;
    // Shutdown
    procedure DoShutDown;
    // Is All Thread Terminated
    function DoIsTerminated: Boolean;
    // Submit Task
    function DoSubmit(AObject: TObject): Boolean;
    // Create Executor
    function DoCreateExecutor: TExecutorThread;
    // Shutdown Thread
    procedure DoShutDownThread;
    // Start ACount Thread
    procedure DoStartThread(ACount: Integer);
    // Task Execute
    procedure DoTaskExecute(AObject: TObject);
    // Task Moniter
    procedure DoTaskMonitor(AObject: TObject);
    // Message Proc
    procedure DoWndProc(var Message: TMessage);
    // Post Message
    procedure DoPostMessage(AMSG: Cardinal; AWParam, ALParam: Integer);
  public
    // Constructor
    constructor Create(AShareMgr: IShareMgr); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Start
    procedure Start;
    // Shutdown
    procedure ShutDown;
    // Is Terminated
    function IsTerminated: boolean;
    // Set Fixed Thread Count
    procedure SetFixedThread(ACount: Integer);
    // Submit Task
    function Submit(AObject: TObject): Boolean;
  end;

implementation

uses
  GFData,
  LogLevel,
  ErrorCode,
  HttpContext,
  HttpExecutor,
  ExecutorThreadHttp,
  HttpExecutorImpl;

const

  WM_EVENT_DATA =         WM_USER + 6000;
  WM_EVENT_PIPE =         WM_USER + 6003;
  WM_EVENT_RELOGIN =      WM_USER + 6004;

{ TExecutors }

constructor TExecutors.Create(AShareMgr: IShareMgr);
begin
  inherited Create;
  FIsStart := False;
  FIsShutDown := False;
  FWorkerThreadCount := 1;
  FShareMgr := AShareMgr;
  FMonitorThread := TExecutorThread.Create;
  FMonitorThread.ThreadMethod := DoTaskMonitor;
  FWorkerThreads := TList<TExecutorThread>.Create;
  FSubmitQueue := TSafeSemaphoreQueue<TObject>.Create;
  FFinishQueue := TSafeSemaphoreQueue<TObject>.Create;
  DoInitWindowMessage;
end;

destructor TExecutors.Destroy;
begin
  DoUnInitWindowMessage;
  DoCleanQueue(FFinishQueue);
  DoCleanQueue(FSubmitQueue);
  FFinishQueue.Free;
  FSubmitQueue.Free;
  FWorkerThreads.Free;
  FShareMgr := nil;
  inherited;
end;

procedure TExecutors.Start;
begin
  if not FIsStart then begin
    DoStart;
    FIsStart := True;
  end;
end;

procedure TExecutors.ShutDown;
begin
  if not FIsShutDown then begin
    DoShutDown;
    FIsShutDown := True;
  end;
end;

function TExecutors.IsTerminated: boolean;
begin
  Result := DoIsTerminated;
end;

function TExecutors.Submit(AObject: TObject): boolean;
begin
  Result := DoSubmit(AObject);
end;

procedure TExecutors.SetFixedThread(ACount: Integer);
begin
  if not FIsStart then begin
    FWorkerThreadCount := ACount;
  end;
end;

procedure TExecutors.DoCleanQueue(AQueue: TSafeSemaphoreQueue<TObject>);
var
  LObject: TObject;
begin
  while not AQueue.IsEmpty do begin
    LObject := AQueue.Dequeue;
    if LObject <> nil then begin
      LObject.Free;
    end;
  end;
end;

procedure TExecutors.DoInitWindowMessage;
begin
  FWindowHandle := AllocateHWnd(DoWndProc);
end;

procedure TExecutors.DoUnInitWindowMessage;
begin
  if FWindowHandle <> 0 then begin
    SetWindowLong(FWindowHandle, GWL_WNDPROC, 0);
    DeallocateHWnd(FWindowHandle);
  end;
end;

procedure TExecutors.DoStart;
begin
  DoStartThread(FWorkerThreadCount);
  FMonitorThread.StartEx;
end;

procedure TExecutors.DoShutDown;
begin
  FMonitorThread.ShutDown;
  DoShutDownThread;
end;

function TExecutors.DoIsTerminated: Boolean;
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  Result := True;
  for LIndex := 0 to FWorkerThreadCount - 1 do begin
    LWorker := FWorkerThreads.Items[LIndex];
    Result := LWorker.IsTerminated and Result;
    if not Result then Exit;
  end;
  Result := FMonitorThread.IsTerminated and Result;
end;

function TExecutors.DoSubmit(AObject: TObject): Boolean;
begin
  Result := True;
  FSubmitQueue.Enqueue(AObject);
  FSubmitQueue.ReleaseSemaphore;
end;

procedure TExecutors.DoStartThread(ACount: Integer);
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  for LIndex := 0 to ACount - 1 do begin
    LWorker := DoCreateExecutor;
    if LWorker <> nil then begin
      LWorker.Name := 'Worker_' + IntToStr(LWorker.ID);
      LWorker.ThreadMethod := DoTaskExecute;
      LWorker.StartEx;
      FWorkerThreads.Add(LWorker);
    end;
  end;
end;

function TExecutors.DoCreateExecutor: TExecutorThread;
begin
  Result := TExecutorThreadHttp.Create;
  TExecutorThreadHttp(Result).HttpExecutor := THttpExecutorImpl.Create(FShareMgr) as IHttpExecutor;
end;

procedure TExecutors.DoShutDownThread;
var
  LIndex: Integer;
  LWorker: TExecutorThread;
begin
  for LIndex := 0 to FWorkerThreads.Count - 1 do begin
    LWorker := FWorkerThreads.Items[LIndex];
    LWorker.ShutDown;
//    if LWorker.InterfaceRef <> nil then begin
//      LWorker.InterfaceRef := nil;
//    end;
    if TExecutorThreadHttp(LWorker).HttpExecutor <> nil then begin
      TExecutorThreadHttp(LWorker).HttpExecutor := nil;
    end;
  end;
  FWorkerThreads.Clear;
end;

procedure TExecutors.DoTaskExecute(AObject: TObject);
var
  LObject: TObject;
  LResult: Cardinal;
  LWorker: TExecutorThread;
  LHttpExecutor: IHttpExecutor;
begin
  LWorker := TExecutorThread(AObject);
//  LHttpExecutor := THttpExecutorImpl.Create(FShareMgr) as IHttpExecutor;
  try
    while not LWorker.IsTerminated do begin
      LResult := FMonitorThread.WaitForEx;
      case LResult of
        WAIT_OBJECT_0:
          begin
            while not FSubmitQueue.IsEmpty do begin

              if LWorker.IsTerminated then begin
//                if LHttpExecutor <> nil then begin
//                  LHttpExecutor := nil;
//                end;
                Exit;
              end;

              LObject := FSubmitQueue.Dequeue;

              if TExecutorThreadHttp(LWorker).HttpExecutor <> nil then begin
  {$IFDEF DEBUG}
                if FShareMgr.GetAppContext <> nil then begin
                  FShareMgr.GetAppContext.SysLog(llDEBUG, Format('[TExecutors][DoTaskExecute] Worker Id is %d and execute.', [LWorker.ID]));
                end;
  {$ENDIF}

                TExecutorThreadHttp(LWorker).HttpExecutor.Execute(LObject);
//                (LWorker.InterfaceRef as IHttpExecutor).Execute(LObject);

//                LHttpExecutor.Execute(LObject);
              end;

              case THttpContext(LObject).GFDataUpdate.GetErrorCode of
                ErrorCode_Service_Response_NoLogin,
                ErrorCode_Service_Response_NoExistsSid,
                ErrorCode_Service_Response_Session_Timeout,
                ErrorCode_Service_Login_ElseWhere_Logined,
                ErrorCode_Service_Response_Need_ReLogin:
                  begin
                    DoPostMessage(WM_EVENT_RELOGIN, THttpContext(LObject).GFDataUpdate.GetErrorCode, 0);
                  end;
              end;

              if THttpContext(LObject).WaitMode = wmNoBlocking then begin
                DoPostMessage(WM_EVENT_DATA, 0, 0);
              end else begin
                THttpContext(LObject).SetWaitFinish;
              end;
            end;
          end;
      end;
    end;
  finally
//    if LHttpExecutor <> nil then begin
//      LHttpExecutor := nil;
//    end;
  end;
end;

procedure TExecutors.DoTaskMonitor(AObject: TObject);
var
  LResult: Cardinal;
begin
  while not FMonitorThread.IsTerminated do begin
    LResult := WaitForSingleObject(FSubmitQueue.Semaphore, INFINITE);
    case LResult of
      WAIT_OBJECT_0:
        begin
          if FMonitorThread.IsTerminated then Exit;
          
          FMonitorThread.ResumeEx;
        end;
    end;
  end;
end;

procedure TExecutors.DoWndProc(var Message: TMessage);
var
  LObject: TObject;
  LReLoginEvent: TReLoginEvent;
begin
  case message.Msg of
    WM_EVENT_DATA:
      begin
        if FFinishQueue.IsEmpty then Exit;

        LObject := FFinishQueue.Dequeue;
        if LObject <> nil then begin
          if not THttpContext(LObject).GFDataUpdate.GetIsCancel then begin
            THttpContext(LObject).CallBack;
          end;
          FShareMgr.GetHttpContextPool.DeAllocate(LObject);
        end;
      end;
    WM_EVENT_PIPE:
      begin

      end;
    WM_EVENT_RELOGIN:
      begin
        LReLoginEvent := FShareMgr.GetReLoginEvent;
        if Assigned(LReLoginEvent) then begin
          LReLoginEvent(Integer(Message.WParam), '');
        end;
      end;
  end;
end;

procedure TExecutors.DoPostMessage(AMSG: Cardinal; AWParam, ALParam: Integer);
begin
  PostMessage(FWindowHandle, AMSG, AWParam, ALParam);
end;

end.
