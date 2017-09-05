unit IOCPLibrary;

interface

uses windows;

const

  C_IOCP_BUFFER_SIZE = 1024 * 32; // 使用32K的缓冲区

  // 包类型标志位定义
  CONST_PKGTYPE_DATA = $00; // 0.普通数据
  CONST_PKGTYPE_FILE = $01; // 1.文件，UDP暂时不支持
  CONST_PKGTYPE_HEARTBEAT = $02; // 2.TCP心跳包
  CONST_PKGTYPE_SERVERBUSY = $03; // 3.服务器忙返回包，客户端收到应该断连

  // 返回码定义
  CONST_SUCCESS_NO = $0; // 成功

  // 连接常数
  CONST_ERROR_CONNECT = $1000; // 连接服务器失败
  CONST_ERROR_INVALID_SERVERIP = $1001; // 无效IP
  CONST_ERROR_INVALID_SERVERPORT = $1002; // 无效端口
  CONST_ERROR_CHANGE_SETTING_ON_RUNNING = $1003; // 不能在已运行时改变设置
  CONST_ERROR_CREATE_SOCKET = $1004; // 创建套接字失败
  CONST_ERROR_SET_RECVTIMEOUT = $1005; // 设置接收超时失败
  CONST_ERROR_HAVE_CONNECTED = $1006; // 已连接，不能再次连接
  CONST_ERROR_NOT_CONNECTED = $1007; // 未连接，不能进行此操作
  CONST_ERROR_NO_NET_OPTION = $1008; // 没有设置服务器信息
  CONST_ERROR_TERMINATED = $1009; // 被中断
  CONST_ERROR_IN_OPERATION = $100A; // 当前正在进行独占操作
  CONST_ERROR_CANCEL_OPERATION = $100B; // 操作被放弃
  CONST_ERROR_IDLE_TIMEOUT = $100C; // 空闲超时
  CONST_ERROR_NETWORK_DAMAGE = $100D; // 网络严重故障
  CONST_ERROR_PROXY_NEGOTIATE = $100E; // 与代理协商失败
  CONST_ERROR_PROXY_DENY = $100F; // 代理拒绝连接
  CONST_ERROR_PROXY_AUTHENTICATE = $1010; // 代理验证失败
  CONST_ERROR_HOST_POWEROFF = $1011; // 主机关机
  CONST_ERROR_HOST_NOT_FOUND = $1012; // 无此主机
  CONST_ERROR_HOST_DENY = $1013; // 主机拒绝

  // 发送接收错误常数
  CONST_ERROR_SEND_FAIL = $2000; // 发送报文失败（对方终止连接）
  CONST_ERROR_RECV_FAIL = $2001; // 接收报文失败（超时）
  CONST_ERROR_RECV_NO_ENOUGH = $2002; // 未收够指定字节
  CONST_ERROR_REMOTE_DISCONNECT = $2003; // 远程主机主动终止连接
  CONST_ERROR_CONTROL_BANDWIDTH = $2004; // 无法控制发送带宽
  CONST_ERROR_LOCAL_DISCONNECT = $2005; // 本地主机主动终止连接
  CONST_ERROR_SEND_AGAIN = $2006; // 不能在上次发送未结束前再次发送
  CONST_ERROR_SEND_REQUEST = $2007; // 发送请求失败
  CONST_ERROR_RECV_AUTO = $2008; // 接收将自动启动
  CONST_ERROR_COMMAND_DISCONNECT = $2009; // HTTP控制通道连接已经断开
  CONST_ERROR_CREATE_HTTP_TUNNEL = $200A; // 无法打开HTTP隧道
  CONST_ERROR_HTTP_TUNNEL_SEND = $200B; // 数据通过HTTP隧道传输失败
  CONST_ERROR_HTTP_TUNNEL_RECV = $200C; // 从HTTP隧道中取数据失败

  // 报文相关常数
  CONST_ERROR_INVALID_REQUEST = $3000; // 非法请求报文
  CONST_ERROR_INVALID_ACTION = $3001; // 非法请求业务
  CONST_ERROR_INVALID_PKG_LEN = $3002; // 非法报文长度
  CONST_ERROR_INVALID_PKG_FLAG = $3003; // 非法报文标志
  CONST_ERROR_INVALID_HANDLE_RESULT = $3004; // 非法处理结果类型
  CONST_ERROR_PKG_TOOLONG = $3005; // 待发送内容超长（针对传内存块的情况）
  CONST_ERROR_PKG_NIL = $3006; // 待发送内容为空
  CONST_ERROR_PKG_NO_ENOUGH = $3007; // 待发送内容大于实际内容
  CONST_ERROR_PARAM_ISNULL = $3008; // 请求参数为空
  CONST_ERROR_INVALID_PARAM_VALUE = $3009; // 无效参数值
  CONST_ERROR_FAIL_GEN_PKG_HEAD = $300A; // 数据长度参数与约定不符
  CONST_ERROR_FAIL_CHECK_CRC = $300B; // CRC校验失败
  CONST_ERROR_KEEPCONNECT = $200C; // 还未发生有效交互就要求保持连接
  // 文件处理错误常数
  CONST_ERROR_CREATEFILE = $4000; // 创建文件失败
  CONST_ERROR_OPENFILE = $4001; // 打开文件失败
  CONST_ERROR_READFILE = $4002; // 读文件失败
  CONST_ERROR_WRITEFILE = $4003; // 写文件失败
  CONST_ERROR_INVALID_FILENAME = $4004; // 无效文件名
  CONST_ERROR_NO_SUCH_FILE = $4005; // 无此文件
  CONST_ERROR_NO_SUCH_DIR = $4006; // 无效的目录
  CONST_ERROR_GETFILESIZE = $4007; // 获取文件大小失败
  CONST_ERROR_FILEOFFSET = $4008; // 文件偏移无效
  CONST_ERROR_FILELEN = $4009; // 指定了无效的长度
  CONST_ERROR_NOT_RECVFILE = $400A; // 文件到达却未启动接收文件
  CONST_ERROR_NO_FILE_ARRIVE = $400B; // 没有文件到达,不能启动接收文件
  CONST_ERROR_FILE_ARRIVE = $400C; // 文件到达需要启动文件接收
  // 队列操作常数
  CONST_ERROR_QUEUE_BLANK = $5000; // 队列空
  CONST_ERROR_QUEUE_TOOLONG = $5001; // 队列长度超过最大限制
  CONST_ERROR_QUEUE_IN = $5002; // 入队列失败
  CONST_ERROR_QUEUE_OUT = $5003; // 出队列失败
  // 重叠错误
  CONST_ERROR_TOOMANY_OVERLAP = $6000; // 重叠对象太多
  CONST_ERROR_CANCELED_BY_OS = $6001; // 操作被后台取消
  CONST_ERROR_OTHER_OVERLAP_ERROR = $6002; // 其他重叠错误
  CONST_ERROR_OVERLAP_PARAM = $6003; // 重叠参数错误导致无法重叠
  CONST_ERROR_BIND_TO_COMPPORT = $6004; // 绑定到完成端口出错
  CONST_ERROR_ACCEPT_EVENT = $6005; // acceptex事件出错
  CONST_ERROR_RECV_EVENT = $6006; // 创建接收事件失败
  CONST_ERROR_SEND_EVENT = $6007; // 创建发送事件失败
  CONST_SEND_ZERO = $6008; // 发送长度为 0.

  // 控件内部错误
  CONST_ERROR_FAIL_CTRL_TIMEOUT = $998E; // 无法控制超时
  CONST_ERROR_WAIT = $998F; // 等待失败
  CONST_ERROR_GET_FREE_SOCKET = $9990; // 无法获取空的SOCKET;
  CONST_ERROR_CREATE_COMPPORT = $9991; // 创建完成端口失败
  CONST_ERROR_CREATE_LISTENSOCKET = $9992; // 创建监听socket失败
  CONST_ERROR_BIND_LISTEN = $9993; // 无法绑定
  CONST_ERROR_LISTENING = $9994; // 无法监听
  CONST_ERROR_BIND_LISTEN_TO_COMPPORT = $9995; // 关联到完成端口失败
  CONST_ERROR_CREATE_LOGDIR = $9996; // 日志目录创建失败
  CONST_ERROR_SERVICE_STARTED = $9997; // 服务已经启动或正在启动
  CONST_ERROR_SERVICE_NOT_STARTED = $9998; // 服务未启动或正在停止
  CONST_ERROR_ACCEPTEX = $9999; // 无法投递接受连接操作
  CONST_ERROR_EXCEPTION = $999A; // 控件内部处理数据异常
  CONST_ERROR_INVALID_INDEX = $999B; // 无效的索引

  CONST_ERROR_LISTEN_ERROR = $FFFD; // 监听出现错误
  CONST_ERROR_ALLOC_MEMORY = $FFFE; // 分配内存失败
  CONST_OTHER_ERROR = $FFFF; // 其他错误

  // windows标准错误，免掉多国语言问题
  { 13/数据无效。
    1345/指定属性无效，或与整个群体的属性不兼容。
    1707/网络地址无效。
    3678/保存配置文件时出错，原先记录的网络连接状态没有更改。
    5089/由于与另一个现有属性冲突，未能修改资源属性。
    8255/一个或多个参数非法。
    8311/修改操作非法。不允许该修改的某个方面。
    8423/由于安全原因不允许修改。
    9552/无效的 IP 地址。
    9553/无效的属性。
    10022/提供了一个无效的参数。 }
  WERROR_INVALID_IP = 9552; // windows标准错误，无效的IP地址
  WERROR_CANNOT_MODIFY = 8423; // 不能被修改
  WERROR_INVALID_VALUE = 13; // 无效的值

  // 以下定义的是通知类型常数
  NOTIFYKIND_CONNECT = 0; // 连接通知
  NOTIFYKIND_DISCONNECT = 1; // 断连通知
  NOTIFYKIND_KEEPCONNECTION = 2; // 保持连接通知
  NOTIFYKIND_ERROR = 255; // 错误通知

const
  C_ERROR_IOPC_CreateSock_1 = '创建监听SOCKET失败! (%S)';
  C_ERROR_IOPC_BindnSock_1 = '绑定监听SOCKET失败! (%S)';
  C_ERROR_IOPC_ListenSock_1 = '启动监听失败! (%S)';
  C_ERROR_IOPC_AcceptEvent_1 = '创建接收事件失! (%S)';
  C_ERROR_IOPC_AcceptSelect_1 = '分配接收事件失败! (%S)';
  C_ERROR_IOPC_StartServer = '服务已经启动或正在启动!';
  C_ERROR_IOPC_StartServerParam = 'socket池 > 并发数 无效参数值!';
  C_ERROR_IOPC_CreateTimerQueue = 'CreateTimerQueue失败!';
  C_ERROR_IOPC_StopServer = '服务未启动或正在停止';
  C_ERROR_IOPC_StartServerListenComp_1 = '绑定监听套接字到完成端口失败而导致服务启动失败!(%s)';

function GetErrorMsg(ErrNo: dword; NeedErrorCode: boolean): string;

implementation

function GetErrorMsg(ErrNo: dword; NeedErrorCode: boolean): string;
begin
  case ErrNo of
    CONST_SUCCESS_NO:
      result := '成功'; // 0000
    // 连接常数
    CONST_ERROR_CONNECT:
      result := '连接服务器失败'; // $1000
    CONST_ERROR_INVALID_SERVERIP:
      result := '无效的主机IP地址'; // $1001
    CONST_ERROR_INVALID_SERVERPORT:
      result := '无效端口'; // $1002
    CONST_ERROR_CHANGE_SETTING_ON_RUNNING: // $1003
      result := '已运行时不允许改变设置';
    CONST_ERROR_CREATE_SOCKET:
      result := '创建套接字失败'; // $1004
    CONST_ERROR_SET_RECVTIMEOUT:
      result := '设置套接字接收超时失败'; // $1005
    CONST_ERROR_HAVE_CONNECTED: // $1006
      result := '已连接或已经启动连接,不能再次连接';
    CONST_ERROR_NOT_CONNECTED:
      result := '未连接,不能进行此操作'; // $1007
    CONST_ERROR_NO_NET_OPTION:
      result := '没有设置服务器信息'; // $1008
    CONST_ERROR_TERMINATED:
      result := '操作被中断'; // $1009
    CONST_ERROR_IN_OPERATION: // $100A
      result := '当前正在进行独占操作,无法处理本次请求';
    CONST_ERROR_CANCEL_OPERATION: // $100B
      result := '操作被放弃';
    CONST_ERROR_IDLE_TIMEOUT: // $100C
      result := '已超出系统等待时间';
    CONST_ERROR_NETWORK_DAMAGE:
      result := '网络出现问题,请检查网络!'; // $100D
    CONST_ERROR_PROXY_NEGOTIATE: // $100E
      result := '代理拒绝外出请求';
    CONST_ERROR_PROXY_DENY:
      result := '连接被代理拒绝'; // $100F
    CONST_ERROR_PROXY_AUTHENTICATE:
      result := '没有通过代理验证,请确认用户名口令'; // $1010
    CONST_ERROR_HOST_POWEROFF:
      result := '服务器已经关机'; // $1011
    CONST_ERROR_HOST_NOT_FOUND:
      result := '不存在这样的主机或目标网络不通'; // $1012
    CONST_ERROR_HOST_DENY:
      result := '连接被对方拒绝,可能是服务没有启动'; // $1013
    // 发送接收错误常数
    CONST_ERROR_SEND_FAIL:
      result := '发送报文失败(对方可能已终止连接)'; // $2000
    CONST_ERROR_RECV_FAIL:
      result := '未收全足够数据(对方可能已终止连接)'; // $2001
    CONST_ERROR_RECV_NO_ENOUGH:
      result := '未收够指定字节'; // $2002
    CONST_ERROR_REMOTE_DISCONNECT:
      result := '远程主机主动放弃连接或者服务没有启动'; // $2003
    CONST_ERROR_CONTROL_BANDWIDTH:
      result := '无法控制发送带宽'; // $2004
    CONST_ERROR_LOCAL_DISCONNECT:
      result := '取消与对方的连接,原因是到对方网络不通或者空闲时间超过限制'; // $2005
    CONST_ERROR_SEND_AGAIN:
      result := '不能在上次请求未结束前再次请求'; // $2006
    CONST_ERROR_SEND_REQUEST:
      result := '发送请求失败'; // $2007
    CONST_ERROR_RECV_AUTO:
      result := '接收将自动启动'; // $2008
    CONST_ERROR_COMMAND_DISCONNECT:
      result := 'HTTP控制通道连接已经断开,请重新连接'; // $2009
    CONST_ERROR_CREATE_HTTP_TUNNEL:
      result := '打开HTTP隧道没有成功'; // $200A
    // 报文相关常数
    CONST_ERROR_INVALID_REQUEST:
      result := '错误的数据格式导致无法解析'; // $3000
    CONST_ERROR_INVALID_ACTION:
      result := '不支持此项操作'; // $3001
    CONST_ERROR_INVALID_PKG_LEN:
      result := '非法报文长度'; // $3002
    CONST_ERROR_INVALID_PKG_FLAG:
      result := '非法报文标志'; // $3003
    CONST_ERROR_INVALID_HANDLE_RESULT:
      result := '非法处理结果类型'; // $3004
    CONST_ERROR_PKG_TOOLONG:
      result := '待发送内容超长'; // $3005针对传内存块的情况）
    CONST_ERROR_PKG_NIL:
      result := '待发送内容为空'; // $3006
    CONST_ERROR_PKG_NO_ENOUGH:
      result := '待发送字节数少于实际字节数或小于1'; // $3007
    CONST_ERROR_PARAM_ISNULL:
      result := '请求参数为空'; // $3008
    CONST_ERROR_INVALID_PARAM_VALUE:
      result := '无效参数值'; // $3009
    CONST_ERROR_FAIL_GEN_PKG_HEAD:
      result := '数据长度参数与约定不符'; // $300A
    CONST_ERROR_FAIL_CHECK_CRC:
      result := 'CRC校验失败'; // $300B
    CONST_ERROR_KEEPCONNECT:
      result := '还未发生有效交互就要求保持连接'; // $200C
    // 文件处理常数
    CONST_ERROR_CREATEFILE:
      result := '创建文件失败'; // $4000
    CONST_ERROR_OPENFILE:
      result := '打开文件失败'; // $4001
    CONST_ERROR_READFILE:
      result := '读文件失败'; // $4002
    CONST_ERROR_WRITEFILE:
      result := '写文件失败'; // $4003
    CONST_ERROR_INVALID_FILENAME:
      result := '无效文件名'; // $4004
    CONST_ERROR_NO_SUCH_FILE:
      result := '未找到指定文件'; // $4005
    CONST_ERROR_NO_SUCH_DIR:
      result := '无效的目录'; // $4006
    CONST_ERROR_GETFILESIZE:
      result := '获取文件大小失败'; // $4007
    CONST_ERROR_FILEOFFSET:
      result := '文件偏移无效'; // $4008
    CONST_ERROR_FILELEN:
      result := '指定了无效的长度'; // $4009
    CONST_ERROR_NOT_RECVFILE:
      result := '文件到达却未启动接收文件'; // $400A
    CONST_ERROR_NO_FILE_ARRIVE:
      result := '没有文件到达,不能启动接收文件'; // $400B
    CONST_ERROR_FILE_ARRIVE:
      result := '文件到达需要启动文件接收'; // $400C
    // 队列操作常数
    CONST_ERROR_QUEUE_BLANK:
      result := '队列空'; // $5000
    CONST_ERROR_QUEUE_TOOLONG:
      result := '队列长度超过最大限制'; // $5001
    CONST_ERROR_QUEUE_IN:
      result := '进入队列失败'; // $5002
    CONST_ERROR_QUEUE_OUT:
      result := '出队列失败'; // $5003
    // OS错误
    CONST_ERROR_TOOMANY_OVERLAP:
      result := '重叠对象太多'; // $6000
    CONST_ERROR_CANCELED_BY_OS:
      result := '操作被后台取消'; // $6001
    CONST_ERROR_OTHER_OVERLAP_ERROR:
      result := '系统处理当前I/O请求失败'; // $6002
    CONST_ERROR_OVERLAP_PARAM:
      result := '重叠参数错误导致无法重叠'; // $6003
    CONST_ERROR_BIND_TO_COMPPORT:
      result := '绑定到完成端口出错'; // $6004
    CONST_ERROR_ACCEPT_EVENT:
      result := '无法继续投递接受连接操作'; // $6005
    CONST_ERROR_RECV_EVENT: // $6006
      result := '更改套接字到异步状态没有成功';
    CONST_ERROR_SEND_EVENT: // $6007
      result := '创建发送事件失败';
    CONST_SEND_ZERO:
      result := '发送长度为0，重发。'; // $6008
    // 控件内部错误
    CONST_ERROR_FAIL_CTRL_TIMEOUT:
      result := '无法控制超时'; // $998E
    CONST_ERROR_WAIT:
      result := '系统错误,无法监控操作进度'; // $998F
    CONST_ERROR_GET_FREE_SOCKET:
      result := '无法创建套接字'; // $9990
    CONST_ERROR_CREATE_COMPPORT:
      result := '创建完成端口失败'; // $9991
    CONST_ERROR_CREATE_LISTENSOCKET:
      result := '创建监听套接字失败'; // $9992
    CONST_ERROR_BIND_LISTEN:
      result := '无法绑定监听套接字到本地IP'; // $9993
    CONST_ERROR_LISTENING:
      result := '监听套接字无法监听'; // $9994
    CONST_ERROR_BIND_LISTEN_TO_COMPPORT:
      result := '绑定套接字到完成端口失败'; // $9995
    CONST_ERROR_CREATE_LOGDIR:
      result := '日志目录创建失败'; // $9996
    CONST_ERROR_SERVICE_STARTED:
      result := '服务已经启动或正在启动'; // $9997
    CONST_ERROR_SERVICE_NOT_STARTED:
      result := '服务未启动或正在停止'; // $9998
    CONST_ERROR_ACCEPTEX:
      result := '无法投递接受连接操作'; // $9999
    CONST_ERROR_EXCEPTION:
      result := '未知错误导致处理没有完成,请检查输入条件!'; // $999A
    CONST_ERROR_INVALID_INDEX:
      result := '无效的索引'; // $999B
    CONST_ERROR_LISTEN_ERROR:
      result := '监听出现错误'; // $FFFD
    CONST_OTHER_ERROR:
      result := '其他错误' // $FFFF
  else
    result := '未知错误';
  end; // end case
end;

end.
