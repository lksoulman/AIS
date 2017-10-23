unit EDCryptImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Encrypt and Decrypt Interface Implementation
// Author：      lksoulman
// Date：        2017-8-5
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  ElAES,
  EDCrypt,
  Windows,
  Classes,
  SysUtils,
  CipherRSA,
  CipherAES,
  CipherMD5,
  AppContext,
  CommonRefCounter;

type

  // Encrypt and Decrypt Interface Implementation
  TEDCryptImpl = class(TAutoInterfacedObject, IEDCrypt)
  private
    // is Init RSA
    FIsInitRSA: Boolean;
    // is Init AES
    FIsInitAES: Boolean;
    // AES Key
    FAESKey: AnsiString;
    // AES Buffer
    FAESBuffer: TAESBuffer;
    // RSA object
    FCipherRSA: TCipherRSA;
    // MD5 Object
    FCipherMD5: TCipherMD5;
    // Application Context
    FAppContext: IAppContext;
  protected
    // Init RSA
    procedure DoInitCipherRSA;
    // Init AES
    procedure DoInitCipherAES;
  public
     // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IEDCrypt }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface); safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; safecall;

    // String MD5
    function StringMD5(AString: AnsiString): AnsiString; safecall;

    { AES }

    // Encrypt AES
    function EncryptAES(APlain: AnsiString): AnsiString; safecall;
    // Decrypt AES
    function DecryptAES(ACiper: AnsiString): AnsiString; safecall;
    // Encrypt AES And EncodeStr HEX
    function EncryptAESEncodeHEX(APlain: AnsiString): AnsiString; safecall;
    // DecodeStr HEX and Decrypt AES
    function DecodeHEXDecryptAES(ACiper: AnsiString): AnsiString; safecall;
    // Encrypt AES And EncodeStr Base64
    function EncryptAESEncodeBase64(APlain: AnsiString): AnsiString; safecall;
    // DecodeStr Base64 And Decrypt AES
    function DecodeBase64DecryptAES(ACiper: AnsiString): AnsiString; safecall;

    { RSA }

    // Encrypt AES
    function EncryptRSA(APlain: AnsiString): AnsiString; safecall;
    // Decrypt AES
    function DecryptRSA(ACiper: AnsiString): AnsiString; safecall;
    // Encrypt RSA And EncodeStr HEX
    function EncryptRSAEncodeHEX(APlain: AnsiString): AnsiString; safecall;
    // DecodeStr HEX And Decrypt RSA
    function DecodeHEXDecryptRSA(ACiper: AnsiString): AnsiString; safecall;
    // Encrypt RSA And EncodeStr Base64
    function EncryptRSAEncodeBase64(APlain: AnsiString): AnsiString; safecall;
    // DecodeStr Base64 And Decrypt RSA
    function DecodeBase64DecryptRSA(ACiper: AnsiString): AnsiString; safecall;
  end;

implementation

uses
  Base64,
  LogLevel;

const

  // Private Key
  PRIVATE_KEY = 'MIIEpQIBAAKCAQEAsG69YPAQULQ9H2/sGYNf1dw7XUkQ2jWu0PSE6WfQW+h'
    + 'PF9R0b0a22c5jqdXEGdWZrEwebyfOmT3guRtIJJ8VKfC8NgOe48Ypdzd5WQ4wZizGSvB08oGS'
    + 'RTCKhL2FoxjRYM5PVpT9rRq8Uy7MNmsEMfjqwnj7FNIQyMhvYWMkaAzoGiVf7ZKLyUj6hQ4Yx'
    + '1yayinZ2gdqL0EmZYwvpANFybJhKUW7Ph0c0Flz5O7nD3ALWGmDb9K8NXbqzjRPbmEx36Ydv7'
    + 'COk8G0BtVh5TtShgdBrKPNrAHURyBhmqhl2U87RS1/pibkQIYtVxnYgQed905PIcb4+8uDPtw'
    + '+7MvATQIDAQABAoIBAGWs6+ZZco2P0Um0rlNlqm0Mpgl0egnGtiAlShNYiHLuxeXtwcv+7JFI'
    + 'p5bQYlqhBhaNJ1zXi/A0ALWsSz8PjprE6TIXlBGfuXXCumPgEXRQiVXWjQ7ULP9CohEtRz5ep'
    + 'wsq2f4Djs2bgrxNU9JoidpioKfCILA2/wU2vTlacTikgaD8S+A0yqqaHsIwMp2n7RwRC85ahJ'
    + 'eDE3YuAVrF6ZYJ+lMTHq9Au9iYTtMZo3VA8RkyrjHXFyoGn5dqkAOomxSv0sfBLrOGSPZHV3M'
    + 'ZB6e8G0sjwH8EZLQriRba36q0Sqv06nvZSjM2ugJqPWGUaXPYVssq8ukos+/epwGafuECgYEA'
    + '56ROMlnVxexzuuq83qI6N9q9+PTq6lHAB8O3ncpVxAaUrPhp/2HYAcCzbZdT7qs7eB+uJ3V6m'
    + 'A56q+Q17FxaXKTkQVtpVnRoEeilzqf0a+RD1oA7lGkpsaxJXfZ2Wo4bCvaiBMN8NSjE8JRbUb'
    + 'OmvWVl5mJWjAKINvY7WiY9/HMCgYEAwvw54+hu/l65vyq6SL8Qa0JKeeybGMSr1FWUNPTLrlz'
    + '8FNdZTxFAo2AzLaXhvqYBc4oLglbRVD41f0sY9iSRVYvOHpqxrMjTgKExfQtizvv4NsvkRIV0'
    + 'Y4Jh57LrBLHTk3vvRBy3jHdZQEcUo3Y5tKUzOQ8/aygJBmH9FctC4D8CgYEAnw2qw9f7eVPKg'
    + '2X7GcO6xe9k0jUZuJs5iBtTUP1FtrvuCnboEXtVnp56lZ16/D6HLwxRwLZh31bR1IV2oT0ors'
    + 'RqFpZ11e9IJkPg1e1tX0f1bKvQPS+YeW8bUXGSAsvgtb5zsWGpP7cmwyqbKZZ5v0KInZCYbLq'
    + 'wXUzlpBjuJxECgYEApcuutdo4Ntb4/lIooB7GqU1u4omLv93Ldftm0Diu0I6EUnxillbHLaRp'
    + 'IBGDCIdDiKkC7EtCJ23WM2z5xqKFacY898z180O4hBGMcRUzaWjbQEzSxmjr9IkzEr8SE6XZj'
    + '/i8FKCOekQpgfxu0id/Hdmy2nvaoxUhx2met99j+CUCgYEAncYCm1xBY3mRLw+lMztGykzsRV'
    + 'iVmNnh+WumtpWwz8KS4zDMlc7/dlJKwOLd3PNvGU6/nu39ybAEXTcYdMIXRGnuCN7RXdFs0MY'
    + 'tCnM6h9x7JNra/B0QRKmBlqBJo5hIyJ+KWrGoTTWvos8y4dD8s6sdZZE2lEi4j+3BgTnjIQE=';

  // Public Key
  PUBLIC_KEY = 'MIIBCgKCAQEAsG69YPAQULQ9H2/sGYNf1dw7XUkQ2jWu0PSE6WfQW+hPF9R0'
    + 'b0a22c5jqdXEGdWZrEwebyfOmT3guRtIJJ8VKfC8NgOe48Ypdzd5WQ4wZizGSvB08oGSRTCKh'
    + 'L2FoxjRYM5PVpT9rRq8Uy7MNmsEMfjqwnj7FNIQyMhvYWMkaAzoGiVf7ZKLyUj6hQ4Yx1yayi'
    + 'nZ2gdqL0EmZYwvpANFybJhKUW7Ph0c0Flz5O7nD3ALWGmDb9K8NXbqzjRPbmEx36Ydv7COk8G'
    + '0BtVh5TtShgdBrKPNrAHURyBhmqhl2U87RS1/pibkQIYtVxnYgQed905PIcb4+8uDPtw+7MvA'
    + 'TQIDAQAB';

constructor TEDCryptImpl.Create;
begin
  inherited;
  FIsInitRSA := False;
  FIsInitAES := False;
  FCipherRSA := TCipherRSA.Create;
  FCipherMD5 := TCipherMD5.Create;
end;

destructor TEDCryptImpl.Destroy;
begin
  FCipherMD5.Free;
  FCipherRSA.Free;
  inherited;
end;

procedure TEDCryptImpl.DoInitCipherRSA;
var
  LLen: Integer;
  LBytes: TBytes;
  LBase64Str: UTF8String;
  LStr, LTestStr: AnsiString;
begin
  try
    // Base64
    LBase64Str := PUBLIC_KEY;
    SetLength(LBytes, (Length(LBase64Str) div 4) * 3);
    LLen := Base64Decode(@LBase64Str[1],@LBytes[0], Length(LBase64Str));
    SetLength(LBytes, LLen);
    FCipherRSA.LoadPublicKey(LBytes);

    // 客户端只需加密，不用加载私钥
    LBase64Str := PRIVATE_KEY;
    SetLength(LBytes, (Length(LBase64Str) div 4) * 3);
    LLen := Base64Decode(@LBase64Str[1],@LBytes[0], Length(LBase64Str));
    SetLength(LBytes, LLen);
    FCipherRSA.LoadPrivateKey(LBytes);

    LStr := 'Hello';
    LTestStr := LStr;
    LTestStr := EncryptRSAEncodeBase64(LTestStr);
    LTestStr := DecodeBase64DecryptRSA(LTestStr);
    if LStr = LTestStr then begin
      FIsInitRSA := True;
    end;
  except
    on Ex: Exception do begin
      FIsInitRSA := False;
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][DoInitCipherRSA] Exception is %s.', [Ex.Message]));
    end;
  end;
end;

procedure TEDCryptImpl.DoInitCipherAES;
const
  AES_PLAIN              = '12ede%de';
  AES_KEY                = 'po98&^jn';
  AES_KEYBUF: TAESBuffer = ($41, $72, $65, $79, $6F, $75, $6D, $79, $53,
    $6E, $6F, $77, $6D, $61, $6E, $3F);
begin
  try
    CopyMemory(@FAESBuffer[0], @AES_KEYBUF[0], Length(FAESBuffer));
    FAESKey := CipherAES.EncryptString(AES_PLAIN, AES_KEY);
    FIsInitAES := True;
  except
    on Ex: Exception do begin
      FIsInitAES := False;
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][DoInitCipherAES] CipherAES.EncryptString Exception is %s.', [Ex.Message]));
    end;
  end;
end;

procedure TEDCryptImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;

  DoInitCipherRSA;
  DoInitCipherAES;
end;

procedure TEDCryptImpl.UnInitialize;
begin

  FAppContext := nil;
end;

function TEDCryptImpl.StringMD5(AString: AnsiString): AnsiString;
var
  LMD5: string;
begin
  try
    LMD5:= FCipherMD5.GetStringMD5(AString);
    Result := AnsiString(LMD5);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][EncryptAES] FCipherMD5.GetStringMD5 Exception is %s.', [Ex.Message]));
    end;
  end;
end;

function TEDCryptImpl.EncryptAES(APlain: AnsiString): AnsiString;
begin
  Result := '';
  if APlain = '' then Exit;
  try
    Result := CipherAES.EncryptString128B64(APlain, FAESKey, FAESBuffer);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][EncryptAES] CipherAES.EncryptString128B64 Exception is %s.', [Ex.Message]));
    end;
  end;
end;

function TEDCryptImpl.DecryptAES(ACiper: AnsiString): AnsiString;
begin
  Result := '';
  if ACiper = '' then Exit;

  try
    Result := CipherAES.DecryptString128B64(ACiper, FAESKey, FAESBuffer);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][DecryptAES] CipherAES.DecryptString128B64 Exception is %s.', [Ex.Message]));
    end;
  end;
end;

function TEDCryptImpl.EncryptAESEncodeHEX(APlain: AnsiString): AnsiString;
begin
  Result := EncryptAES(APlain);
  if Result <> '' then begin
    try
      Result := CipherAES.StrToHex(Result);
    except
      on Ex: Exception do begin
        Result := '';
        FAppContext.SysLog(llError, Format('[TEDCryptImpl][EncryptAESEncodeHEX] CipherAES.StrToHex Exception is %s.', [Ex.Message]));
      end;
    end;
  end;
end;

function TEDCryptImpl.DecodeHEXDecryptAES(ACiper: AnsiString): AnsiString;
begin
  if ACiper <> '' then begin
    try
      Result := CipherAES.HexToStr(Result);
    except
      on Ex: Exception do begin
        Result := '';
        FAppContext.SysLog(llError, Format('[TEDCryptImpl][DecodeHEXDecryptAES] CipherAES.HexToStr Exception is %s.', [Ex.Message]));
      end;
    end;
  end else begin
    Result := '';
  end;
  Result := DecryptAES(Result);
end;

function TEDCryptImpl.EncryptAESEncodeBase64(APlain: AnsiString): AnsiString;
begin
  Result := EncryptAES(APlain);
  if Result <> '' then begin
    try
      Result := Base64EncodeStr(Result);
    except
      on Ex: Exception do begin
        Result := '';
        FAppContext.SysLog(llError, Format('[TEDCryptImpl][EncryptAESEncodeBase64] Base64EncodeStr Exception is %s.', [Ex.Message]));
      end;
    end;
  end;
end;

function TEDCryptImpl.DecodeBase64DecryptAES(ACiper: AnsiString): AnsiString;
begin
  if ACiper <> '' then begin
    try
      Result := Base64DecodeStr(Result);
    except
      on Ex: Exception do begin
        Result := '';
        FAppContext.SysLog(llError, Format('[TEDCryptImpl][DecodeBase64DecryptAES] Base64DecodeStr Exception is %s.', [Ex.Message]));
      end;
    end;
  end else begin
    Result := '';
  end;
  Result := DecryptAES(Result);
end;

function TEDCryptImpl.EncryptRSA(APlain: AnsiString): AnsiString;
var
  LPlainBytes, LCiperBytes: TBytes;
begin
  Result := '';
  if APlain = '' then Exit;

  SetLength(LPlainBytes, Length(APlain));
  CopyMemory(@LPlainBytes[0], @APlain[1], Length(APlain));
  try
    FCipherRSA.Encrypt(LPlainBytes, LCiperBytes);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][EncryptRSA] FCipherRSA.Encrypt Exception is %s.', [Ex.Message]));
    end;
  end;
  SetLength(Result, Length(LCiperBytes));
  CopyMemory(@Result[1], @LCiperBytes[0], Length(LCiperBytes));
end;

function TEDCryptImpl.DecryptRSA(ACiper: AnsiString): AnsiString;
var
  LPlainBytes, LCiperBytes: TBytes;
begin
  Result := '';
  if ACiper = '' then Exit;

  SetLength(LCiperBytes, Length(ACiper));
  CopyMemory(@LCiperBytes[0], @Result[1], Length(Result));
  try
    FCipherRSA.Decrypt(LCiperBytes, LPlainBytes);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][DecryptRSA] FCipherRSA.Decrypt Exception is %s.', [Ex.Message]));
    end;
  end;
  SetLength(Result, Length(LPlainBytes));
  CopyMemory(@Result[1], @LPlainBytes[0], Length(LPlainBytes));
end;

function TEDCryptImpl.EncryptRSAEncodeHEX(APlain: AnsiString): AnsiString;
begin
  Result := EncryptRSA(APlain);
  try
    Result := CipherAES.StrToHex(Result);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][EncryptRSAEncodeHEX] CipherAES.StrToHex Exception is %s.', [Ex.Message]));
    end;
  end;
end;

function TEDCryptImpl.DecodeHEXDecryptRSA(ACiper: AnsiString): AnsiString;
begin
  try
    Result := CipherAES.HexToStr(ACiper);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][DecodeHEXDecryptRSA] CipherAES.HexToStr Exception is %s.', [Ex.Message]));
    end;
  end;
  Result := DecryptRSA(Result);
end;

function TEDCryptImpl.EncryptRSAEncodeBase64(APlain: AnsiString): AnsiString;
begin
  Result := EncryptRSA(APlain);
  try
    Result := Base64EncodeStr(Result);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][EncryptRSAEncodeBase64] Base64EncodeStr Exception is %s.', [Ex.Message]));
    end;
  end;
end;

function TEDCryptImpl.DecodeBase64DecryptRSA(ACiper: AnsiString): AnsiString;
begin
  try
    Result := Base64DecodeStr(ACiper);
  except
    on Ex: Exception do begin
      Result := '';
      FAppContext.SysLog(llError, Format('[TEDCryptImpl][DecodeBase64DecryptRSA] Base64DecodeStr Exception is %s.', [Ex.Message]));
    end;
  end;
  Result := DecryptRSA(Result);
end;

end.
