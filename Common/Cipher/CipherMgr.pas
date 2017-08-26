unit CipherMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-5
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  ICipherMgr = Interface(IInterface)
    ['{6E9AC6CB-8276-4E98-A149-1F2E33731227}']
    // AES 加密 128 key
    function AES_Encrypt128(APlain: AnsiString): AnsiString; safecall;
    // AES 解密 128 key
    function AES_Decrypt128(ACiper: AnsiString): AnsiString; safecall;
    // RSA 加密并 Base64 编码
    function RSA_EncryptAndBase64(APlain: AnsiString): AnsiString; safecall;
    // Base64 解码并 RSA 解密
    function RSA_Base64AndDecrypt(ACiper: AnsiString): AnsiString; safecall;
  end;

implementation

end.
