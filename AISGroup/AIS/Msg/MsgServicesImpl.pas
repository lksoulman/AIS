unit MsgServicesImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-29
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  MsgSys,
  MsgType,
  SyncAsync,
  AppContext,
  MsgFactory,
  CommonLock,
  MsgServices,
  MsgReceiver,
  CommonQueue,
  MsgSubcribeMgr,
  ExecutorThread;

type

  // 消息服务实现
  TMsgServicesImpl = class(TInterfacedObject, ISyncAsync, IMsgServices)
  private
    // 线程锁
    FLock: TCSLock;
    // 消息句柄
    FMsgHandle: THandle;
    // 自增 ID (生成接收者 ID)
    FIncrementID: Integer;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 消息创建工厂
    FMsgFactory : TMsgFactory;
    // 消息队列
    FSysMsgQueue: TSafeQueue<IMsgSys>;
    // 消息订阅管理
    FMsgSubcribeMgr: TMsgSubcribeMgr;
//    // 通知服务
//    FNotifyServices: INotifyServices;
    // 消息派发线程
    FMsgDispachThread: TExecutorThread;
  protected
    // 清空消息队列
    procedure DoClearQueue;
    // 初始化
    procedure DoInitialize;
    // 释放接口资源
    procedure DoUnInitialize;
    // 发送系统消息
    procedure DoSendSysMessage;
    // 消息
    procedure DoWndProc(var Message: TMessage);
    // 消息派发线程
    procedure DoMsgDispachThreadExecute(AObject: TObject);
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ISyncAsync }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; safecall;
    // 同步执行方法
    procedure SyncExecute; safecall;
    // 异步执行方法
    procedure AsyncExecute; safecall;

    { IMsgServices }

    // 创建一个消息接收者
    function CreateMsgReceiver(ACallBack: TMsgCallBackFunc): IMsgReceiver; safecall;
    // 生产消息
    procedure Producer(AProduceID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
    // 订阅消息
    procedure Subcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver); safecall;
    // 取消订阅
    procedure DisSubcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver); safecall;
  end;

implementation

uses
  MsgReceiverImpl;

const

  WM_SYS_MSG = WM_USER + 1000;

{ TMsgServicesImpl }

constructor TMsgServicesImpl.Create;
begin
  inherited;
  FIncrementID := 0;
  FLock := TCSLock.Create;
  FMsgFactory := TMsgFactory.Create;
  FSysMsgQueue := TSafeQueue<IMsgSys>.Create;
  FMsgSubcribeMgr := TMsgSubcribeMgr.Create;
  FMsgDispachThread := TExecutorThread.Create;
  FMsgHandle := Classes.AllocateHWnd(DoWndProc);
  FMsgDispachThread.ThreadMethod := DoMsgDispachThreadExecute;
end;

destructor TMsgServicesImpl.Destroy;
begin
  Classes.DeallocateHWnd(FMsgHandle);
  FMsgSubcribeMgr.Free;
  FSysMsgQueue.Free;
  FMsgFactory.Free;
  FLock.Free;
  inherited;
end;

procedure TMsgServicesImpl.DoClearQueue;
var
  LMsgSys: IMsgSys;
begin
  while not FSysMsgQueue.IsEmpty do begin
    LMsgSys := FSysMsgQueue.Dequeue;
    if LMsgSys <> nil then begin
      LMsgSys := nil;
    end;
  end;
end;

procedure TMsgServicesImpl.DoInitialize;
begin
  FMsgDispachThread.StartEx;
end;

procedure TMsgServicesImpl.DoUnInitialize;
begin
  FMsgDispachThread.ShutDown;
end;

procedure TMsgServicesImpl.DoSendSysMessage;
begin
  PostMessage(FMsgHandle, WM_SYS_MSG, 0, 0);
end;

procedure TMsgServicesImpl.DoWndProc(var Message: TMessage);
begin
  if Message.Msg = WM_SYS_MSG then begin
    if not FSysMsgQueue.IsEmpty then begin
      FMsgSubcribeMgr.DispachMsg(FSysMsgQueue.Dequeue);
    end;
  end;
end;

procedure TMsgServicesImpl.DoMsgDispachThreadExecute(AObject: TObject);
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
           if not FSysMsgQueue.IsEmpty then begin
             DoSendSysMessage;
           end;
        end;
    end;
  end;
end;

procedure TMsgServicesImpl.Initialize(AContext: IAppContext); safecall;
begin
  FAppContext := AContext;
  DoInitialize;
end;

procedure TMsgServicesImpl.UnInitialize;
begin
  DoUnInitialize;
end;

function TMsgServicesImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TMsgServicesImpl.SyncExecute;
begin

end;

procedure TMsgServicesImpl.AsyncExecute;
begin

end;

function TMsgServicesImpl.CreateMsgReceiver(ACallBack: TMsgCallBackFunc): IMsgReceiver;
begin
  FLock.Lock;
  try
    Result := TMsgReceiverImpl.Create(FIncrementID, ACallBack) as IMsgReceiver;
    Inc(FIncrementID);
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgServicesImpl.Producer(AProduceID: Integer; AMsgType: TMsgType; AMsgInfo: WideString);
begin
  FMsgFactory.CreateSysMsg(AProduceID, AMsgType, AMsgInfo);
end;

procedure TMsgServicesImpl.Subcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver);
begin
  FMsgSubcribeMgr.Subcribe(AMsgType, AMsgReceiver);
end;

procedure TMsgServicesImpl.DisSubcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver);
begin
  FMsgSubcribeMgr.DisSubcribe(AMsgType, AMsgReceiver);
end;

end.
