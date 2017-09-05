unit Verify;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonObject;

type

  IVerify = Interface(IInterface)
    ['{BB2A6946-62F0-4A16-BF97-BF93A738A0F2}']
    // 设置产生验证码个数
    procedure SetVerifyCodeCount(ACount: Integer); safeCall;
    // 获取验证码对应的流
    function GetStreamByVerifyCode(AVerifyCode: Integer): TStream; safeCall;
    // 获取验证码对应字符串
    function GetStringByVerifyCode(AVerifyCode: Integer): WideString; safeCall;
    // 产生随机码
    procedure GenerateVerifyCodes(var AVerifyCodes: TIntegerDynArray); safeCall;
  end;

implementation

end.
