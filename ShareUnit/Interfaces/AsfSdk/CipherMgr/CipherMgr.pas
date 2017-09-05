unit CipherMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Encryption and decryption management interface
// Author£º      lksoulman
// Date£º        2017-8-5
// Comments£º    Encryption and decryption management interface
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Encryption and decryption management interface
  ICipherMgr = Interface(IInterface)
    ['{6E9AC6CB-8276-4E98-A149-1F2E33731227}']
    // AES Encrypt 128 key
    function AESEncrypt128(APlain: AnsiString): AnsiString; safecall;
    // AES Decrypt 128 key
    function AESDecrypt128(ACiper: AnsiString): AnsiString; safecall;
    // RSA Encrypt and Base64
    function RSAEncryptAndBase64(APlain: AnsiString): AnsiString; safecall;
    // Base64 and RSA Decrypt
    function RSABase64AndDecrypt(ACiper: AnsiString): AnsiString; safecall;
  end;

implementation

end.
