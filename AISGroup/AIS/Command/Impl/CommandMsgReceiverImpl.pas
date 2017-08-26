unit CommandMsgReceiverImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-24
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgType,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  MsgReceiver,
  CommandImpl;

type

  TCommandMsgReceiverImpl = class(TCommandImpl)
  private
    // 订阅消息
    procedure DoSubcribeMsgTypes;
    // 取消订阅消息
    procedure DoUnSubcribeMsgTypes;
  protected
    // 消息接收接口
    FMsgReceiver: IMsgReceiver;
    // 消息类型数组
    FSubcribeMsgTypes: TMsgTypeDynArray;

    // 增加订阅类型
    procedure DoAddSubcribeMsgTypes; virtual;
    // 订阅消息回调方法
    procedure DoMsgCallBack(AMsgType: TMsgType; AMsgInfo: string; var ALogTag: string); virtual;
  public
    // 构造函数
    constructor Create(ACommandID, APermMask: Integer); override;
    // 析构函数
    destructor Destroy; override;

    { ICommand }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); override;
    // 释放不需要的资源
    procedure UnInitialize; override;
    // 设置激活
    procedure SetActive; override;
    // 设置非激活
    procedure SetNoActive; override;
    // 命令执行方法
    procedure ExecCommand(APermMask: Integer; AParams: WideString); override;
  end;

implementation

uses
  MsgServices;

{ TCommandMsgReceiverImpl }

constructor TCommandMsgReceiverImpl.Create(ACommandID, APermMask: Integer);
begin
  inherited Create(ACommandID, APermMask);
  DoAddSubcribeMsgTypes;
end;

destructor TCommandMsgReceiverImpl.Destroy;
begin

  inherited;
end;

procedure TCommandMsgReceiverImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  if FAppContext.GetMsgServices <> nil then begin
    FMsgReceiver := (FAppContext.GetMsgServices as IMsgServices).CreateMsgReceiver(DoMsgCallBack);
    DoSubcribeMsgTypes;
  end;
end;

procedure TCommandMsgReceiverImpl.UnInitialize;
begin
  if FMsgReceiver <> nil then begin
    DoUnSubcribeMsgTypes;
    FMsgReceiver := nil;
  end;
  inherited UnInitialize;
end;

procedure TCommandMsgReceiverImpl.SetActive;
begin
  if FMsgReceiver <> nil then begin
    FMsgReceiver.SetActive(True);
  end;
end;

procedure TCommandMsgReceiverImpl.SetNoActive;
begin
  if FMsgReceiver <> nil then begin
    FMsgReceiver.SetActive(False);
  end;
end;

procedure TCommandMsgReceiverImpl.ExecCommand(APermMask: Integer; AParams: WideString);
begin

end;

procedure TCommandMsgReceiverImpl.DoAddSubcribeMsgTypes;
begin
  SetLength(FSubcribeMsgTypes, 0);
end;

procedure TCommandMsgReceiverImpl.DoSubcribeMsgTypes;
var
  LIndex: Integer;
  LMsgType: TMsgType;
begin
  for LIndex := Low(FSubcribeMsgTypes) to High(FSubcribeMsgTypes) do begin
    LMsgType := FSubcribeMsgTypes[LIndex];
    (FAppContext.GetMsgServices as IMsgServices).Subcribe(LMsgType, FMsgReceiver);
  end;
end;

procedure TCommandMsgReceiverImpl.DoUnSubcribeMsgTypes;
var
  LIndex: Integer;
  LMsgType: TMsgType;
begin
  for LIndex := Low(FSubcribeMsgTypes) to High(FSubcribeMsgTypes) do begin
    LMsgType := FSubcribeMsgTypes[LIndex];
    (FAppContext.GetMsgServices as IMsgServices).Subcribe(LMsgType, FMsgReceiver);
  end;
end;

procedure TCommandMsgReceiverImpl.DoMsgCallBack(AMsgType: TMsgType; AMsgInfo: string; var ALogTag: string);
begin
  ALogTag := Self.ClassName;


end;

end.
