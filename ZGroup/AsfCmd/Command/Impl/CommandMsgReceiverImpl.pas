unit CommandMsgReceiverImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-24
// Comments��
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
    // ������Ϣ
    procedure DoSubcribeMsgTypes;
    // ȡ��������Ϣ
    procedure DoUnSubcribeMsgTypes;
  protected
    // ��Ϣ���սӿ�
    FMsgReceiver: IMsgReceiver;
    // ��Ϣ��������
    FSubcribeMsgTypes: TMsgTypeDynArray;

    // ���Ӷ�������
    procedure DoAddSubcribeMsgTypes; virtual;
    // ������Ϣ�ص�����
    procedure DoMsgCallBack(AMsgType: TMsgType; AMsgInfo: string; var ALogTag: string); virtual;
  public
    // ���캯��
    constructor Create(ACommandID, APermMask: Integer); override;
    // ��������
    destructor Destroy; override;

    { ICommand }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); override;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; override;
    // ���ü���
    procedure SetActive; override;
    // ���÷Ǽ���
    procedure SetNoActive; override;
    // ����ִ�з���
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
