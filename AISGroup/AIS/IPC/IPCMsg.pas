unit IPCMsg;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-15
// Comments：
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

  // window 消息实现的进程间通信服务端
  TIPCMsgServer = class
  private
    // 是不是已经启动
    FIsStart: Boolean;
    // 窗口名称
    FWindowName: string;
    // 窗口句柄
    FWindowHandle: THandle;
    // Session 名称
    FSessionName: string;
    // 服务端连接断开消息
    FServerDisConnectHwnd: THandle;
    // 客户端连接断开连接消息
    FClientDisConnectHwnd: THandle;
    // 客户端连接请求消息
    FClientConnectRequestHwnd: THandle;
    // 服务端响应客户端连接消息
    FServerConnectResponseHwnd: THandle;
  protected
    // 注册消息
    procedure DoRegisterMesssage;
    // 窗口消息过程
    procedure WndProc(var AMsg: TMessage);
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 启动服务端
    procedure StartServer;
    // 停止服务端
    procedure StopServer;
  end;

  // window 消息实现的进程间通信客户端
  TIPCMsgClient = class
  private
    // 是不是连接上
    FIsConnected: boolean;
    // Session 名称
    FSessionName: string;
    // 服务端连接断开消息
    FServerDisConnectHwnd: THandle;
    // 客户端连接断开连接消息
    FClientDisConnectHwnd: THandle;
    // 客户端连接请求消息
    FClientConnectRequestHwnd: THandle;
    // 服务端响应客户端连接消息
    FServerConnectResponseHwnd: THandle;
  protected
    // 注册消息
    procedure DoRegisterMesssage;
    // 窗口消息过程
    procedure WndProc(var AMsg: TMessage);
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 连接 Server
    procedure ConnectServer;
    // 断开 Server
    procedure DisConnectServer;


    property IsConnected: boolean read FIsConnected;
  end;

implementation

const

  // 连接请求注册消息字符串
  IPC_CONNECT_REQUEST      = 'IPCConnectRequest';
  // 连接响应注册消息字符串
  IPC_CONNECT_RESPONSE     = 'IPCConnectRespose';
  // 服务端连接断开注册消息字符串
  IPC_SERVER_DISCONNECTING = 'IPCServerDisconneting';
  // 客户端连接断开注册消息字符串
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
  // 获取 UtilWindowClass 窗体类是不是被注册
  LClassRegistered := GetClassInfo(HInstance,
                                   UtilWindowClass.lpszClassName,
                                   LWndClass);
  // 如果没有注册 或者 注册了的窗口消息过程不是默认的过程
  if not LClassRegistered then begin
    Windows.RegisterClass(UtilWindowClass);
  end else begin
    if LWndClass.lpfnWndProc <> @DefWindowProc then begin
      Windows.UnregisterClass(UtilWindowClass.lpszClassName, HInstance);
      Windows.RegisterClass(UtilWindowClass);
    end;
  end;
  // 创建一个不显示的窗口，window 接收消息
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

  // 设置窗口消息接收方法
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
