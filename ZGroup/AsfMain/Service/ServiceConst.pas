unit ServiceConst;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

const

  ECODE_SUCCESS                       = 0;  // 成功

  ECODE_BIND_BASE_NEED                = 11; // 需要绑定
  ECODE_BIND_BASE_NEED_REPEAT         = 12; // 需要重新绑定
  ECODE_BIND_BASE_RETURN_NIL          = 13; // 绑定服务接口返回数据为 NIL
  ECODE_BIND_BASE_RETURN_FIELD        = 14; // 绑定服务接口返回数据字段有问题
  ECODE_BIND_BASE_USER_EXIST          = 15; // 账号已被绑定
  ECODE_BIND_BASE_USER_NOEXIST        = 16; // 绑定用户不存在

  ECODE_PASSWORD_ERROR                = 21; // 密码错误
  ECODE_PASSWORD_RESET                = 22; // 密码已经被重置，需要被修改
  ECODE_PASSWORD_EXPIRE               = 23; // 密码已经过期，需要修改被修改
  ECODE_PASSWORD_NDAY_EXPIRE          = 24; // 密码还有N天过期，需要提示修改密码

  ECODE_SERVICE_BASE_NETWORK_EXCEPT   = 31; // GF 基础服务网络异常
  ECODE_SERVICE_ASSET_NETWORK_EXCEPT  = 32; // GF 资产服务网络异常
  ECODE_SERVICE_BASE_NIL              = 33; // GF 基础服务接口是 NIL
  ECODE_SERVICE_ASSET_NIL             = 34; // GF 资产服务接口是 NIL
  ECODE_SERVICE_BASE_EXEC_EXCEPT      = 35; // GF 基础服务接口执行异常
  ECODE_SERVICE_ASSET_EXEC_EXCEPT     = 36; // GF 资产服务接口执行异常

  ECODE_SERVICE_ASSET_NO_INIT         = 36; // 资产服务未初始化

  ECODE_OTHER                         = 50; // 其他错误


implementation

end.
