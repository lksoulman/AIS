unit IPCMsg;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-15
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Graphics,
  Controls,
  Forms,
  Dialogs;

type

  // window ��Ϣʵ�ֵĽ��̼�ͨ�ŷ����
  TIPCMsgServer = class
  private
    // �ǲ����Ѿ�����
    FIsStart: Boolean;
    // ��������
    FWindowName: string;
    // ���ھ��
    FWindowHandle: THandle;
    // Session ����
    FSessionName: string;
    // ��������ӶϿ���Ϣ
    FServerDisConnectHwnd: THandle;
    // �ͻ������ӶϿ�������Ϣ
    FClientDisConnectHwnd: THandle;
    // �ͻ�������������Ϣ
    FClientConnectRequestHwnd: THandle;
    // �������Ӧ�ͻ���������Ϣ
    FServerConnectResponseHwnd: THandle;
  protected
    // ע����Ϣ
    procedure DoRegisterMesssage;
    // ������Ϣ����
    procedure WndProc(var AMsg: TMessage);
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ���������
    procedure StartServer;
    // ֹͣ�����
    procedure StopServer;
  end;

  // window ��Ϣʵ�ֵĽ��̼�ͨ�ſͻ���
  TIPCMsgClient = class
  private
    // �ǲ���������
    FIsConnected: boolean;
    // Session ����
    FSessionName: string;
    // ��������ӶϿ���Ϣ
    FServerDisConnectHwnd: THandle;
    // �ͻ������ӶϿ�������Ϣ
    FClientDisConnectHwnd: THandle;
    // �ͻ�������������Ϣ
    FClientConnectRequestHwnd: THandle;
    // �������Ӧ�ͻ���������Ϣ
    FServerConnectResponseHwnd: THandle;
  protected
    // ע����Ϣ
    procedure DoRegisterMesssage;
    // ������Ϣ����
    procedure WndProc(var AMsg: TMessage);
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ���� Server
    procedure ConnectServer;
    // �Ͽ� Server
    procedure DisConnectServer;


    property IsConnected: boolean read FIsConnected;
  end;

implementation

const

  // ��������ע����Ϣ�ַ���
  IPC_CONNECT_REQUEST      = 'IPCConnectRequest';
  // ������Ӧע����Ϣ�ַ���
  IPC_CONNECT_RESPONSE     = 'IPCConnectRespose';
  // ��������ӶϿ�ע����Ϣ�ַ���
  IPC_SERVER_DISCONNECTING = 'IPCServerDisconneting';
  // �ͻ������ӶϿ�ע����Ϣ�ַ���
  IPC_CLIENT_DISCONNECTING = 'IPCClientDisconneting';

var
  UtilWindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TPUtilWindow');


function IPC_AllocateHWnd(AMethod: TWndMethod; AWindowName: string): HWND;
var
  LWndClass: TWndClass;
  LClassRegistered: Boolean;
begin
  UtilWindowClass.hInstance := HInstance;
{$IFDEF PIC}
  UtilWindowClass.lpfnWndProc := @DefWindowProc;
{$ENDIF}
  // ��ȡ UtilWindowClass �������ǲ��Ǳ�ע��
  LClassRegistered := GetClassInfo(HInstance,
                                   UtilWindowClass.lpszClassName,
                                   LWndClass);
  // ���û��ע�� ���� ע���˵Ĵ�����Ϣ���̲���Ĭ�ϵĹ���
  if not LClassRegistered then begin
    Windows.RegisterClass(UtilWindowClass);
  end else begin
    if LWndClass.lpfnWndProc <> @DefWindowProc then begin
      Windows.UnregisterClass(UtilWindowClass.lpszClassName, HInstance);
      Windows.RegisterClass(UtilWindowClass);
    end;
  end;
  // ����һ������ʾ�Ĵ��ڣ�window ������Ϣ
  Result := CreateWindowEx(WS_EX_TOOLWINDOW,
                           UtilWindowClass.lpszClassName,
                           PChar(AWindowName),
                           WS_POPUP,
                           0,
                           0,
                           0,
                           0,
                           0,
                           0,
                           HInstance,
                           nil);

  // ���ô�����Ϣ���շ���
  if Assigned(AMethod) then begin
    SetWindowLong(Result, GWL_WNDPROC, Longint(MakeObjectInstance(AMethod)));
  end;
end;

{ TIPCMsgServer }

constructor TIPCMsgServer.Create;
begin
  inherited;
  FIsStart := False;
end;

destructor TIPCMsgServer.Destroy;
begin

  inherited;
end;

procedure TIPCMsgServer.StartServer;
begin

end;

procedure TIPCMsgServer.StopServer;
begin

end;

procedure TIPCMsgServer.DoRegisterMesssage;
begin
  FServerDisConnectHwnd := RegisterWindowMessage(IPC_SERVER_DISCONNECTING);
  FClientDisConnectHwnd := RegisterWindowMessage(IPC_CLIENT_DISCONNECTING);
  FClientConnectRequestHwnd := RegisterWindowMessage(IPC_CONNECT_REQUEST);
  FServerConnectResponseHwnd := RegisterWindowMessage(IPC_CONNECT_RESPONSE);
end;

procedure TIPCMsgServer.WndProc(var AMsg: TMessage);
begin

end;

{ TIPCMsgClient }

constructor TIPCMsgClient.Create;
begin
  inherited;

end;

destructor TIPCMsgClient.Destroy;
begin

  inherited;
end;

procedure TIPCMsgClient.ConnectServer;
begin

end;

procedure TIPCMsgClient.DisConnectServer;
begin

end;

procedure TIPCMsgClient.DoRegisterMesssage;
begin
  FServerDisConnectHwnd := RegisterWindowMessage(IPC_SERVER_DISCONNECTING);
  FClientDisConnectHwnd := RegisterWindowMessage(IPC_CLIENT_DISCONNECTING);
  FClientConnectRequestHwnd := RegisterWindowMessage(IPC_CONNECT_REQUEST);
  FServerConnectResponseHwnd := RegisterWindowMessage(IPC_CONNECT_RESPONSE);
end;

procedure TIPCMsgClient.WndProc(var AMsg: TMessage);
begin

end;

end.
