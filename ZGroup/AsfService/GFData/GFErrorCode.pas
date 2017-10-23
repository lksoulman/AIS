unit GFErrorCode;

interface

const

  GFECODE_UNKNOWN               = -1;       // UnKnown
  GFECODE_SUCCESS               = 0;        // Success
  GFECODE_WAIT_TIMEOUT          = 1;        // Wait Timeout
  GFECODE_WAIT_FAILED           = 2;        // Wait Failed


  GFECODE_FUNCID_NULL           = 100;      // Indicator FundId Is NULL
  GFECODE_COMPRESS              = 101;      // Compress
  GFECODE_UNCOMPRESS            = 102;      // UnpCompress
  GFECODE_ENCRYPT               = 103;      // Encrypt
  GFECODE_DECRYPT               = 104;      // Decrypt
  GFECODE_URL_NULL              = 105;      // Url Is NULL
  GFECODE_POST                  = 106;      // POST
  GFECODE_RETURN_NULL           = 107;      // Return NULL

  GFECODE_INIT_NOLOGIN          = 200;      // Init No Login
  GFECODE_NEED_RELOGIN          = 201;      // Need Re Login

  GFECODE_INDICATOR_JSONFORMAT            = 9001;    // JSON格式错误
  GFECODE_INDICATOR_NOTEXISTS             = 9002;    // 指标不存在
  GFECODE_INDICATOR_PARAMSCHECK           = 9003;    // 参数校验失败
  GFECODE_INDICATOR_PARAMSCOUNT           = 9004;    // 参数个数不一致
  GFECODE_INDICATOR_PARAMSTYPE            = 9005;    // 参数类型有误
  GFECODE_INDICATOR_EXECEXCEPT            = 9006;    // 指标执行异常
  GFECODE_INDICATOR_RETURNEXCEPT          = 9007;    // 指标返回结果异常
  GFECODE_SESSIONID_USEREXCEPT            = 9011;    // 用户异常
  GFECODE_SESSIONID_PASSWDEXCEPT          = 9012;    // 帐号密码校验失败
  GFECODE_SESSIONID_MACCODEFAIL           = 9013;    // 机器码校验失败
  GFECODE_SESSIONID_TIMEOUT               = 9014;    // 会话超时
  GFECODE_SESSIONID_LOGINELSEWHERE        = 9015;    // 帐号已经在别处登录
  GFECODE_SESSIONID_NOEXISTS              = 9016;    // 不存在 SID
  GFECODE_SESSIONID_NOLOGIN               = 9017;    // 未登录
  GFECODE_SESSIONID_LOGINFAIL             = 9018;    // 登录失败
  GFECODE_BIND_INVAILDACCOUNT             = 9031;    // 无效的绑定绑定账号
  GFECODE_BIND_ACCOUNTBINDED              = 9032;    // 账号已被绑定
  GFECODE_BIND_BINDEDEXCEPT               = 9033;    // 账号绑定异常
  GFECODE_SERVICESYS_EXCEPTION            = 9999;    // 服务端系统异常


implementation

end.
