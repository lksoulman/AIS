unit IOCPUtil;

interface

uses Windows, SysUtils, Classes, WinSock2, IOCPLibrary, AnsiStrings;

const
  C_ERROR_IOPC_WSAStartup_1 = '致命错误!初始化失败!(%S)';

  // 下面定义的是定时器队列要用的常数
  WT_EXECUTEONLYONCE = $00000008; // 只触发一次
  WT_EXECUTEINTIMERTHREAD = $00000020; // 在定时器队列线程里执行

  // 下面定义的是定时器队列相关函数,delphi的windows.pas没有声明
  // 1、创建定时器队列
function CreateTimerQueue(): THandle; stdcall; // 返回值为队列句柄
// 2、添加定时任务
function CreateTimerQueueTimer(var phNewTimer: THandle; // 输出的定时器句柄
  hTimerQueue: THandle; // CreateTimerQueue返回值
  pfnCallback: pointer; // 3中定义的回调指针
  lpParameter: pointer; // 回调函数的参数
  dwDueTime: dword; // 第1次触发时间 毫秒
  dwPeriod: dword; // 触发间隔 毫秒 0表示1次性触发,否则以后每过这个时间再触发直至取消
  dwFlags: ULONG): bool; stdcall; // 标志

// 3、时间到要调用的回调函数形式
// 按照MSDN上的说法，这个回调函数应该是运行在另外的线程里，有可能是应用程序主线程
// 也有可能是操作系统临时生成的线程，它要求不能调用TerminateThread终止线程
// TimerOrWaitFired始终为true
{ procedure WaitOrTimerCallback(lpParameter:pointer;
  TimerOrWaitFired:boolean); stdcall; }
// 4、删除定时任务
function DeleteTimerQueueTimer(hTimerQueue: THandle; //
  hTimer: THandle; //
  hCompletionEvent: THandle): bool; stdcall; //
// 5、删除定时器队列
function DeleteTimerQueueEx(TimerQueue: THandle; //
  CompletionEvent: THandle): bool; stdcall; //
// 6、修改定时器对象
// 可以在超时回调里调用
// 不能在交互界面里调用
// 对于超短时间触发的定时器不起作用
function ChangeTimerQueueTimer(TimerQueue: THandle; Timer: THandle; DueTime, Period: ULONG): bool; stdcall;

function WinSock2Startup: boolean;
procedure WinSock2Cleanup(Init: boolean);
function GetOwnErrByWinsockErr(const Error: integer): integer;

function IsValidIP(const S: AnsiString): boolean;
function GetAllIPByName(const HostName: AnsiString; IPs: TStringList; const GetStringIP: boolean = false): boolean;
function ConvertIPToDword(ip: PAnsiChar): dword;
function ConvertDwordToIP(ip: dword): PAnsiChar;
function TransferWinsockError(const winsockErr: integer): integer;
function IsWholeHTTPResponse(const buf: PAnsiChar; const buflen: Cardinal): boolean;

implementation

function IsWholeHTTPResponse(const buf: PAnsiChar; const buflen: Cardinal): boolean;
var
  rnpos, cnpos, cnlen, k: integer;
begin
  result := false;
  if (buf = nil) or (buflen = 0) then
    exit;

  rnpos := Pos(AnsiString(#13#10#13#10), buf); // 连续的2个换行是HTTP头结束

  if (rnpos = 0) or (rnpos > integer(buflen)) then
    exit;

  cnpos := AnsiPos(AnsiString('content-length: '), AnsiStrings.StrLower(buf));
  if cnpos = 0 then
  begin // 没有数据体
    result := rnpos + 3 = integer(buflen);
    exit;
  end;

  // 有Content-Length，看他有没有收全

  cnpos := cnpos + length(AnsiString('content-length: '));
  for k := cnpos - 2 to cnpos + 11 do
  begin
    if (buf[k] = #13) and (buf[k + 1] = #10) then
    begin
      break;
    end;
  end;

  cnlen := StrToIntDef(Trim(string(Copy(buf, cnpos, k - cnpos + 1))), 0);

  result := (rnpos + cnlen + 3) = integer(buflen);
end;

function TransferWinsockError(const winsockErr: integer): integer;
begin // 转换winsock错误到自己的错误
  case winsockErr of
    WSAENOTCONN, WSAENOTSOCK:
      begin
        result := CONST_ERROR_NOT_CONNECTED;
      end;
    WSAENETDOWN, WSAEHOSTUNREACH:
      begin
        result := CONST_ERROR_NETWORK_DAMAGE;
      end;
    WSAECONNABORTED:
      begin
        result := CONST_ERROR_LOCAL_DISCONNECT;
      end;
    WSAECONNRESET:
      begin
        result := CONST_ERROR_REMOTE_DISCONNECT;
      end;
    WSAETIMEDOUT:
      begin
        result := CONST_ERROR_IDLE_TIMEOUT;
      end;
    WSAECONNREFUSED:
      begin
        result := CONST_ERROR_HOST_DENY;
      end;
  else
    begin
      result := winsockErr;
    end;
  end;
end;

function IsValidIP(const S: AnsiString): boolean;
var
  j, i: integer;
  LTmp: AnsiString;
  function Fetch(AInput: AnsiString; const ADelim: AnsiString): AnsiString;
  var
    LPos: integer;
  begin
    // AnsiPos does not work with #0
    LPos := Pos(ADelim, AInput);
    if LPos = 0 then
    begin
      result := AInput;
      AInput := '';
    end
    else
    begin
      result := Copy(AInput, 1, LPos - 1);
      AInput := Copy(AInput, LPos + length(ADelim), MaxInt);
    end;
  end;

begin
  result := True;
  LTmp := AnsiString(Trim(string(S)));
  for i := 1 to 4 do
  begin
    j := StrToIntDef(string(Fetch(LTmp, '.')), -1); { Do not Localize }
    result := result and (j > -1) and (j < 256);
    if not result then
      exit;
  end;
end;

function ConvertIPToDword(ip: PAnsiChar): dword;
begin
  result := inet_addr(ip);
end;

function ConvertDwordToIP(ip: dword): PAnsiChar;
var
  Addr: TInAddr;
begin
  Addr.S_addr := ip;
  result := inet_ntoa(Addr);
end;

function GetAllIPByName(const HostName: AnsiString; IPs: TStringList; const GetStringIP: boolean): boolean;
var
  pHost: PHostEnt;
  pIP: PDWORD;
  ippos, i: integer; // ,k
  thostname, dhostname: AnsiString;
  buf: PAnsiChar;
begin
  result := false;

  pHost := gethostbyname(PAnsiChar(HostName));
  if pHost <> nil then
  begin
    IPs.Clear;
    thostname := pHost.h_name;
    dhostname := '';
    // 判断是否是域名
    if pHost.h_aliases <> nil then
    begin
      // 实际测试发现，如果是Intranet的机器，往往没有域名，这里必须判断
      if pHost.h_aliases^ <> nil then
        dhostname := pHost.h_aliases^;
    end;

    buf := pHost.h_addr_list^;
    ippos := 0;
    if (dhostname = '') and (thostname <> '') then
    begin

      for i := 1 to 40 * pHost.h_length do
      begin
        if thostname = AnsiStrings.strpas(buf) then
        begin
          ippos := (i - 1) div pHost.h_length;
          break;
        end;
        inc(buf);
      end;
    end
    else if dhostname <> '' then
    begin
      for i := 1 to 40 * pHost.h_length do
      begin
        if dhostname = AnsiStrings.strpas(buf) then
        begin
          ippos := (i - 1) div pHost.h_length;
          break;
        end;
        inc(buf);
      end;
    end;

    if ippos = 0 then
      exit;

    pIP := PDWORD(pHost.h_addr_list^);
    for i := 0 to (ippos - 1) do
    begin
      if not GetStringIP then
        IPs.Add(inttostr(pIP^))
      else
        IPs.Add(string(ConvertDwordToIP(pIP^)));
      inc(pIP);
    end;
    result := True;
  end;
end;

function WinSock2Startup: boolean;
var
  WSData: TWSAData;
  sock: TSocket;
begin
  sock := Socket(AF_INET, SOCK_STREAM, 0);
  if sock = INVALID_SOCKET then
  begin
    if WSAStartup($0202, WSData) <> 0 then
      Raise Exception.Create(Format(C_ERROR_IOPC_WSAStartup_1, [SysErrorMessage(WSAGetlastError())]));
  end
  else
    closesocket(sock);
  result := True;
end;

procedure WinSock2Cleanup(Init: boolean);
begin
  if Init then
    WSACleanup;
end;

function GetOwnErrByWinsockErr(const Error: integer): integer;
begin

  case Error of
    WSAENOTSOCK, WSAECONNABORTED: // not sock,maybe local close connection
      result := CONST_ERROR_LOCAL_DISCONNECT;
    WSAEADDRINUSE: // address has been used
      result := CONST_ERROR_BIND_LISTEN;
    WSAENETDOWN, WSAENETRESET: // network fail
      result := CONST_ERROR_NETWORK_DAMAGE;
    WSAECONNRESET: // remote close connection
      result := CONST_ERROR_REMOTE_DISCONNECT;
    WSAETIMEDOUT:
      result := CONST_ERROR_IDLE_TIMEOUT;
    WSAECONNREFUSED:
      result := CONST_ERROR_HOST_DENY;
    WSAEHOSTUNREACH, WSAENETUNREACH:
      result := CONST_ERROR_HOST_NOT_FOUND;
    ERROR_INVALID_HANDLE:
      result := CONST_ERROR_WAIT;
  else
    result := Error;
  end;
end;

// 定时器队列相关，delphi中未声明
function CreateTimerQueue; external Kernel32 name 'CreateTimerQueue';
function CreateTimerQueueTimer; external Kernel32 name 'CreateTimerQueueTimer';
function DeleteTimerQueueTimer; external Kernel32 name 'DeleteTimerQueueTimer';
function DeleteTimerQueueEx; external Kernel32 name 'DeleteTimerQueueEx';
function ChangeTimerQueueTimer; external Kernel32 name 'ChangeTimerQueueTimer';

end.
