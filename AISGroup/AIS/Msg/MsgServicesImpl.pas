unit MsgServicesImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-29
// Comments��
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

  // ��Ϣ����ʵ��
  TMsgServicesImpl = class(TInterfacedObject, ISyncAsync, IMsgServices)
  private
    // �߳���
    FLock: TCSLock;
    // ��Ϣ���
    FMsgHandle: THandle;
    // ���� ID (���ɽ����� ID)
    FIncrementID: Integer;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ��Ϣ��������
    FMsgFactory : TMsgFactory;
    // ��Ϣ����
    FSysMsgQueue: TSafeQueue<IMsgSys>;
    // ��Ϣ���Ĺ���
    FMsgSubcribeMgr: TMsgSubcribeMgr;
//    // ֪ͨ����
//    FNotifyServices: INotifyServices;
    // ��Ϣ�ɷ��߳�
    FMsgDispachThread: TExecutorThread;
  protected
    // �����Ϣ����
    procedure DoClearQueue;
    // ��ʼ��
    procedure DoInitialize;
    // �ͷŽӿ���Դ
    procedure DoUnInitialize;
    // ����ϵͳ��Ϣ
    procedure DoSendSysMessage;
    // ��Ϣ
    procedure DoWndProc(var Message: TMessage);
    // ��Ϣ�ɷ��߳�
    procedure DoMsgDispachThreadExecute(AObject: TObject);
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISyncAsync }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; safecall;
    // ͬ��ִ�з���
    procedure SyncExecute; safecall;
    // �첽ִ�з���
    procedure AsyncExecute; safecall;

    { IMsgServices }

    // ����һ����Ϣ������
    function CreateMsgReceiver(ACallBack: TMsgCallBackFunc): IMsgReceiver; safecall;
    // ������Ϣ
    procedure Producer(AProduceID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
    // ������Ϣ
    procedure Subcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver); safecall;
    // ȡ������
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
