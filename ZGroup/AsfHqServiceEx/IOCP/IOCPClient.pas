{ 本单元定义一个特殊的TCP类，既支持监听又支持连接，最多可以同时维持63个连接
  如果要起监听，就只支持62个连接，如果要支持更多连接，可以使用多个实例来做
  彼此互不干扰，但遗憾的是，没有考虑到让一个监听而把接受到的连接分配给其他类来管理

  发送数据应该使用发送者自己的线程，不要在事件回调里调用发送，因为只有一个
  线程来处理所有的事情，如果用来发送，就势必影响对网络事件的轮询和数据接收

  如果数据量大，就不要使用主线程发送，因为发送是同步的，会影响应用程序的消息循环

  本类使用win98-win2003通用API，可以使用在win98以上任意微软平台
}

unit IOCPClient;

interface

uses Windows, Classes, NetEncoding, SysUtils, WinSock2, EncdDecd, IOCPUtil, IOCPLibrary, IOCPMemory,
  Ansistrings;

type

  // 包头
  PPkgHead = ^TPkgHead;

  TPkgHead = packed record
    Sign: array [0 .. 3] of AnsiChar;
    DataLen: Cardinal; // 当前包数据长度
  end;

  TClientStatus = (csFree, // 空闲，可以用来连接，也可以用来接收连接
    csAccept, // 只有监听套接字才会处于这个状态
    csConnecting, // 正在连接或者正在接受连接
    csConnected, // 已连接
    csDisconnecting); // 断开状态

  TClientOperType = (otProxy1, // 启动代理协商第1步
    otProxy2, // 接收代理协商第1步响应，发送第2步
    otProxy3, // 接收代理协商第2步响应，发送第3步
    otRecvHead, // 接收头
    otRecvBody, // 接收体
    otRecvFile, // 接收文件块
    otRecvData); // 接收数据

  // 代理类型
  PProxyKind = ^TProxyKind;
  TProxyKind = (pkNoProxy = 1, pkHTTPProxy = 2, pkSOCKS5Proxy = 3, pkSOCKS4Proxy = 4);

  PClientContext = ^TClientContext;

  TClientContext = packed record
    Sock: TSocket; // 套接字
    TotalLen: Cardinal; // 总字节数
    FinishLen: Cardinal; // 完成字节数
    Overlap: TOverlapped; // 重叠结构   用来接收
    Index: byte; // 索引
    Status: TClientStatus; // 使用状态
    OperType: TClientOperType; // 操作状态,用来控制接收步骤
    UseProxy: boolean; // 是否使用Proxy
    UsePkgHead: boolean; // 是否使用自定义协议
    Reserve: byte; // 补齐
    SendRTL: TRTLCriticalSection;
    FileHandle: THandle; // 接收文件句柄
    Offset: Cardinal; // 接收文件偏移
    Timeout: integer; // 超时值,为-1表示不控制超时,整数开始记时,由超时线程
    // 每2秒醒来累加,超过等待时间则激活不同事件,然后通知
    // 轮询线程重组句柄数组
    MaxTimeout: integer; // 超时值
    NetEvent: THandle; // 网络事件
    RecvTime: Double; // 使用自定义协议时的接收计时

    ProxyDestIP: Cardinal; // 代理IP，优先使用这个，没有的话看机器名
    ProxyDestPort: Word;

    ProxyKind: PProxyKind;
    ProxyUser: PAnsiString; // 代理用户
    ProxyPwd: PAnsiString; // 代理口令
    ProxyLevel: Word;

    DestIP: Cardinal; // 服务器IP    如果是接受的连接，那么是对方IP
    DestName: PAnsiChar; // 服务器名称  如果调用Connect是提供名字，则这里记录名字，否则为nil
    DestPort: Word; // 目标端口
    OuterFlag: integer; // 外部标志
    ConnTime: Double; // 连接成功时间
    Data: PAnsiChar; // 真正收到的数据
    PkgHead: TPkgHead; // 自定义的TCP头
    Buf: PAnsiChar; // 指向CONST_BUFFER_LEN长度的指针
  end;

  TTcpClient = class;

  // 事件回调定义
  // 连接完成
  // 连接完成
  TOnConnectOver = procedure(Sender: TTcpClient; // 发生事件的对象
    const Index: byte; // 索引
    const ErrCode: integer) of object; // 错误码

  // 接受到连接
  TOnAcceptConnect = procedure(Sender: TTcpClient; // 发生事件的对象
    const Index: byte; // 索引
    const IP: Cardinal; // 对方IP
    const Port: Word) of object; // 对方端口

  // 接收到数据
  TOnRecvDataOver = procedure(Sender: TTcpClient; // 发生事件的对象
    const Index: byte; // 索引
    const ErrCode: integer; // 错误码
    const Data: PAnsiChar; // 数据指针
    const DataLen: Cardinal; // 数据长度
    const UseTime: Double) of object; // 本次接收用时

  // 连接被断开事件  自己主动断开没有通知
  TOnDisconnected = procedure(Sender: TTcpClient; // 发生事件的对象
    const Index: byte) of object; // 索引

  // 文件到达事件，仅适用于使用自定义协议
  TOnRecvFileQuery = procedure(Sender: TTcpClient; // 发生事件的对象
    const Index: byte; // 索引
    const FileSize: Cardinal; // 到达的文件大小
    var SaveName: Ansistring; // 保存文件名，填空不接收并断开
    var Offset: Cardinal) of object; // 保存偏移，仅适用于写已存在文件

  // 文件接收完成事件，仅适用于使用自定义协议
  TOnRecvFileOver = procedure(Sender: TTcpClient; // 发生事件的对象
    const Index: byte; // 索引
    const ErrCode: integer; // 错误码
    const SaveName: Ansistring; // 到达事件里的文件名
    const FileSize: Cardinal; // 文件大小
    const FinishLen: Cardinal; // 完成字节数
    const Offset: Cardinal; // 到达事件填写的偏移
    const UseTime: Double) of object; // 本次接收用时

  TOnWriteDebug = procedure(Sender: TTcpClient; const DebugStr: string) of object;

  TRecvThread = class(TThread)
  private
    FWaitArray: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of THandle; // 监听事件句柄数组
    FWaitIndex: array [0 .. MAXIMUM_WAIT_OBJECTS - 1] of byte; // 记录当前轮询的索引
    FWaitCount: integer;
    FTcpClient: TTcpClient;
    FRecvEvent: THandle;

    procedure SetNoNagle(Sock: THandle);
    procedure StartNegociateWithProxy(pClient: PClientContext);
    procedure StartRecvFile(pClient: PClientContext; SaveName: Ansistring; Offset: Cardinal); // 去打开文件，准备接收文件

    function SendProxyData(pClient: PClientContext; const Buf: WSABUF): integer;

    procedure SendProxy2(pClient: PClientContext);
    procedure SendProxy3(pClient: PClientContext);

    procedure OnlyDisconnect(pClient: PClientContext);
    procedure DoRecvDataOver(const ErrCode: integer; pClient: PClientContext; const Data: PAnsiChar;
      const DataLen: Cardinal; const UseTime: Double);
    procedure DoConnectOver(const ErrCode: integer; pClient: PClientContext);

  protected

    procedure ReBuildWaitArray;
    procedure HandleOneEvent(const Index: byte);
    procedure CallAccept(pClient: PClientContext); // 有连接来了

    procedure HandleConnOver(pClient: PClientContext);

    procedure HandleRecvHead(pClient: PClientContext); // 接收头
    procedure HandleRecvBody(pClient: PClientContext); // 接收体
    procedure HandleFileArrive(pClient: PClientContext); // 处理文件到达
    procedure HandleRecvFile(pClient: PClientContext); // 接收文件块

    procedure HandleRecvData(pClient: PClientContext); // 收到数据体

    procedure RecvProxyRes1(pClient: PClientContext); // 接收代理协商第1步响应，发送第2步
    procedure RecvProxyRes2(pClient: PClientContext); // 接收代理协商第2步响应，发送第3步
    procedure RecvProxyRes3(pClient: PClientContext); // 接收代理协商第3步响应

    procedure Execute; override;
  public
    constructor Create(TcpIoClient: TTcpClient);
  end;

  TTimeOutThread = class(TThread)
  private
    FTcpClient: TTcpClient;
  protected
    procedure Execute; override;
  public
    constructor Create(TcpClient: TTcpClient);
  end;

  TTcpClient = class
  private
    FActive: boolean;
    FNeedListen: boolean;
    FRTLClient: TRTLCriticalSection;
    FClientArray: array [1 .. MAXIMUM_WAIT_OBJECTS - 1] of TClientContext;

    FExitSema: THandle;
    FTimeoutEvent: THandle;

    FRecvThread: TRecvThread;
    FTimeOutThread: TTimeOutThread;

    FListenPort: Word; // 本地监听端口
    FListenIP: Cardinal; // 本地绑定IP

    FProxyKind: TProxyKind;
    FProxyIP: Ansistring; // 代理IP，优先使用这个，没有的话看机器名
    FProxyPort: Word; // 代理监听端口
    FProxyUser: Ansistring; // 代理用户
    FProxyPwd: Ansistring; // 代理口令

    FProxyKind2: TProxyKind;
    FProxyIP2: Ansistring; // 代理IP，优先使用这个，没有的话看机器名
    FProxyPort2: Word; // 代理监听端口
    FProxyUser2: Ansistring; // 代理用户
    FProxyPwd2: Ansistring; // 代理口令

    FUsePkgHead: boolean; // 总体是否使用包头

    FInitWinSock: boolean;

    FOnAcceptConnect: TOnAcceptConnect;
    FOnConnectOver: TOnConnectOver;
    FOnRecvDataOver: TOnRecvDataOver;
    FOnDisconnected: TOnDisconnected;
    FOnRecvFileQuery: TOnRecvFileQuery;
    FOnRecvFileOver: TOnRecvFileOver;
    FOnWriteDebug: TOnWriteDebug;
    function GetFlags(const Index: integer): integer;
  protected
    function InitContext: integer;
    function UnInitContext: integer; // 初始化上下文

    function CreateListenSock: integer; // 创建监听套接字
    function GetFreeContext: PClientContext;
    procedure ReturnContext(pClient: PClientContext);

    function GetProxyIPByProxyName(const ProxyIP: Ansistring): Cardinal;
    procedure DoConnectOver(const ErrCode: integer; pClient: PClientContext);
    procedure DoDisconnected(pClient: PClientContext);
    procedure DoRecvFileOver(const ErrCode: integer; pClient: PClientContext; const SaveName: Ansistring;
      const FileSize: Cardinal; const FinishLen: Cardinal; const Offset: Cardinal; const UseTime: Double);

    procedure DoRecvFileQuery(pClient: PClientContext; var SaveName: Ansistring; var Offset: Cardinal);
    procedure DoRecvDataOver(const ErrCode: integer; pClient: PClientContext; const Data: PAnsiChar;
      const DataLen: Cardinal; const UseTime: Double);
    procedure DoAcceptConnect(pClient: PClientContext; IP: Cardinal; const Port: Word);

    function CheckValid(const Index: byte): integer;
    function CheckValidFlag(const Index: byte): integer;
    function SendFinalData(pClient: PClientContext; Buf: PWSABUF; BufCount: Cardinal; NeedLen: Cardinal): integer;

    function EncodePkgHead(var PkgHead: TPkgHead; DataLen, PkgKind: Cardinal): integer;
    function DecodePkgHead(var PkgHead: TPkgHead): integer;

  public
    constructor Create;
    destructor Destroy; override;

    function StartServer: integer;
    function StopServer: integer;

    // 连接到对方，提供2个重载方法  其中PassProxy参数表示连接时如果当前定义了
    // 代理，是否使用代理，如果为false，表示不通过代理而是简单直接连接
    // 之所以这么定义是为了方便局域网内部自己连接
    function ConnectTo(const DestName: Ansistring; // 目标机器名或者域名
      const DestPort: Word; // 目标端口
      var Index: byte; // 返回的索引号
      const Flag: integer = 0; // 标志
      const OwnProto: boolean = true; const PassProxy: boolean = true): integer; overload;

    function ConnectTo(const DestIP: Cardinal; // 目标IP
      const DestPort: Word; // 目标端口
      var Index: byte; // 返回索引号
      const Flag: integer = 0; // 标志
      const OwnProto: boolean = true; const PassProxy: boolean = true): integer; overload;

    // 专用保持连接的方法
    function KeepConnection(const Index: byte): integer;

    // 发送数据 提供3个重载方法
    // 如果不为0，表示发送失败，但又有如下结果
    // $2006，表示上次发送任务还没有完成，稍后可以再试
    // $9998 表示服务未启动
    // $3009 表示索引错误
    // $1007 表示当前索引没有连接
    // $6002 表示通过网络发送失败，连接将被自动断开
    // $6007 表示无法监控发送完成，估计是系统资源不足，当前连接也没有出现问题，稍后可以再试
    // 发送数据
    function SendData(const Index: byte; // 索引
      const Data: Pointer; // 数据
      const DataLen: Cardinal): integer; overload; // 数据长度

    function SendData(const Index: byte; // 索引
      const Head, Data: Pointer; // 数据头+数据指针
      const HeadLen, DataLen: Cardinal): integer; overload; // 数据头+数据长度

    // 下面的方法支持"头+数据体+尾"三块数据
    function SendData(const Index: byte; const Head, Data, Tail: Pointer; const HeadLen, DataLen, TailLen: Cardinal)
      : integer; overload;

    // 发送文件 支持使用一个自定义的头（在Head不为nil且HeadLen>0情况下），支持断点发送
    // 不支持超过2G文件的发送
    function SendFile(const Index: byte; const FileName: Ansistring; // 全路径文件名
      var FileSize: Cardinal; // 文件大小
      const Offset: Cardinal = 0; // 偏移
      const Head: Pointer = nil; // 文件头
      const HeadLen: Cardinal = 0 // 头长度
      ): integer;

    // 断开连接
    function DisconnectFrom(const Index: byte): integer;

    // 启动超时控制
    function StartTimeout(const Index: byte; NewTimeOut: Cardinal): integer; // 新的超时值
    function StopTimeout(const Index: byte): integer; // 索引

    procedure WriteDebug(const DebugMsg: string);

    property Active: boolean read FActive;
    property ListenPort: Word read FListenPort write FListenPort;
    property NeedListen: boolean read FNeedListen write FNeedListen;

    property ProxyKind: TProxyKind read FProxyKind write FProxyKind;
    property ProxyIP: Ansistring read FProxyIP write FProxyIP; // 代理IP，优先使用这个，没有的话看机器名
    property ProxyPort: Word read FProxyPort write FProxyPort; // 代理监听端口

    property ProxyUser: Ansistring read FProxyUser write FProxyUser; // 代理用户
    property ProxyPwd: Ansistring read FProxyPwd write FProxyPwd; // 代理口令

    property ProxyKind2: TProxyKind read FProxyKind2 write FProxyKind2;
    property ProxyIP2: Ansistring read FProxyIP2 write FProxyIP2; // 代理IP，优先使用这个，没有的话看机器名
    property ProxyPort2: Word read FProxyPort2 write FProxyPort2; // 代理监听端口

    property ProxyUser2: Ansistring read FProxyUser2 write FProxyUser2; // 代理用户
    property ProxyPwd2: Ansistring read FProxyPwd2 write FProxyPwd2; // 代理口令

    property OnAcceptConnect: TOnAcceptConnect read FOnAcceptConnect write FOnAcceptConnect;
    property OnConnectOver: TOnConnectOver read FOnConnectOver write FOnConnectOver;
    property OnRecvDataOver: TOnRecvDataOver read FOnRecvDataOver write FOnRecvDataOver;
    property OnDisconnected: TOnDisconnected read FOnDisconnected write FOnDisconnected;
    property OnRecvFileQuery: TOnRecvFileQuery read FOnRecvFileQuery write FOnRecvFileQuery;
    property OnRecvFileOver: TOnRecvFileOver read FOnRecvFileOver write FOnRecvFileOver;
    property OnWriteDebug: TOnWriteDebug read FOnWriteDebug write FOnWriteDebug;

    property Flags[const index: integer]: integer read GetFlags;
  end;

implementation

{ TIOCPClient }

constructor TTcpClient.Create;
begin
  FExitSema := INVALID_HANDLE_VALUE;
  FTimeoutEvent := INVALID_HANDLE_VALUE;
  FInitWinSock := WinSock2Startup;
  FListenPort := 5151;
  FNeedListen := false;
  FUsePkgHead := true;

  FProxyKind := pkNoProxy;
  FProxyIP := ''; // 代理IP，优先使用这个，没有的话看机器名
  FProxyPort := 0; // 代理监听端口

  FProxyUser := ''; // 代理用户
  FProxyPwd := ''; // 代理口令

  FProxyKind2 := pkNoProxy;
  FProxyIP2 := ''; // 代理IP，优先使用这个，没有的话看机器名
  FProxyPort2 := 0; // 代理监听端口

  FProxyUser2 := ''; // 代理用户
  FProxyPwd2 := ''; // 代理口令

  InitializeCriticalSection(FRTLClient);
end;

destructor TTcpClient.Destroy;
begin
  StopServer;
  WinSock2Cleanup(FInitWinSock);

  DeleteCriticalSection(FRTLClient);

  inherited Destroy;
end;

function TTcpClient.DisconnectFrom(const Index: byte): integer;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin
    FClientArray[Index].Status := csDisconnecting;
    ReleaseSemaphore(FExitSema, 1, nil); // 通知线程改变轮询
  end;
end;

procedure TTcpClient.DoAcceptConnect(pClient: PClientContext; IP: Cardinal; const Port: Word);
begin
  if assigned(FOnAcceptConnect) then
    try
      FOnAcceptConnect(self, pClient^.Index, IP, Port);
    except
    end;
end;

procedure TTcpClient.DoConnectOver(const ErrCode: integer; pClient: PClientContext);
begin
  if assigned(FOnConnectOver) then
    try
      FOnConnectOver(self, pClient^.Index, ErrCode);
    except
    end;
end;

procedure TTcpClient.DoDisconnected(pClient: PClientContext);
begin
  if assigned(FOnDisconnected) then
    try
      FOnDisconnected(self, pClient^.Index);
    except
    end;
end;

procedure TTcpClient.DoRecvDataOver(const ErrCode: integer; pClient: PClientContext; const Data: PAnsiChar;
  const DataLen: Cardinal; const UseTime: Double);
begin
  if assigned(FOnRecvDataOver) then
    try
      FOnRecvDataOver(self, pClient^.Index, ErrCode, Data, DataLen, UseTime);
    except
    end;
end;

procedure TTcpClient.DoRecvFileOver(const ErrCode: integer; pClient: PClientContext; const SaveName: Ansistring;
  const FileSize: Cardinal; const FinishLen: Cardinal; const Offset: Cardinal; const UseTime: Double);
begin
  if assigned(FOnRecvFileOver) then
    try
      FOnRecvFileOver(self, pClient^.Index, ErrCode, SaveName, FileSize, FinishLen, Offset, UseTime);
    except
    end;
end;

procedure TTcpClient.DoRecvFileQuery(pClient: PClientContext; var SaveName: Ansistring; var Offset: Cardinal);
begin
  if assigned(FOnRecvFileQuery) then
    try
      FOnRecvFileQuery(self, pClient^.Index, pClient^.TotalLen, SaveName, Offset);
    except
    end;
end;

function TTcpClient.EncodePkgHead(var PkgHead: TPkgHead; DataLen, PkgKind: Cardinal): integer;
begin

  // Copy(PkgHead.Sign, AnsiString('2003'), 4);
  // PkgHead.Sign[0] := '2';
  // PkgHead.Sign[1] := '0';
  // PkgHead.Sign[2] := '0';
  // PkgHead.Sign[3] := '3';
  Move(Ansistring('2003'), PkgHead.Sign[0], 4);

  PkgHead.DataLen := DataLen;
  result := CONST_SUCCESS_NO;
end;

function TTcpClient.DecodePkgHead(var PkgHead: TPkgHead): integer;
begin
  if CompareMem(PAnsiChar('2003'), @PkgHead.Sign[0], 4) then
    result := CONST_SUCCESS_NO
  else if CompareMem(PAnsiChar('003'), @PkgHead.Sign[0], 3) then
  begin
    Move(PkgHead.Sign[0], PkgHead.Sign[1], Sizeof(TPkgHead) - 1);
    result := CONST_SUCCESS_NO;
  end
  else
    result := CONST_ERROR_INVALID_PKG_FLAG;
end;

function TTcpClient.SendData(const Index: byte; const Data: Pointer; const DataLen: Cardinal): integer;
var
  SendBuf: array [0 .. 1] of WSABUF;
  pClient: PClientContext;
  NeedLen: Cardinal;
  BufCount: Cardinal;
  PkgHead: PPkgHead;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin
    PkgHead := nil;
    try
      pClient := @FClientArray[Index];
      BufCount := 1;
      NeedLen := DataLen;
      if pClient.UsePkgHead then
      begin
        GetMemEx(Pointer(PkgHead), Sizeof(TPkgHead));
        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(PkgHead);

        EncodePkgHead(PkgHead^, NeedLen, CONST_PKGTYPE_DATA);

        SendBuf[1].len := DataLen;
        SendBuf[1].Buf := Data;
        NeedLen := SendBuf[0].len + NeedLen;
        inc(BufCount);
      end
      else
      begin
        SendBuf[0].len := DataLen;
        SendBuf[0].Buf := Data;
      end;
      result := SendFinalData(pClient, @SendBuf[0], BufCount, NeedLen);
    finally
      if PkgHead <> nil then
        FreeMemEx(PkgHead);
    end;
  end;
end;

function TTcpClient.SendData(const Index: byte; const Head, Data: Pointer; const HeadLen, DataLen: Cardinal): integer;
var
  SendBuf: array [0 .. 2] of WSABUF;
  pClient: PClientContext;
  NeedLen: Cardinal;
  BufCount: Cardinal;
  PkgHead: PPkgHead;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin

    PkgHead := nil;
    try
      pClient := @FClientArray[Index];
      BufCount := 2;
      NeedLen := HeadLen + DataLen;
      if pClient.UsePkgHead then
      begin
        GetMemEx(Pointer(PkgHead), Sizeof(TPkgHead));
        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(PkgHead);
        EncodePkgHead(PkgHead^, NeedLen, CONST_PKGTYPE_DATA);

        SendBuf[1].len := HeadLen;
        SendBuf[1].Buf := Head;
        SendBuf[2].len := DataLen;
        SendBuf[2].Buf := Data;
        NeedLen := SendBuf[0].len + NeedLen;

        inc(BufCount);
      end
      else
      begin
        SendBuf[0].len := HeadLen;
        SendBuf[0].Buf := Head;
        SendBuf[1].len := DataLen;
        SendBuf[1].Buf := Data;
      end;
      result := SendFinalData(pClient, @SendBuf[0], BufCount, NeedLen);
    finally
      if PkgHead <> nil then
        FreeMemEx(PkgHead);
    end;
  end;

end;

function TTcpClient.SendData(const Index: byte; const Head, Data, Tail: Pointer;
  const HeadLen, DataLen, TailLen: Cardinal): integer;
var
  SendBuf: array [0 .. 3] of WSABUF;
  pClient: PClientContext;
  NeedLen: Cardinal;
  BufCount: Cardinal;
  PkgHead: PPkgHead;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin

    PkgHead := nil;
    try
      pClient := @FClientArray[Index];
      BufCount := 3;
      NeedLen := HeadLen + DataLen + TailLen;
      if pClient.UsePkgHead then
      begin
        GetMemEx(Pointer(PkgHead), Sizeof(TPkgHead));
        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(PkgHead);
        EncodePkgHead(PkgHead^, NeedLen, CONST_PKGTYPE_DATA);

        SendBuf[1].len := HeadLen;
        SendBuf[1].Buf := Head;

        SendBuf[2].len := DataLen;
        SendBuf[2].Buf := Data;

        SendBuf[3].len := TailLen;
        SendBuf[3].Buf := Tail;
        NeedLen := SendBuf[0].len + NeedLen;

        inc(BufCount);
      end
      else
      begin
        SendBuf[0].len := HeadLen;
        SendBuf[0].Buf := Head;
        SendBuf[1].len := DataLen;
        SendBuf[1].Buf := Data;
        SendBuf[2].len := TailLen;
        SendBuf[2].Buf := Tail;
      end;
      result := SendFinalData(pClient, @SendBuf[0], BufCount, NeedLen);
    finally
      if PkgHead <> nil then
        FreeMemEx(PkgHead);
    end;
  end;
end;

function TTcpClient.SendFile(const Index: byte; const FileName: Ansistring; var FileSize: Cardinal;
  const Offset: Cardinal; const Head: Pointer; const HeadLen: Cardinal): integer;
var
  SendBuf: array [0 .. 3] of WSABUF;
  pClient: PClientContext;
  NeedLen: Cardinal;
  BufCount: Cardinal;
  MapHandle, FileHandle: THandle; // 内存映射对象句柄和文件句柄
  RealSize: Cardinal; // 真实的文件大小
  MemPtr: PAnsiChar; //
  PkgHead, pkgHead1: PPkgHead;
begin
  result := CheckValid(Index);
  if result <> CONST_SUCCESS_NO then
    exit;

  pClient := @FClientArray[Index];

  FileHandle := CreateFileA(PAnsiChar(FileName), GENERIC_READ, FILE_SHARE_READ, NiL, OPEN_EXISTING,
    FILE_FLAG_SEQUENTIAL_SCAN, 0);

  if FileHandle = INVALID_HANDLE_VALUE then
  begin
    result := CONST_ERROR_OPENFILE;
    exit;
  end;

  // 获取文件大小
  RealSize := GetFileSize(FileHandle, nil);
  if RealSize = INVALID_HANDLE_VALUE then
  begin
    CloseHandle(FileHandle);
    result := CONST_ERROR_GETFILESIZE;
    exit;
  end;

  if FileSize = 0 then
    FileSize := RealSize;

  if Offset >= RealSize then
  begin
    CloseHandle(FileHandle);
    result := CONST_ERROR_FILEOFFSET;
    exit;
  end;

  // 重新指定偏移
  if FileSize + Offset > RealSize then
    FileSize := RealSize - Offset;

  try // 创建内存映射句柄
    MapHandle := CreateFileMapping(FileHandle, nil, PAGE_READONLY, 0, RealSize, nil);
    if MapHandle = 0 then
    begin
      result := CONST_ERROR_CREATEFILE;
      exit;
    end;
  finally
    CloseHandle(FileHandle);
  end;
  // 映射
  try
    MemPtr := MapViewOfFile(MapHandle, FILE_MAP_READ, 0, Offset, FileSize);
    if MemPtr = nil then
    begin
      result := CONST_ERROR_CREATEFILE;
      exit;
    end;
  finally
    CloseHandle(MapHandle);
  end;

  // 到这里内存映射全部好了，开始发送
  PkgHead := nil;
  pkgHead1 := nil;
  try
    if pClient.UsePkgHead then
    begin
      if (Head <> nil) and (HeadLen > 0) then
      begin
        GetMemEx(Pointer(PkgHead), Sizeof(TPkgHead));
        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(PkgHead);
        EncodePkgHead(PkgHead^, HeadLen, CONST_PKGTYPE_DATA);

        SendBuf[1].len := HeadLen;
        SendBuf[1].Buf := Head;

        GetMemEx(Pointer(pkgHead1), Sizeof(TPkgHead));
        SendBuf[2].len := Sizeof(TPkgHead);
        SendBuf[2].Buf := PAnsiChar(pkgHead1);
        EncodePkgHead(pkgHead1^, FileSize, CONST_PKGTYPE_FILE);

        SendBuf[3].len := FileSize;
        SendBuf[3].Buf := MemPtr;

        NeedLen := SendBuf[0].len + SendBuf[1].len + SendBuf[2].len + SendBuf[3].len;
        BufCount := 4;
      end
      else
      begin

        GetMemEx(Pointer(pkgHead1), Sizeof(TPkgHead));

        SendBuf[0].len := Sizeof(TPkgHead);
        SendBuf[0].Buf := PAnsiChar(pkgHead1);
        EncodePkgHead(pkgHead1^, FileSize, CONST_PKGTYPE_FILE);

        SendBuf[1].len := FileSize;
        SendBuf[1].Buf := MemPtr;

        NeedLen := SendBuf[0].len + SendBuf[1].len;
        BufCount := 2;
      end;
    end
    else
    begin
      if (Head <> nil) and (HeadLen > 0) then
      begin
        SendBuf[0].len := HeadLen;
        SendBuf[0].Buf := Head;

        SendBuf[1].len := FileSize;
        SendBuf[1].Buf := MemPtr;

        NeedLen := SendBuf[0].len + SendBuf[1].len;
        BufCount := 2;
      end
      else
      begin
        SendBuf[0].len := FileSize;
        SendBuf[0].Buf := MemPtr;

        NeedLen := SendBuf[0].len;
        BufCount := 1;
      end;
    end;
    result := SendFinalData(pClient, @SendBuf[0], BufCount, NeedLen);
  finally
    UnmapViewOfFile(MemPtr); // 必须要释放内存映射
    if PkgHead <> nil then
      FreeMemEx(PkgHead);
    if pkgHead1 <> nil then
      FreeMemEx(pkgHead1);
  end;
end;

function TTcpClient.SendFinalData(pClient: PClientContext; Buf: PWSABUF; BufCount, NeedLen: Cardinal): integer;
var
  tSendOverlap: TOverlapped;
  Flags, dRes: Cardinal;

  ErrCode: integer;
begin

  FillChar(tSendOverlap, Sizeof(TOverlapped), #0);
  tSendOverlap.hEvent := CreateEvent(nil, false, false, nil);
  if tSendOverlap.hEvent = INVALID_HANDLE_VALUE then
  begin
    result := CONST_ERROR_SEND_EVENT;
    exit;
  end;
  // {$IfDEF DEBUG}
  // outputdebugstring(PChar(format('SendFinalData发送数据长度:%d %s',[NeedLen,formatdatetime('hh:mm:ss zzz',Now)])));
  // {$ENDIF}
  try
    // times:=GetTickCount;
    if WSASend(pClient.Sock, Buf, BufCount, dRes, 0, @tSendOverlap, nil) <> 0 then
    begin

      ErrCode := WSAGetLastError;
      if (ErrCode = ERROR_IO_PENDING) or (ErrCode = WSAEWOULDBLOCK) then
      begin
        // 等待
        if not WSAGetOverlappedResult(pClient.Sock, @tSendOverlap, dRes, true, Flags) then
        begin // 重叠没有成功
          outputdebugstring(PChar(Format('WSAGetOverlappedResult Error:%d.', [WSAGetLastError()])));
          result := CONST_ERROR_OTHER_OVERLAP_ERROR;
          WriteDebug(Format('WSAGetOverlappedResult Error:%d. [IP=%d  Port=%d]', [WSAGetLastError(), FListenIP, FListenPort]));
          DoDisconnected(pClient);
          pClient.Status := csDisconnecting;
          ReleaseSemaphore(FExitSema, 1, nil);
          exit;
        end;
      end
      else
      begin
        // 说明已经结束
        outputdebugstring(PChar(Format('WSASend Error:%d ', [ErrCode])));
        result := CONST_ERROR_OTHER_OVERLAP_ERROR;
        WriteDebug(Format('WSASend Error:%d  [IP=%d  Port=%d]', [ErrCode, FListenIP, FListenPort]));
        DoDisconnected(pClient);
        pClient.Status := csDisconnecting;
        ReleaseSemaphore(FExitSema, 1, nil);
        exit;
      end;

    end;
    // times:=GetTickCount-times;
    if dRes = NeedLen then
    begin
      result := CONST_SUCCESS_NO;
      // WriteDebug('SendFinalData Used time:'+inttostr(times));

    end
    else
    begin
      // {$IfDEF DEBUG}
      outputdebugstring(PChar(Format('发送不完整，长度：%d  已发送长度:%d', [NeedLen, dRes])));
      // {$ENDIF}
      result := CONST_ERROR_OTHER_OVERLAP_ERROR;
      pClient.Status := csDisconnecting;
      WriteDebug(Format('发送不完整，长度：%d  已发送长度:%d [IP=%d  Port=%d]', [NeedLen, dRes, FListenIP, FListenPort]));
      DoDisconnected(pClient);
      ReleaseSemaphore(FExitSema, 1, nil);
    end;
  finally
    CloseHandle(tSendOverlap.hEvent); // 关闭句柄
  end;
end;

function TTcpClient.StartServer: integer;
begin
  result := CONST_SUCCESS_NO;
  if not FActive then
    try
      // 初始化 Context
      result := InitContext;
      if result <> CONST_SUCCESS_NO then
        exit;

      // 创建 监听
      if FNeedListen then
      begin
        result := CreateListenSock;
        if result <> CONST_SUCCESS_NO then
          exit;
      end;

      // 创建线程开始轮询
      FRecvThread := TRecvThread.Create(self);
      FTimeOutThread := TTimeOutThread.Create(self);
      // FCMDThrd := TCMDSendThrd.create(self);

      FActive := true;

    finally
      if result <> CONST_SUCCESS_NO then
        StopServer;
    end;
end;

function TTcpClient.StopServer: integer;
begin
  FActive := false;
  // 通知线程退出
  if FRecvThread <> nil then
  begin
    FRecvThread.Terminate;
    FRecvThread := nil;
  end;

  if FTimeOutThread <> nil then
  begin
    FTimeOutThread.Terminate;
    FTimeOutThread := nil;
  end;
  if FExitSema <> INVALID_HANDLE_VALUE then
    ReleaseSemaphore(FExitSema, 1, nil);

  if FTimeoutEvent <> INVALID_HANDLE_VALUE then
    SetEvent(FTimeoutEvent); // 通知超时线程退出

  UnInitContext;

  result := CONST_SUCCESS_NO;
end;

function TTcpClient.StartTimeout(const Index: byte; NewTimeOut: Cardinal): integer;
begin
  if not FActive then
  begin
    result := CONST_ERROR_SERVICE_NOT_STARTED;
    exit;
  end;

  if ((index < low(FClientArray)) or (index > high(FClientArray))) then
  begin
    result := CONST_ERROR_INVALID_PARAM_VALUE;
    exit;
  end;

  if (FClientArray[Index].Status <> csConnecting) and (FClientArray[Index].Status <> csConnected) then
  begin
    result := CONST_ERROR_FAIL_CTRL_TIMEOUT;
    exit;
  end;

  FClientArray[Index].MaxTimeout := NewTimeOut;
  FClientArray[Index].Timeout := 0;
  result := CONST_SUCCESS_NO;
end;

function TTcpClient.StopTimeout(const Index: byte): integer;
begin
  if not FActive then
  begin
    result := CONST_ERROR_SERVICE_NOT_STARTED;
    exit;
  end;

  if ((index < low(FClientArray)) or (index > high(FClientArray))) then
  begin
    result := CONST_ERROR_INVALID_PARAM_VALUE;
    exit;
  end;

  if (FClientArray[Index].Status <> csConnecting) and (FClientArray[Index].Status <> csConnected) then
  begin
    result := CONST_ERROR_FAIL_CTRL_TIMEOUT;
    exit;
  end;

  FClientArray[Index].Timeout := -1;
  result := CONST_SUCCESS_NO;
end;

function TTcpClient.CreateListenSock: integer;
var
  pClient: PClientContext;
  Addr: TSockAddr;
  Addrin: PSockAddrIn;
  lenn: integer;
begin
  pClient := @FClientArray[Low(FClientArray)];
  pClient^.Status := csAccept; // 免得被GetFreeContext用掉
  FreeMemEx(pClient^.Buf);

  pClient^.Buf := nil; // 用于接受连接时这个缓冲区没有用
  pClient^.Data := nil;

  pClient^.Sock := WSASocket(AF_INET, SOCK_STREAM, 0, nil, 0, WSA_FLAG_OVERLAPPED);
  if pClient^.Sock = INVALID_SOCKET then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  Addrin := @Addr;
  // 绑定到本机任意ip地址
  Addrin^.sin_family := AF_INET;
  if FListenPort = 0 then
    Addrin^.sin_port := htons(0)
  else
    Addrin^.sin_port := htons(FListenPort);
  Addrin^.sin_addr.S_addr := htonl(INADDR_ANY);

  if bind(pClient^.Sock, Addr, Sizeof(TSockAddrIn)) = SOCKET_ERROR then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  if listen(pClient^.Sock, 5) = SOCKET_ERROR then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  // 获取绑定的端口
  lenn := Sizeof(TSockAddr);
  if getsockname(pClient^.Sock, Addr, lenn) <> 0 then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  FListenPort := htons(Addrin^.sin_port);
  FListenIP := Addrin^.sin_addr.S_addr;

  pClient^.NetEvent := CreateEvent(nil, false, false, nil);
  if pClient^.NetEvent = INVALID_HANDLE_VALUE then
  begin // 事件创建没有成功，要退出
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  // 事件选择没有成功，那么acceptex将得不到投递，因此要退出
  if WSAEventSelect(pClient^.Sock, pClient^.NetEvent, FD_ACCEPT) = SOCKET_ERROR then
  begin
    result := CONST_ERROR_CREATE_SOCKET;
    exit;
  end;

  result := CONST_SUCCESS_NO;
end;

function TTcpClient.UnInitContext: integer;
var
  i: integer;
begin
  EnterCriticalSection(FRTLClient);
  try
    for i := Low(FClientArray) to High(FClientArray) do
    begin
      ReturnContext(@FClientArray[i]);
      DeleteCriticalSection(FClientArray[i].SendRTL);
    end;

    if FExitSema <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FExitSema);
      FExitSema := INVALID_HANDLE_VALUE;
    end;

    if FTimeoutEvent <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FTimeoutEvent);
      FTimeoutEvent := INVALID_HANDLE_VALUE;
    end;

    result := CONST_SUCCESS_NO;
  finally
    LeaveCriticalSection(FRTLClient);
  end;
end;

procedure TTcpClient.WriteDebug(const DebugMsg: string);
begin
  if assigned(FOnWriteDebug) then
    FOnWriteDebug(self, '[TTcpClient] ' + DebugMsg);
end;

function TTcpClient.GetFlags(const Index: integer): integer;
begin
  result := 0;
  if CheckValidFlag(Index) = CONST_SUCCESS_NO then
  begin
    result := FClientArray[Index].OuterFlag;
  end;
end;

function TTcpClient.GetFreeContext: PClientContext;
var
  i: integer;
begin
  EnterCriticalSection(FRTLClient);
  try
    result := nil;
    for i := Low(FClientArray) to High(FClientArray) do
    begin
      if FClientArray[i].Status = csFree then
      begin
        FClientArray[i].Timeout := -1;
        FClientArray[i].Status := csConnecting;
        FClientArray[i].MaxTimeout := 1000;

        GetMemEx(FClientArray[i].Buf, C_IOCP_BUFFER_SIZE); // 指向CONST_BUFFER_LEN长度的指针

        FClientArray[i].Data := FClientArray[i].Buf;
        result := @FClientArray[i];

        break;
      end;
    end;
  finally
    LeaveCriticalSection(FRTLClient);
  end;
end;

function TTcpClient.GetProxyIPByProxyName(const ProxyIP: Ansistring): Cardinal;
var
  IPs: TStringList;
begin
  result := INADDR_NONE;

  IPs := TStringList.Create;
  try
    if GetAllIPByName(ProxyIP, IPs) then
    begin
      if IPs.Count > 0 then
        result := StrToInt64(IPs[0]);
    end;
  finally
    IPs.Free;
  end;
end;

function TTcpClient.InitContext;
var
  i: integer;
begin
  EnterCriticalSection(FRTLClient);
  try
    FExitSema := CreateSemaphore(nil, 0, 2, nil);
    FTimeoutEvent := CreateEvent(nil, false, false, nil);

    ZeroMemory(@FClientArray[1], Sizeof(TClientContext) * (MAXIMUM_WAIT_OBJECTS - 1));
    for i := Low(FClientArray) to High(FClientArray) do
    begin
      with FClientArray[i] do
      begin
        Sock := INVALID_SOCKET; // 套接字
        NetEvent := INVALID_HANDLE_VALUE; // 网络事件
        // DestIP := 0;           //服务器IP
        // DestName := nil;       //服务器名称
        // DestPort := 0;         //目标端口
        OuterFlag := 0; // 外部标志
        Overlap.hEvent := INVALID_HANDLE_VALUE; // 重叠结构   用来接收
        Index := i; // 索引
        // Status:=;              //使用状态
        // OperType:=;            //操作状态,用来控制接收步骤
        // UseProxy:byte;         //是否使用Proxy
        // OwnProto:=true;        //是否使用自定义协议
        // Reserve:byte;          //补齐
        // PkgHead:TPkgHead1;     //自定义的TCP头
        InitializeCriticalSection(SendRTL);
        Buf := nil;
        Data := nil;
        FileHandle := INVALID_HANDLE_VALUE;
      end;
    end;
    result := CONST_SUCCESS_NO;
  finally
    LeaveCriticalSection(FRTLClient);
  end;
end;

function TTcpClient.KeepConnection(const Index: byte): integer;
var
  SendBuf: WSABUF;
  pClient: PClientContext;
  PkgHead: TPkgHead;
begin
  result := CheckValid(Index);
  if result = CONST_SUCCESS_NO then
  begin

    pClient := @FClientArray[Index];
    if not pClient.UsePkgHead then
    begin
      result := CONST_ERROR_INVALID_ACTION;
      exit;
    end;

    SendBuf.len := Sizeof(TPkgHead);
    SendBuf.Buf := @PkgHead;

    EncodePkgHead(PkgHead, 0, CONST_PKGTYPE_HEARTBEAT);

    result := SendFinalData(pClient, @SendBuf, 1, Sizeof(TPkgHead));
  end;
end;

procedure TTcpClient.ReturnContext(pClient: PClientContext);
begin
  EnterCriticalSection(FRTLClient);
  try
    // 先释放资源，最后打空闲标志
    if (pClient^.Data <> nil) then
    begin
      if pClient^.Data <> pClient^.Buf then
        FreeMemEx(pClient^.Data);
      pClient^.Data := nil;
    end;

    if pClient^.Buf <> nil then
    begin
      FreeMemEx(pClient^.Buf);
      pClient^.Buf := nil;
    end;

    if pClient^.DestName <> nil then
    begin
      FreeMemEx(pClient^.DestName);
      pClient^.DestName := nil;
    end;

    if pClient^.NetEvent <> INVALID_HANDLE_VALUE then
    begin
      try
        CloseHandle(pClient^.NetEvent);
      except
      end;
      pClient^.NetEvent := INVALID_HANDLE_VALUE;
    end;

    if pClient^.FileHandle <> INVALID_HANDLE_VALUE then
    begin
      try
        CloseHandle(pClient^.FileHandle);
      except
      end;
      pClient^.FileHandle := INVALID_HANDLE_VALUE;
    end;

    if pClient^.Sock <> INVALID_SOCKET then
    begin
      try
        closesocket(pClient^.Sock);
      except
      end;
      pClient^.Sock := INVALID_SOCKET;
    end;
    // 最后置标志
    pClient^.ProxyLevel := 0;
    pClient^.Status := csFree;
  finally
    LeaveCriticalSection(FRTLClient);
  end;
end;

function TTcpClient.CheckValid(const Index: byte): integer;
begin
  if not FActive then
  begin
    result := CONST_ERROR_SERVICE_NOT_STARTED;
    exit;
  end;

  if ((index < Low(FClientArray)) or (index > High(FClientArray))) then
  begin
    result := CONST_ERROR_INVALID_PARAM_VALUE;
    exit;
  end;

  if FClientArray[Index].Status <> csConnected then
  begin
    result := CONST_ERROR_NOT_CONNECTED;
    exit;
  end;

  result := CONST_SUCCESS_NO;
end;

function TTcpClient.CheckValidFlag(const Index: byte): integer;
begin
  if not FActive then
  begin
    result := CONST_ERROR_SERVICE_NOT_STARTED;
    exit;
  end;

  if ((index < Low(FClientArray)) or (index > High(FClientArray))) then
  begin
    result := CONST_ERROR_INVALID_PARAM_VALUE;
    exit;
  end;

  result := CONST_SUCCESS_NO;
end;

function TTcpClient.ConnectTo(const DestIP: Cardinal; const DestPort: Word; var Index: byte; const Flag: integer;
  const OwnProto, PassProxy: boolean): integer;
var
  pClient: PClientContext;
  Addr: TSockAddr;
  Addrin: PSockAddrIn;
  ErrCode: integer;
begin
  pClient := nil;
  result := CONST_ERROR_CONNECT;
  try
    if not FActive then
    begin
      result := StartServer();
      if result <> CONST_SUCCESS_NO then
        exit;
    end;

    if DestIP = INADDR_NONE then
    begin
      result := CONST_ERROR_INVALID_SERVERIP;
      exit;
    end;

    pClient := GetFreeContext();
    if pClient = nil then
    begin
      result := CONST_ERROR_GET_FREE_SOCKET;
      exit;
    end;

    // 记录参数
    pClient^.DestIP := DestIP;
    pClient^.DestPort := DestPort;
    index := pClient^.Index;
    pClient^.UsePkgHead := OwnProto;
    pClient^.UseProxy := PassProxy;
    pClient^.OuterFlag := Flag;

    FillChar(Addr, Sizeof(Addr), 0);
    Addrin := @Addr;

    Addrin^.sin_family := AF_INET; // 连接类型
    if (FProxyKind = pkNoProxy) or not(PassProxy) then
    begin
      Addrin^.sin_addr.S_addr := DestIP;
      Addrin^.sin_port := htons(DestPort); // 端口
    end
    else
    begin // 有代理连接代理
      Addrin^.sin_port := htons(FProxyPort); // 端口

      if IsValidIP(FProxyIP) then
        Addrin^.sin_addr.S_addr := inet_addr(PAnsiChar(FProxyIP))
      else
        Addrin^.sin_addr.S_addr := GetProxyIPByProxyName(FProxyIP);

      // 无效IP地址
      if Addrin^.sin_addr.S_addr = INADDR_NONE then
      begin
        result := CONST_ERROR_INVALID_SERVERIP;
        exit;
      end;
    end;
    // 创建套接字
    pClient^.Sock := WSASocket(AF_INET, SOCK_STREAM, 0, nil, 0, WSA_FLAG_OVERLAPPED);
    if pClient^.Sock = INVALID_SOCKET then
    begin
      ErrCode := WSAGetLastError;
      WriteDebug(inttostr(ErrCode) + '  / ' + GetErrorMsg(ErrCode, false));
      result := CONST_ERROR_CREATE_SOCKET;
      exit;
    end;

    pClient^.NetEvent := CreateEvent(nil, false, false, nil); // 套接字网络事件
    if WSAEventSelect(pClient.Sock, pClient.NetEvent, FD_CONNECT) = SOCKET_ERROR then
    begin // or FD_READ or FD_CLOSE
      result := CONST_ERROR_CREATE_SOCKET;
      exit;
    end;

    // 调用连接
    ErrCode := Connect(pClient^.Sock, Addr, Sizeof(Addr));
    if ErrCode <> NO_ERROR then
    begin
      ErrCode := WSAGetLastError;
      if ErrCode <> WSAEWOULDBLOCK then
      begin
        if ErrCode = WSAEINTR then
          WriteDebug('Connect fail WSAEINTR');

        result := CONST_ERROR_CONNECT;
        exit;
      end;
    end;

    // 通知线程改变轮询
    ReleaseSemaphore(FExitSema, 1, nil);

    result := CONST_SUCCESS_NO;
  finally
    if (result <> CONST_SUCCESS_NO) and (pClient <> nil) then
      ReturnContext(pClient);
  end;
end;

function TTcpClient.ConnectTo(const DestName: Ansistring; const DestPort: Word; var Index: byte; const Flag: integer;
  const OwnProto, PassProxy: boolean): integer;
var
  IPs: TStringList;
  i: integer;
  pClient: PClientContext;
begin
  result := CONST_ERROR_CONNECT;
  if IsValidIP(DestName) then
  begin
    result := ConnectTo(ConvertIPToDWORD(PAnsiChar(DestName)), DestPort, Index, Flag, OwnProto, PassProxy);
  end
  else
  begin

    IPs := TStringList.Create;
    try
      if not GetAllIPByName(DestName, IPs) then
      begin
        result := CONST_ERROR_HOST_NOT_FOUND;
        exit;
      end;

      for i := 0 to IPs.Count - 1 do
      begin
        // 依次去试
        result := ConnectTo(StrToInt64(IPs[i]), DestPort, Index, Flag, OwnProto, PassProxy);
        if result = CONST_SUCCESS_NO then
        begin
          pClient := @FClientArray[Index];

          // 记下IP
          GetMemEx(pClient^.DestName, length(DestName) + 1);
          Ansistrings.strpcopy(pClient^.DestName, DestName);

          break;
        end;
      end;
    finally
      IPs.Free;
    end;
  end;
end;

{ TRecvThread }

procedure TRecvThread.CallAccept(pClient: PClientContext);
var
  tSock, tEvent: THandle;
  Addr: TSockAddr;
  Addrin: PSockAddrIn;
  addrlen: integer;
  NewClient: PClientContext;
begin
  addrlen := Sizeof(TSockAddr);
  tSock := accept(pClient.Sock, @Addr, @addrlen);
  if tSock = INVALID_SOCKET then
    exit;

  tEvent := CreateEvent(nil, false, false, nil);
  if tEvent = INVALID_HANDLE_VALUE then
  begin
    closesocket(tSock);
    exit;
  end;

  SetNoNagle(tSock);

  if WSAEventSelect(tSock, tEvent, FD_READ or FD_CLOSE) = SOCKET_ERROR then
  begin
    closesocket(tSock);
    CloseHandle(tEvent);
    exit;
  end;

  // 现在连接已经进来了，去获取上下文
  NewClient := FTcpClient.GetFreeContext;
  if NewClient = nil then
  begin
    closesocket(tSock);
    CloseHandle(tEvent);
    exit;
  end;
  Addrin := @Addr;
  // 记录相关信息
  NewClient.Sock := tSock;
  NewClient.DestIP := Addrin^.sin_addr.S_addr;
  NewClient.DestPort := ntohs(Addrin^.sin_port);
  NewClient.UseProxy := false;
  NewClient.Status := csConnected;
  NewClient.NetEvent := tEvent;
  NewClient.ConnTime := now;
  NewClient.UsePkgHead := FTcpClient.FUsePkgHead;
  if NewClient.UsePkgHead then
    NewClient.OperType := otRecvHead
  else
    NewClient.OperType := otRecvData;

  ReBuildWaitArray;
  // 通知连接上来
  FTcpClient.DoAcceptConnect(NewClient, NewClient.DestIP, NewClient.DestPort);

end;

constructor TRecvThread.Create(TcpIoClient: TTcpClient);
begin
  FreeOnTerminate := true;
  FTcpClient := TcpIoClient;
  inherited Create(false);
end;

procedure TRecvThread.DoConnectOver(const ErrCode: integer; pClient: PClientContext);
begin
  FTcpClient.DoConnectOver(ErrCode, pClient);
  if ErrCode <> CONST_SUCCESS_NO then
  begin
    pClient^.Status := csDisconnecting;
    ReBuildWaitArray;
  end;
end;

procedure TRecvThread.DoRecvDataOver(const ErrCode: integer; pClient: PClientContext; const Data: PAnsiChar;
  const DataLen: Cardinal; const UseTime: Double);
begin
  FTcpClient.DoRecvDataOver(ErrCode, pClient, Data, DataLen, UseTime);
  if ErrCode <> CONST_SUCCESS_NO then
  begin
    pClient^.Status := csDisconnecting;
    ReBuildWaitArray;
  end;
end;

procedure TRecvThread.Execute;
var
  i: integer;
  dRes: Cardinal;
begin
  ReBuildWaitArray;

  FRecvEvent := CreateEvent(nil, false, false, nil); // 接收事件
  try
    while not Terminated do
    begin
      dRes := WaitForMultipleObjects(FWaitCount, @FWaitArray, false, INFINITE);

      if Terminated then
        exit;

      case dRes of
        WAIT_OBJECT_0:
          begin // 改变轮询或者退出通知
            if FTcpClient.FActive then
            begin // 有新的套接字加入轮询
              ReBuildWaitArray;
            end
            else
              break;
          end;
        WAIT_TIMEOUT:
          begin // 等待超时

            FTcpClient.WriteDebug('WAIT_TIMEOU');
            break;
          end;
        WAIT_FAILED:
          begin // 等待失败
            FTcpClient.WriteDebug('WAIT_FAILED');
            break;
          end;
      else
        begin // 正儿八经有事情做了
          i := Cardinal(dRes) - WAIT_OBJECT_0;
          // 现在知道是那个句柄有了事件

          // 先处理I，然后再去循环看后面的事件是否也被传信
          HandleOneEvent(FWaitIndex[i]);

          if Terminated then
            exit;

          while i < FWaitCount do
          begin
            dRes := WaitForSingleObject(FWaitIndex[i], 0);
            if dRes = WAIT_OBJECT_0 then
              HandleOneEvent(FWaitIndex[i]);

            inc(i);

            if Terminated then
              exit;
          end;
        end;
      end;
    end;
  finally
    CloseHandle(FRecvEvent)
  end;
end;

procedure TRecvThread.StartNegociateWithProxy(pClient: PClientContext);
var
  ConnStr, sip: Ansistring;
  ErrCode: integer;
  SendBuf: WSABUF;
begin
  case pClient^.ProxyKind^ of
    pkHTTPProxy:
      begin
        sip := ConvertDWORDToIP(pClient^.ProxyDestIP);

        ConnStr := 'CONNECT ' + Ansistring(sip) + ':' + Ansistring(inttostr(pClient^.ProxyDestPort)) + ' HTTP/1.1' +
          #13#10 + 'User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)' + #13#10 + 'Host: ' + Ansistring(sip)
          + #13#10 + 'Content-Length: 0' + #13#10 + 'Proxy-Connection: Keep-Alive' + #13#10 + 'Pragma: no-cache' + #13#10;

        if pClient^.ProxyUser^ <> '' then
        begin // 提供了用户名和密码
          ConnStr := ConnStr + 'Proxy-Authorization: Basic ' +
            Ansistring(EncdDecd.EncodeString(string(pClient^.ProxyUser^ + ':' + pClient^.ProxyPwd^))) + #13#10;
        end;

        ConnStr := ConnStr + #13#10;
        Ansistrings.strpcopy(pClient^.Buf, ConnStr);
        SendBuf.len := length(ConnStr);
        SendBuf.Buf := pClient^.Buf;

        // 修改状态，以便继续协商
        pClient^.OperType := otProxy1;
        // 发送，而且要等到发送结束
        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // 激活连接失败
          DoConnectOver(ErrCode, pClient);
        end;
      end;

    pkSOCKS5Proxy:
      begin
        pClient^.Buf[0] := #5; // SOCKS版本5
        pClient^.Buf[1] := #2; // 支持2种方法
        pClient^.Buf[2] := #0; // 方法1：无认证
        pClient^.Buf[3] := #2; // 方法2：用户和口令验证
        SendBuf.len := 4;
        SendBuf.Buf := pClient^.Buf;
        // 修改状态，以便继续协商
        pClient^.OperType := otProxy1;
        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // 激活连接失败
          DoConnectOver(ErrCode, pClient);
        end;
      end;

    pkSOCKS4Proxy:
      begin
        // 向代理服务器发送socks4协商
        pClient^.Buf[0] := #4; // SOCKS版本4   1字节
        pClient^.Buf[1] := #1; // Connect请求  1字节
        PWord(@pClient^.Buf[2])^ := htons(pClient^.ProxyDestPort); // 服务器端口2字节
        PCardinal(@pClient^.Buf[4])^ := pClient^.ProxyDestIP; // 服务器ip4字节
        if pClient^.ProxyUser^ <> '' then // 提供了用户
          CopyMemory(@pClient^.Buf[8], @(pClient^.ProxyUser^[1]), length(pClient^.ProxyUser^));
        pClient^.Buf[8 + length(pClient^.ProxyUser^)] := #0; // 结尾
        SendBuf.len := 9 + length(pClient^.ProxyUser^);
        SendBuf.Buf := pClient^.Buf;
        // 修改状态，以便继续协商
        pClient^.OperType := otProxy1;
        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // 激活连接失败
          DoConnectOver(ErrCode, pClient);
        end;
      end;
  end;
end;

procedure TRecvThread.StartRecvFile(pClient: PClientContext; SaveName: Ansistring; Offset: Cardinal);
var
  ExistsFlag: boolean;
  FileSize: Cardinal;
begin
  // 开始接收文件
  // 文件名记录在Data里
  GetMemEx(pClient^.Data, length(SaveName) + 1);
  Ansistrings.strpcopy(pClient^.Data, SaveName);
  pClient^.Offset := Offset;

  // 简单点，用同步方式去写文件，不然还要区分操作系统，因为98不支持重叠读写文件
  if not ForceDirectories(ExtractFilePath(string(SaveName))) then
  begin // 创建文件目录失败
    FTcpClient.DoRecvFileOver(CONST_ERROR_NO_SUCH_DIR, pClient, SaveName, 0, 0, 0, 0);
    OnlyDisconnect(pClient);
    exit;
  end;
  ExistsFlag := FileExists(string(SaveName));

  pClient^.FileHandle := CreateFileA(pClient^.Data, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_ALWAYS,
    FILE_ATTRIBUTE_NORMAL, 0);
  if pClient^.FileHandle = HFILE_ERROR then
  begin // 创建文件目录失败
    FTcpClient.DoRecvFileOver(CONST_ERROR_OPENFILE, pClient, SaveName, pClient^.TotalLen, 0, Offset, 0);
    OnlyDisconnect(pClient);
    exit;
  end;

  if ExistsFlag then
  begin
    FileSize := GetFileSize(pClient^.FileHandle, nil);
    if Offset > FileSize then
    begin
      CloseHandle(pClient^.FileHandle);
      FTcpClient.DoRecvFileOver(CONST_ERROR_FILEOFFSET, pClient, SaveName, pClient^.TotalLen, 0, Offset, 0);
      OnlyDisconnect(pClient);
      exit;
    end;
    if SetFilePointer(pClient^.FileHandle, Offset, nil, FILE_BEGIN) = $FFFFFFFF then
    begin
      CloseHandle(pClient^.FileHandle);
      FTcpClient.DoRecvFileOver(CONST_ERROR_FILEOFFSET, pClient, SaveName, pClient^.TotalLen, 0, Offset, 0);
      OnlyDisconnect(pClient);
      exit;
    end;
  end;

  // ok，文件已经打开，置接收标志
  pClient^.OperType := otRecvFile;
  pClient^.FinishLen := 0;
end;

procedure TRecvThread.HandleConnOver(pClient: PClientContext);
begin
  SetNoNagle(pClient.Sock);

  // 重新关联事件，因为原来只关联了FD_CONNECT
  if WSAEventSelect(pClient.Sock, pClient.NetEvent, FD_READ or FD_CLOSE) = SOCKET_ERROR then
  begin
    pClient.Status := csDisconnecting;
    exit;
  end;

  if FTcpClient.FProxyKind = pkNoProxy then
  begin // 不使用代理
    pClient.Status := csConnected;
    pClient.ConnTime := now;
    if pClient.UsePkgHead then
      pClient.OperType := otRecvHead
    else
      pClient.OperType := otRecvData;
    // 通知连接成功
    DoConnectOver(CONST_SUCCESS_NO, pClient);
  end
  else
  begin // 还要过代理

    if pClient.UseProxy then
    begin
      // 开始代理协商
      pClient^.OperType := otProxy1;

      // 连接服务器IP
      if FTcpClient.FProxyKind2 <> pkNoProxy then
      begin
        if IsValidIP(FTcpClient.FProxyIP2) then
          pClient^.ProxyDestIP := inet_addr(PAnsiChar(FTcpClient.FProxyIP2))
        else
          pClient^.ProxyDestIP := FTcpClient.GetProxyIPByProxyName(FTcpClient.FProxyIP2);
        pClient^.ProxyDestPort := FTcpClient.FProxyPort2;
      end
      else
      begin
        pClient^.ProxyDestIP := pClient^.DestIP;
        pClient^.ProxyDestPort := pClient^.DestPort;
      end;

      pClient^.ProxyKind := @FTcpClient.FProxyKind;
      pClient^.ProxyUser := @FTcpClient.FProxyUser; // 代理用户
      pClient^.ProxyPwd := @FTcpClient.FProxyPwd; // 代理口令

      StartNegociateWithProxy(pClient);
    end
    else
    begin
      pClient.Status := csConnected;
      pClient.ConnTime := now;
      if pClient.UsePkgHead then
        pClient.OperType := otRecvHead
      else
        pClient.OperType := otRecvData;
      // 通知连接成功
      DoConnectOver(CONST_SUCCESS_NO, pClient);
    end;
  end;
end;

procedure TRecvThread.HandleFileArrive(pClient: PClientContext);
var
  SaveName: Ansistring;
  Offset: Cardinal;
begin
  SaveName := '';
  try
    FTcpClient.DoRecvFileQuery(pClient, SaveName, Offset);
  except
    DoRecvDataOver(CONST_ERROR_NO_FILE_ARRIVE, pClient, nil, 0, 0);
    exit;
  end;

  if SaveName <> '' then
    StartRecvFile(pClient, SaveName, Offset)
  else
    DoRecvDataOver(CONST_ERROR_NO_FILE_ARRIVE, pClient, nil, 0, 0);
end;

procedure TRecvThread.HandleOneEvent(const Index: byte);
var
  pClient: PClientContext;
  we: TWSANetworkEvents; // 网络事件
  dRes: Cardinal;
begin
  pClient := @FTcpClient.FClientArray[index];
  // 先枚举网络事件，然后根据网络事件来分支处理
  dRes := WSAEnumNetworkEvents(pClient.Sock, pClient^.NetEvent, we);
  if dRes = NO_ERROR then
  begin
    if (we.lNetworkEvents and FD_READ = FD_READ) then
    begin
      if we.iErrorCode[FD_READ_BIT] = NO_ERROR then
      begin // 有数据可以读
        case pClient^.OperType of
          otProxy1:
            RecvProxyRes1(pClient);
          otProxy2: // 接收代理协商第1步响应，发送第2步
            RecvProxyRes2(pClient);
          otProxy3: // 接收代理协商第2步响应，发送第3步
            RecvProxyRes3(pClient);
          otRecvHead: // 接收头
            HandleRecvHead(pClient);
          otRecvBody: // 接收体
            HandleRecvBody(pClient);
          otRecvFile: // 接收文件块
            HandleRecvFile(pClient);
          otRecvData: // 收到数据体
            HandleRecvData(pClient);
        end;
      end
      else
      begin // 读数据错误了
        // 激活一个连接断开事件，然后释放连接
        if pClient.Status = csConnected then
          DoRecvDataOver(TransferWinsockError(we.iErrorCode[FD_READ_BIT]), pClient, nil, 0, 0)
        else
          DoConnectOver(TransferWinsockError(we.iErrorCode[FD_READ_BIT]), pClient);
      end;
    end
    else if (we.lNetworkEvents and FD_CONNECT) = FD_CONNECT then
    begin
      if we.iErrorCode[FD_CONNECT_BIT] = NO_ERROR then
      begin
        HandleConnOver(pClient);
      end
      else
      begin // 激活一个连接失败事件，然后释放连接
        TransferWinsockError(we.iErrorCode[FD_CONNECT_BIT]);
        FTcpClient.WriteDebug('[TRecvThread]连接目标失败:' + inttostr(we.iErrorCode[FD_CONNECT_BIT]) + '/' +
          string(ConvertDWORDToIP(pClient.DestIP)) + '/' + inttostr(pClient.DestPort));
        DoConnectOver(TransferWinsockError(we.iErrorCode[FD_CONNECT_BIT]), pClient);
      end;
    end
    else if (we.lNetworkEvents and FD_CLOSE) = FD_CLOSE then
    begin // 连接被关了
      if pClient.Status = csConnected then
      begin
        FTcpClient.WriteDebug('[TRecvThread] 连接被关了');
        FTcpClient.DoDisconnected(pClient);
        OnlyDisconnect(pClient);
      end
      else
        DoConnectOver(CONST_ERROR_REMOTE_DISCONNECT, pClient);
    end
    else if (we.lNetworkEvents and FD_ACCEPT) = FD_ACCEPT then
    begin // 有连接进来
      if we.iErrorCode[FD_ACCEPT_BIT] = NO_ERROR then
        CallAccept(pClient);
    end;
    // 其他网络事件不可能
  end
  else
  begin
    // 激活一个连接断开事件，然后释放连接
  end;
end;

procedure TRecvThread.HandleRecvBody(pClient: PClientContext);
var
  Flag, RecvLen: Cardinal;
  ErrorCode: Cardinal;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := pClient^.TotalLen - pClient^.FinishLen;
  if RecvBuf.len > C_IOCP_BUFFER_SIZE then
    RecvBuf.len := C_IOCP_BUFFER_SIZE;

  RecvBuf.Buf := @pClient^.Data[pClient^.FinishLen];

  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  RecvLen := 0;

  // FTcpClient.WriteDebug('HandleRecvBody WSARecv Len:' + Inttostr(RecvBuf.len));

  if WSARecv(pClient^.Sock, @RecvBuf, 1, RecvLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
  begin
    // 接收失败
    ErrorCode := WSAGetLastError;
    if ((ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, RecvLen, true, Flag) then
      begin
        ErrorCode := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Body Error 1:' + inttostr(ErrorCode));
        DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, pClient^.Data, pClient^.FinishLen, 0);
        exit;
      end;
    end
    else
    begin
      // 激活接收失败
      FTcpClient.WriteDebug('Recv Body Error 2:' + inttostr(ErrorCode));
      DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, pClient^.Data, pClient^.FinishLen, 0);
      exit;
    end;
  end;

  // 这里实际上不能这么判断，因为可能收不够这么多
  if RecvLen = 0 then
  begin
    // 激活接收失败
    // DoRecvDataOver(CONST_ERROR_REMOTE_DISCONNECT, pClient, pClient^.Data,pClient^.FinishLen,0);
    exit;
  end;

  // 调整偏移
  pClient^.FinishLen := pClient^.FinishLen + RecvLen;

  if pClient^.FinishLen = pClient^.TotalLen then
  begin
    // 激活接收成功
    DoRecvDataOver(CONST_SUCCESS_NO, pClient, pClient^.Data, pClient^.TotalLen, (now - pClient^.RecvTime) * 86400);
    if Terminated then
      exit;

    // 看是否要释放内存
    if pClient^.Data <> pClient^.Buf then
    begin
      FreeMemEx(pClient^.Data);
      pClient^.Data := pClient^.Buf;
    end;
    // 重新开始接收
    pClient^.OperType := otRecvHead;
    pClient^.TotalLen := 0;
  end;
end;

procedure TRecvThread.HandleRecvData(pClient: PClientContext);
var
  Flag: Cardinal;
  ErrorCode: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient^.Buf;

  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  if WSARecv(pClient^.Sock, @RecvBuf, 1, pClient^.TotalLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
  begin
    // 接收失败
    ErrorCode := WSAGetLastError;
    if ((ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, pClient^.TotalLen, true, Flag) then
      begin
        ErrorCode := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Data Error 1:' + inttostr(ErrorCode));
        DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, nil, 0, 0);
        exit;
      end;
      // 正确的就不管了
    end
    else
    begin
      // 激活接收失败
      DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, nil, 0, 0);
      FTcpClient.WriteDebug('Recv Data Error:' + inttostr(ErrorCode));
      exit;
    end;
  end;
  // 这里实际上不能这么判断，因为可能收不够这么多
  if pClient^.TotalLen = 0 then
  begin
    // 激活接收失败
    // DoRecvDataOver(CONST_ERROR_REMOTE_DISCONNECT, pClient, nil, 0, 0);
    exit;
  end;
  // 提交数据
  DoRecvDataOver(CONST_SUCCESS_NO, pClient, pClient^.Buf, pClient^.TotalLen, 0);
end;

procedure TRecvThread.HandleRecvFile(pClient: PClientContext);
var
  Flag, RecvLen, WriteLen: Cardinal;
  ErrorCode: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient^.Buf;

  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;

  if RecvBuf.len > pClient^.TotalLen - pClient^.FinishLen then
    RecvBuf.len := pClient^.TotalLen - pClient^.FinishLen;

  RecvBuf.Buf := pClient^.Buf;
  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  RecvLen := 0;
  if WSARecv(pClient^.Sock, @RecvBuf, 1, RecvLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
  begin
    // 接收失败
    ErrorCode := WSAGetLastError;
    if ((ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, RecvLen, true, Flag) then
      begin
        ErrorCode := WSAGetLastError;
        FTcpClient.WriteDebug('Recv File Error:' + inttostr(ErrorCode));
        FTcpClient.DoRecvFileOver(CONST_ERROR_RECV_FAIL, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen,
          pClient^.Offset, (now - pClient.RecvTime) * 86400);
        OnlyDisconnect(pClient);
        exit;
      end;
    end
    else
    begin
      FTcpClient.WriteDebug('Recv File Error:' + inttostr(ErrorCode));
      // 激活接收文件失败
      FTcpClient.DoRecvFileOver(CONST_ERROR_RECV_FAIL, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen,
        pClient^.Offset, (now - pClient.RecvTime) * 86400);
      OnlyDisconnect(pClient);
      exit;
    end;
  end;
  // 这里实际上不能这么判断，因为可能收不够这么多
  if RecvLen = 0 then
  begin // 激活接收文件失败
    // 激活接收文件失败
    // FTcpClient.DoRecvFileOver(CONST_ERROR_REMOTE_DISCONNECT, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen, pClient^.Offset, (now - pClient.RecvTime)*86400);
    // OnlyDisconnect(pClient);
    exit;
  end;
  // 写文件
  if not(WriteFile(pClient^.FileHandle, pClient^.Buf[0], RecvLen, WriteLen, nil)) or (WriteLen <> RecvLen) then
  begin
    // 激活接收文件失败
    FTcpClient.DoRecvFileOver(CONST_ERROR_WRITEFILE, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen,
      pClient^.Offset, (now - pClient.RecvTime) * 86400);
    OnlyDisconnect(pClient);
    exit;
  end;

  // 调整偏移
  pClient^.FinishLen := pClient^.FinishLen + RecvLen;
  if pClient^.FinishLen = pClient^.TotalLen then
  begin // 收完了
    CloseHandle(pClient^.FileHandle);
    pClient^.FileHandle := INVALID_HANDLE_VALUE;
    // 激活接收文件失败
    FTcpClient.DoRecvFileOver(CONST_SUCCESS_NO, pClient, pClient^.Data, pClient^.TotalLen, pClient^.FinishLen,
      pClient^.Offset, (now - pClient.RecvTime) * 86400);
    // 释放pClient^.Data  文件名
    FreeMemEx(pClient^.Data);
    pClient^.Data := pClient^.Buf;
    pClient^.OperType := otRecvHead; // 重新回到接收头的状态
  end;
end;

procedure TRecvThread.HandleRecvHead(pClient: PClientContext);
var
  ErrorCode: integer;
  FinishLen: Cardinal;
  FBuff: PWSABUF;
  Flag, RecvLen: Cardinal;
begin
  // 微软他妈的真是有意思，这里buff只能是这样申请
  GetMemEx(Pointer(FBuff), Sizeof(WSABUF));
  try
    FBuff.len := Sizeof(TPkgHead);
    FBuff.Buf := @pClient^.PkgHead;
    FinishLen := 0;
    FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
    pClient^.Overlap.hEvent := FRecvEvent;

    Flag := 0;
    RecvLen := 0;
    while not Terminated do
    begin

      // 客户端套接字 //接收缓冲区  //缓冲区个数
      if WSARecv(pClient^.Sock, FBuff, 1, RecvLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
      begin

        // 接收失败
        ErrorCode := WSAGetLastError;
        if (ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK) then
        begin
          Flag := 0;
          if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, RecvLen, true, Flag) then
          begin
            ErrorCode := WSAGetLastError;
            FTcpClient.WriteDebug('Recv Head Error 1:' + inttostr(ErrorCode));
            DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, nil, 0, 0);
            exit;
          end; // 正确的就不管了
        end
        else
        begin
          // 激活接收失败
          DoRecvDataOver(TransferWinsockError(ErrorCode), pClient, nil, 0, 0);
          FTcpClient.WriteDebug('Recv Head Error 2:' + inttostr(ErrorCode));
          exit;
        end;
      end;
      FinishLen := FinishLen + RecvLen;

      // 收完退出
      if FinishLen = Sizeof(TPkgHead) then
        break
      else
      begin
        FBuff^.len := Sizeof(TPkgHead) - FinishLen;
        FBuff^.Buf := @PAnsiChar(@pClient^.PkgHead)[FinishLen];
        FTcpClient.WriteDebug('Recv Head :' + inttostr(FinishLen));

      end;
    end;
  finally
    FreeMemEx(FBuff);
  end;

  // 这里实际上不能这么判断，因为可能收不够这么多
  if FinishLen <> Sizeof(TPkgHead) then
  begin
    // 激活接收失败
    DoRecvDataOver(CONST_ERROR_REMOTE_DISCONNECT, pClient, nil, 0, 0);

  end
  else
  begin
    // 解包头
    if FTcpClient.DecodePkgHead(pClient^.PkgHead) <> CONST_SUCCESS_NO then
    begin
      // 寻找数据头
      DoRecvDataOver(CONST_ERROR_INVALID_PKG_FLAG, pClient, nil, 0, 0);
      // pClient^.OperType := otRecvFindHead;
      exit;
    end;

    // 解析报文，准备接收报文体

    // 自定义头中得到 总的接收长变
    pClient^.TotalLen := pClient^.PkgHead.DataLen;
    // 得到 包类型
    // DataKind := pClient^.PkgHead.PkgKind;
    pClient^.RecvTime := now;

    // if datakind = CONST_PKGTYPE_FILE then begin
    // //文件来了
    // HandleFileArrive(pClient);
    // end else if DataKind = CONST_PKGTYPE_HEARTBEAT then begin
    // //心跳包
    //
    // end else begin
    // 申请内存
    if (pClient^.TotalLen > C_IOCP_BUFFER_SIZE) then
    begin

      GetMemEx(pClient^.Data, pClient^.TotalLen);
      if pClient^.Data = nil then
      begin
        DoRecvDataOver(CONST_ERROR_ALLOC_MEMORY, pClient, nil, 0, 0);
        exit;
      end;
    end
    else
      pClient^.Data := pClient^.Buf;

    pClient^.FinishLen := 0;
    pClient^.OperType := otRecvBody;
  end;
  // end;
end;

procedure TRecvThread.OnlyDisconnect(pClient: PClientContext);
begin
  pClient^.Status := csDisconnecting;
  ReBuildWaitArray;
end;

procedure TRecvThread.ReBuildWaitArray;
var
  i, Index: integer;
  pClient: PClientContext;
begin
  FWaitArray[0] := FTcpClient.FExitSema; // 0始终是退出事件和重组通知
  FWaitCount := 1; // 最开始只有一个可等待句柄
  Index := Low(FTcpClient.FClientArray);

  // 是否要监听
  if FTcpClient.FNeedListen then
  begin
    FWaitArray[1] := FTcpClient.FClientArray[Low(FTcpClient.FClientArray)].NetEvent;
    FWaitIndex[1] := Low(FTcpClient.FClientArray);
    inc(FWaitCount);
    inc(Index);
  end;

  for i := Index to High(FTcpClient.FClientArray) do
  begin
    if FTcpClient.FClientArray[i].Status <> csFree then
    begin
      pClient := @FTcpClient.FClientArray[i];
      case pClient^.Status of
        csConnecting, csConnected:
          begin
            // wate INVALID_HANDLE_VALUE 时会等不东西
            if FTcpClient.FClientArray[i].NetEvent <> INVALID_HANDLE_VALUE then
            begin
              FWaitArray[FWaitCount] := FTcpClient.FClientArray[i].NetEvent;
              FWaitIndex[FWaitCount] := FTcpClient.FClientArray[i].Index;
              inc(FWaitCount);
            end;
          end;
        csDisconnecting: // 这个连接要释放
          FTcpClient.ReturnContext(pClient);
      end;
    end;
  end;

end;

procedure TRecvThread.RecvProxyRes1(pClient: PClientContext);
var
  Flag: Cardinal;
  ErrorCode: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient^.Buf;
  FillChar(pClient^.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  if WSARecv(pClient^.Sock, @RecvBuf, 1, pClient^.TotalLen, Flag, @pClient^.Overlap, nil) <> NO_ERROR then
  begin
    ErrorCode := WSAGetLastError;
    if ((ErrorCode = ERROR_IO_PENDING) or (ErrorCode = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient^.Sock, @pClient^.Overlap, pClient^.TotalLen, true, Flag) then
      begin
        ErrorCode := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Proxy Res1 Error 1:' + inttostr(ErrorCode));
        DoConnectOver(TransferWinsockError(ErrorCode), pClient);
        exit;
      end;
      // 正确的就不管了
    end
    else
    begin
      // 激活连接失败
      DoConnectOver(TransferWinsockError(ErrorCode), pClient);
      FTcpClient.WriteDebug('Recv Proxy Res1 Error 2:' + inttostr(ErrorCode));
      exit;
    end;
  end;

  // 这里收到代理的第1次响应

  case pClient^.ProxyKind^ of
    pkHTTPProxy:
      begin

        // 先看有没有收齐响应
        if not IsWholeHTTPResponse(pClient^.Buf, pClient^.TotalLen) then
        begin
          // 激活连接失败
          DoConnectOver(CONST_ERROR_PROXY_DENY, pClient);
          exit;
        end;
        // 收齐了，看响应是否是成功
        if (pos(Ansistring('HTTP/1.1 200 '), AnsiUpperCase(string(pClient^.Buf))) = 1) or
          (pos(Ansistring('HTTP/1.0 200 '), AnsiUpperCase(string(pClient^.Buf))) = 1) then
        begin
          if (FTcpClient.ProxyKind2 <> pkNoProxy) and (pClient^.ProxyLevel <> 2) then
          begin
            // 开始代理协商
            pClient^.OperType := otProxy1;

            pClient^.ProxyDestIP := pClient^.DestIP;
            pClient^.ProxyDestPort := pClient^.DestPort;
            pClient^.ProxyKind := @FTcpClient.FProxyKind2;
            pClient^.ProxyUser := @FTcpClient.FProxyUser2; // 代理用户
            pClient^.ProxyPwd := @FTcpClient.FProxyPwd2; // 代理口令
            pClient^.ProxyLevel := 2;
            StartNegociateWithProxy(pClient);
          end
          else
          begin

            pClient^.ConnTime := now;
            pClient^.Status := csConnected;

            if pClient^.UsePkgHead then
              pClient^.OperType := otRecvHead
            else
              pClient^.OperType := otRecvData;
            // 激活连接成功
            DoConnectOver(CONST_SUCCESS_NO, pClient);
          end;
        end
        else
        begin
          // 激活连接失败
          DoConnectOver(CONST_ERROR_CONNECT, pClient);
        end;

      end;
    pkSOCKS4Proxy:
      begin
        // 解答服务器的反馈
        if (pClient^.TotalLen <> 8) or (pClient^.Buf[0] <> #0) then
        begin
          // 激活连接失败
          DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          exit;
        end;
        case pClient^.Buf[1] of
          #90:
            begin
              if (FTcpClient.ProxyKind2 <> pkNoProxy) and (pClient^.ProxyLevel <> 2) then
              begin
                // 开始代理协商
                pClient^.OperType := otProxy1;
                pClient^.ProxyDestIP := pClient^.DestIP;
                pClient^.ProxyDestPort := pClient^.DestPort;
                pClient^.ProxyKind := @FTcpClient.FProxyKind2;
                pClient^.ProxyUser := @FTcpClient.FProxyUser2; // 代理用户
                pClient^.ProxyPwd := @FTcpClient.FProxyPwd2; // 代理口令
                pClient^.ProxyLevel := 2;
                StartNegociateWithProxy(pClient);
              end
              else
              begin
                pClient^.ConnTime := now;
                pClient^.Status := csConnected;
                if pClient^.UsePkgHead then
                  pClient^.OperType := otRecvHead
                else
                  pClient^.OperType := otRecvData;
                // 激活连接成功
                DoConnectOver(CONST_SUCCESS_NO, pClient);
              end;
            end;
          #91:
            begin
              // 激活连接失败
              DoConnectOver(CONST_ERROR_PROXY_DENY, pClient);
            end;
          #93:
            begin
              // 激活连接失败
              DoConnectOver(CONST_ERROR_PROXY_AUTHENTICATE, pClient);
            end;
        else
          begin
            // 激活连接失败
            DoConnectOver(CONST_ERROR_CONNECT, pClient);
          end;
        end; // end case
      end;
    pkSOCKS5Proxy:
      begin
        if (pClient^.TotalLen <> 2) or (pClient^.Buf[0] = #255) then
        begin
          // 激活连接失败
          DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          exit;
        end;

        case pClient^.Buf[1] of
          #0:
            begin // 去发送第3个请求，直接连接

              // 发送第3步协商，因为它没有身份认证
              SendProxy3(pClient);
            end;
          #2:
            begin // 发送第2个请求进行身份验证

              // 发送第2步协商，因为它要求身份认证
              SendProxy2(pClient);
            end;
        else
          begin
            // 激活连接失败
            DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          end;
        end; //
      end;
  end;
end;

procedure TRecvThread.RecvProxyRes2(pClient: PClientContext);
var
  Flag: Cardinal;
  i: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient.Buf;
  FillChar(pClient.Overlap, Sizeof(TOverlapped), #0);
  pClient.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  if WSARecv(pClient.Sock, @RecvBuf, 1, pClient.TotalLen, Flag, @pClient.Overlap, nil) <> NO_ERROR then
  begin

    i := WSAGetLastError;
    if ((i = ERROR_IO_PENDING) or (i = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient.Sock, @pClient.Overlap, pClient.TotalLen, true, Flag) then
      begin
        i := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Proxy Res2 Error 1:' + inttostr(i));
        DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
        exit;
      end;
      // 正确的就不管了
    end
    else
    begin
      // 激活连接失败
      DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
      FTcpClient.WriteDebug('Recv Proxy Res2 Error 2:' + inttostr(i));
      exit;
    end;
  end;
  // 这里收到代理的第2次响应
  case FTcpClient.FProxyKind of
    pkSOCKS5Proxy:
      begin
        if (pClient.TotalLen <> 2) then
        begin
          // CONST_ERROR_PROXY_NEGOTIATE
          // 激活连接失败
          DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          exit;
        end;
        if (pClient.Buf[1] <> #0) then
        begin
          // 激活连接失败
          DoConnectOver(CONST_ERROR_PROXY_AUTHENTICATE, pClient);
          exit;
        end;
        // 发送终极连接请求
        SendProxy3(pClient);
      end;
  end;
end;

procedure TRecvThread.RecvProxyRes3(pClient: PClientContext);
var
  Flag: Cardinal;
  i: integer;
  RecvBuf: WSABUF;
begin
  RecvBuf.len := C_IOCP_BUFFER_SIZE;
  RecvBuf.Buf := pClient.Buf;
  FillChar(pClient.Overlap, Sizeof(TOverlapped), #0);
  pClient.Overlap.hEvent := FRecvEvent;
  Flag := 0;
  if WSARecv(pClient.Sock, @RecvBuf, 1, pClient.TotalLen, Flag, @pClient.Overlap, nil) <> NO_ERROR then
  begin

    i := WSAGetLastError;
    if ((i = ERROR_IO_PENDING) or (i = WSAEWOULDBLOCK)) then
    begin
      Flag := 0;
      if not WSAGetOverlappedResult(pClient.Sock, @pClient.Overlap, pClient.TotalLen, true, Flag) then
      begin
        i := WSAGetLastError;
        FTcpClient.WriteDebug('Recv Proxy Res3 Error 1:' + inttostr(i));
        DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
        exit;
      end;
      // 正确的就不管了
    end
    else
    begin
      // 激活连接失败
      DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
      FTcpClient.WriteDebug('Recv Proxy Res3 Error:' + inttostr(i));
      exit;
    end;
  end;
  // 这里收到代理的第3次响应
  case FTcpClient.FProxyKind of
    pkSOCKS5Proxy:
      begin // 只有SOCKS5代理会到这一步

        if pClient.TotalLen <> 10 then
        begin
          // 激活连接失败
          DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          exit;
        end;

        case pClient.Buf[1] of
          #0:
            begin // 连接成功
              if (FTcpClient.ProxyKind2 <> pkNoProxy) and (pClient^.ProxyLevel <> 2) then
              begin
                // 开始代理协商
                pClient^.OperType := otProxy1;
                pClient^.ProxyDestIP := pClient^.DestIP;
                pClient^.ProxyDestPort := pClient^.DestPort;
                pClient^.ProxyKind := @FTcpClient.FProxyKind2;
                pClient^.ProxyUser := @FTcpClient.FProxyUser2; // 代理用户
                pClient^.ProxyPwd := @FTcpClient.FProxyPwd2; // 代理口令
                pClient^.ProxyLevel := 2;
                StartNegociateWithProxy(pClient);
              end
              else
              begin
                pClient.ConnTime := now;
                pClient.Status := csConnected;
                if pClient.UsePkgHead then
                  pClient.OperType := otRecvHead
                else
                  pClient.OperType := otRecvData;

                // 激活连接成功
                DoConnectOver(CONST_SUCCESS_NO, pClient);
              end;

            end;
          #3:
            begin
              // 激活连接失败
              DoConnectOver(CONST_ERROR_NETWORK_DAMAGE, pClient);
            end;
          #4:
            begin
              // 激活连接失败
              DoConnectOver(CONST_ERROR_HOST_POWEROFF, pClient);
            end;
          #5:
            begin
              // 激活连接失败
              DoConnectOver(CONST_ERROR_HOST_DENY, pClient);
            end;
        else
          begin
            // 激活连接失败
            DoConnectOver(CONST_ERROR_PROXY_NEGOTIATE, pClient);
          end;
        end; // end case
      end;
  end;
end;

procedure TRecvThread.SendProxy2(pClient: PClientContext);
var
  SendBuf: WSABUF;
  ErrCode: integer;
begin
  case pClient^.ProxyKind^ of
    pkSOCKS5Proxy:
      begin
        pClient.Buf[0] := #1; // 第1字节
        // 第2字节为用户名长度
        pClient.Buf[1] := AnsiChar(byte(length(pClient^.ProxyUser^)));

        // 第3字节起为用户名
        CopyMemory(@pClient.Buf[2], @pClient^.ProxyUser^[1], byte(pClient.Buf[1]));

        // 紧跟用户名的是口令长度
        pClient.Buf[byte(pClient.Buf[1]) + 2] := AnsiChar(byte(length(pClient^.ProxyPwd^)));
        // 口令长度后面是口令
        CopyMemory(@pClient.Buf[byte(pClient.Buf[1]) + 3], @pClient^.ProxyPwd^[1],
          byte(pClient.Buf[byte(pClient.Buf[1]) + 2]));

        SendBuf.len := byte(pClient.Buf[1]) + 3 + byte(pClient.Buf[byte(pClient.Buf[1]) + 2]);
        SendBuf.Buf := pClient.Buf;
        // 修改状态，以便继续协商

        pClient.OperType := otProxy2;

        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // 激活连接失败
          DoConnectOver(ErrCode, pClient);
        end;
      end;
  end;
end;

procedure TRecvThread.SendProxy3(pClient: PClientContext);
var
  SendBuf: WSABUF;
  ErrCode: integer;
begin
  case pClient^.ProxyKind^ of
    pkSOCKS5Proxy:
      begin
        pClient.Buf[0] := #5; // SOCKS版本5
        pClient.Buf[1] := #1; // Connect请求
        pClient.Buf[2] := #0; // 保留
        pClient.Buf[3] := #1; // IPv4类型地址
        PCardinal(@pClient.Buf[4])^ := pClient.ProxyDestIP;
        PWord(@pClient.Buf[8])^ := htons(pClient.ProxyDestPort);
        SendBuf.len := 10;
        SendBuf.Buf := pClient.Buf;
        // 修改状态，以便继续协商
        pClient.OperType := otProxy3;
        ErrCode := SendProxyData(pClient, SendBuf);
        if ErrCode <> CONST_SUCCESS_NO then
        begin
          // 激活连接失败
          DoConnectOver(ErrCode, pClient);
        end;
      end;
  end;
end;

function TRecvThread.SendProxyData(pClient: PClientContext; const Buf: WSABUF): integer;
var
  dRes, Flags: Cardinal;
  ErrCode: integer;
begin
  FillChar(pClient.Overlap, Sizeof(TOverlapped), #0);
  pClient^.Overlap.hEvent := FRecvEvent;
  if WSASend(pClient.Sock, @Buf, 1, dRes, 0, @pClient^.Overlap, nil) <> 0 then
  begin
    ErrCode := WSAGetLastError;
    if (ErrCode = ERROR_IO_PENDING) or (ErrCode = WSAEWOULDBLOCK) then
    begin
      Flags := 0;
      // 等待
      if not WSAGetOverlappedResult(pClient.Sock, @pClient^.Overlap, dRes, true, Flags) then
      begin // 重叠没有成功
        result := CONST_ERROR_OTHER_OVERLAP_ERROR;
        exit;
      end;
    end
    else
    begin
      // 说明已经结束
      result := CONST_ERROR_OTHER_OVERLAP_ERROR;
      exit;
    end;

  end;
  if dRes = Buf.len then
    result := CONST_SUCCESS_NO
  else
    result := CONST_ERROR_SEND_FAIL;
end;

procedure TRecvThread.SetNoNagle(Sock: TSocket);
var
  NoNagle: bool;
begin
  NoNagle := true; // 不使用Nagle算法 int
  setsockopt(Sock, IPPROTO_TCP, TCP_NODELAY, PAnsiChar(@NoNagle), Sizeof(bool));
end;

{ TTimeOutThread }

constructor TTimeOutThread.Create(TcpClient: TTcpClient);
begin
  FreeOnTerminate := true;
  FTcpClient := TcpClient;
  inherited Create(false);
end;

procedure TTimeOutThread.Execute;
var
  i, dRes: integer;
  pClient: PClientContext;
begin
  while not Terminated do
  begin
    // 两秒 轮讯一次
    dRes := WaitForSingleObject(FTcpClient.FTimeoutEvent, 2000);

    if Terminated then
      break;

    if dRes = WAIT_TIMEOUT then
    begin
      for i := Low(FTcpClient.FClientArray) to High(FTcpClient.FClientArray) do
      begin
        pClient := @FTcpClient.FClientArray[i];
        // csConnected csConnecting  只对处于连接和接收状态的上下文监控
        if ((pClient.Status = csConnected) or (pClient.Status = csConnecting)) and (pClient.Timeout >= 0) then
        begin
          // 计时
          inc(pClient.Timeout, 2);

          // 超时
          if (pClient.MaxTimeout > 0) and (pClient.Timeout >= pClient.MaxTimeout) then
          begin

            if pClient.Status = csConnected then
            begin // 接收超时
              if pClient.OperType in [otRecvHead, otRecvBody, otRecvData] then
              begin // 接收头
                FTcpClient.DoRecvDataOver(CONST_ERROR_RECV_FAIL, pClient, nil, 0, 0);
              end
              else if pClient.OperType = otRecvFile then
              begin // 接收文件块
                FTcpClient.DoRecvFileOver(CONST_ERROR_RECV_FAIL, pClient, pClient^.Data, pClient^.TotalLen,
                  pClient^.FinishLen, pClient^.Offset, (now - pClient.RecvTime) * 86400);
              end;
            end
            else if pClient.Status = csConnecting then
            begin
              FTcpClient.DoConnectOver(CONST_ERROR_CONNECT, pClient);
            end;

            // 关闭连接
            pClient.Status := csDisconnecting;
            // 通知轮询线程重组
            ReleaseSemaphore(FTcpClient.FExitSema, 1, nil);
          end;
        end;
        if Terminated then
          break;
      end;
    end
    else
      break;
  end;
end;

end.
