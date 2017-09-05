unit MsgServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message Service Inteface implementation
// Author£º      lksoulman
// Date£º        2017-7-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgType,
  MsgFunc,
  Windows,
  Classes,
  SysUtils,
  Messages,
  MsgService,
  AppContext,
  CommonLock,
  MsgFactory,
  MsgReceiver,
  CommonQueue,
  SyncAsyncImpl,
  ExecutorThread,
  MsgSubcribeMgr,
  MsgDispachingDic;

type

  // Message Service Inteface implementation
  TMsgServiceImpl = class(TSyncAsyncImpl, IMsgService)
  private
    // Thread lock
    FLock: TCSLock;
    // Message handle
    FMsgHandle: THandle;
    // Message Factory
    FMsgFactory: IMsgFactory;
    // Message Dispach Thread
    FMsgDispachThread: TExecutorThread;
    // Message Subcribe manager
    FMsgSubcribeMgr: TMsgSubcribeMgr;
    // Message Dispaching Dictionary
    FMsgDispachingDic: TMsgDispachingDic;
    // Message Pend Dispach Queue
    FMsgPendDispachQueue: TSafeQueue<TMsgEx>;
  protected
    // Clear Queue
    procedure DoClearQueue;
    // Message Callback
    procedure DoWndProc(var Message: TMessage);
    // Send Message
    procedure DoSendMessageMsg(AMsgId: Cardinal);
    // Message Dispach
    procedure DoMsgDispachThreadExecute(AObject: TObject);
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

    { IMsgService }

    // New Message Receiver Interface
    function NewReceiver(ACallBack: TMsgFuncCallBack): IMsgReceiver; safecall;
    // Subcribe Message Type
    procedure Subcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver); safecall;
    // Cancel Subcribe Message Type
    procedure UnSubcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver); safecall;
    // Post Message Type
    procedure PostMessageEx(AProID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
  end;

implementation

uses
  MsgFactoryImpl,
  MsgReceiverImpl;

const

  WM_MSG_SYS = WM_USER + 1000;

{ TMsgServiceImpl }

constructor TMsgServiceImpl.Create;
begin
  inherited;
  FLock := TCSLock.Create;
  FMsgFactory := TMsgFactoryImpl.Create as IMsgFactory;
  FMsgSubcribeMgr := TMsgSubcribeMgr.Create;
  FMsgDispachThread := TExecutorThread.Create;
  FMsgDispachThread.ThreadMethod := DoMsgDispachThreadExecute;
  FMsgDispachingDic := TMsgDispachingDic.Create;
  FMsgPendDispachQueue := TSafeQueue<TMsgEx>.Create;
  FMsgHandle := Classes.AllocateHWnd(DoWndProc);
end;

destructor TMsgServiceImpl.Destroy;
begin
  Classes.DeallocateHWnd(FMsgHandle);
  FMsgPendDispachQueue.Free;
  FMsgDispachingDic.Free;
  FMsgSubcribeMgr.Free;
  FMsgFactory := nil;
  FLock.Free;
  inherited;
end;

procedure TMsgServiceImpl.Initialize(AContext: IAppContext); safecall;
begin
  inherited Initialize(AContext);
  FMsgFactory.Initialize(AContext);
end;

procedure TMsgServiceImpl.UnInitialize;
begin
  FMsgFactory.UnInitialize;
  inherited UnInitialize;
end;

procedure TMsgServiceImpl.SyncBlockExecute;
begin

end;

procedure TMsgServiceImpl.AsyncNoBlockExecute;
begin

end;

function TMsgServiceImpl.Dependences: WideString;
begin

end;

function TMsgServiceImpl.NewReceiver(ACallBack: TMsgFuncCallBack): IMsgReceiver;
begin
  Result := FMsgSubcribeMgr.NewReceiver(ACallBack);
end;

procedure TMsgServiceImpl.Subcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver);
begin
  FMsgSubcribeMgr.Subcribe(AMsgType, AReceiver);
end;

procedure TMsgServiceImpl.UnSubcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver);
begin
  FMsgSubcribeMgr.UnSubcribe(AMsgType, AReceiver);
end;

procedure TMsgServiceImpl.PostMessageEx(AProID: Integer; AMsgType: TMsgType; AMsgInfo: WideString);
var
  LMsgEx: TMsgEx;
begin
  LMsgEx := FMsgFactory.CreateMsg(AProID, AMsgType, AMsgInfo);
  if LMsgEx <> nil then begin
    FMsgPendDispachQueue.Enqueue(LMsgEx);
  end;
end;

procedure TMsgServiceImpl.DoClearQueue;
var
  LMsgEx: TMsgEx;
begin
  while not FMsgPendDispachQueue.IsEmpty do begin
    LMsgEx := FMsgPendDispachQueue.Dequeue;
    if LMsgEx <> nil then begin
      LMsgEx.Free;
    end;
  end;
end;

procedure TMsgServiceImpl.DoSendMessageMsg(AMsgId: Cardinal);
begin
  PostMessage(FMsgHandle, WM_MSG_SYS, AMsgId, 0);
end;

procedure TMsgServiceImpl.DoWndProc(var Message: TMessage);
var
  LMsgEx: TMsgEx;
begin
  if Message.Msg = WM_MSG_SYS then begin
    LMsgEx := FMsgDispachingDic.GetMsgEx(Message.WParam);
    FMsgSubcribeMgr.DispachMessageEx(LMsgEx);
  end;
end;

procedure TMsgServiceImpl.DoMsgDispachThreadExecute(AObject: TObject);
var
  LResult: Integer;
  LThread: TExecutorThread;
begin
//  Sleep(FDelayTime);
  LThread := TExecutorThread(AObject);
  while not LThread.IsTerminated do begin
    LResult := LThread.WaitForEx;
    case LResult of
      WAIT_OBJECT_0:
        begin
//           if not FMsgQueue.IsEmpty then begin
//             DoSendMessageMsg(AMsgId: Integer);
//           end;
        end;
    end;
  end;
end;

end.
