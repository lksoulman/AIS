unit CipherMgrImpl;

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
  SysUtils,
  CipherRSA,
  CipherAES,
  CipherMgr,
  AppContext,
  SyncAsyncImpl;

type

  // Encryption and decryption management interface implementation
  TCipherMgrImpl = class(TSyncAsyncImpl, ICipherMgr)
  private
    // is Init RSA
    FIsInitRSA: Boolean;
    // is Init AES
    FIsInitAES: Boolean;
    // RSA object
    FCipherRSA: TCipherRSA;
    // AES object
    FCipherAES: TCipherAES;
  protected
    // Init RSA
    procedure DoInitCipherRSA;
    // Init AES
    procedure DoInitCipherAES;
  public
     // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    {ISyncAsync}

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;

    { ICipherMgr }

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

uses
  ElAES,
  Base64,
  WExport,
  AESEncript,
  FastLogLevel;

const

  // 服务端公钥
  RSA_PRIVATE_KEY = 'MIIEpQIBAAKCAQEAsG69YPAQULQ9H2/sGYNf1dw7XUkQ2jWu0PSE6WfQW+h'
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

  // 服务端私钥
  RSA_PUBLIC_KEY = 'MIIBCgKCAQEAsG69YPAQULQ9H2/sGYNf1dw7XUkQ2jWu0PSE6WfQW+hPF9R0'
    + 'b0a22c5jqdXEGdWZrEwebyfOmT3guRtIJJ8VKfC8NgOe48Ypdzd5WQ4wZizGSvB08oGSRTCKh'
    + 'L2FoxjRYM5PVpT9rRq8Uy7MNmsEMfjqwnj7FNIQyMhvYWMkaAzoGiVf7ZKLyUj6hQ4Yx1yayi'
    + 'nZ2gdqL0EmZYwvpANFybJhKUW7Ph0c0Flz5O7nD3ALWGmDb9K8NXbqzjRPbmEx36Ydv7COk8G'
    + '0BtVh5TtShgdBrKPNrAHURyBhmqhl2U87RS1/pibkQIYtVxnYgQed905PIcb4+8uDPtw+7MvA'
    + 'TQIDAQAB';

  AES_KEY                = '12ede%de';
  AES_KEYBIT             = 'po98&^jn';
  AES_KEYBUF: TAESBuffer = ($41, $72, $65, $79, $6F, $75, $6D, $79, $53,
    $6E, $6F, $77, $6D, $61, $6E, $3F);

constructor TCipherMgrImpl.Create;
begin
  inherited;
  FIsInitRSA := False;
  FIsInitAES := False;
  FCipherRSA := TCipherRSA.Create;
  FCipherAES := TCipherAES.Create;
end;

destructor TCipherMgrImpl.Destroy;
begin
  FCipherAES.Free;
  FCipherRSA.Free;
  inherited;
end;

procedure TCipherMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TCipherMgrImpl.UnInitialize;
begin

end;

procedure TCipherMgrImpl.SyncBlockExecute;
begin
  DoInitCipherRSA;
  DoInitCipherAES;
end;

procedure TCipherMgrImpl.AsyncNoBlockExecute;
begin

end;

function TCipherMgrImpl.AESEncrypt128(APlain: AnsiString): AnsiString;
begin
  Result := '';
  try
    Result := FCipherAES.Encrypt128(APlain);
  except
    on Ex: Exception do begin
      Result := '';
      if FAppContext <> nil then begin
        FastSysLog(llError, Format('[TCipherMgrImpl][AES_Encrypt128] FCipherAES.Encrypt128 Exception is %s.', [Ex.Message]));
      end;
    end;
  end;
end;

function TCipherMgrImpl.AESDecrypt128(ACiper: AnsiString): AnsiString;
begin
  Result := '';
  try
    Result := FCipherAES.Decrypt128(ACiper);
  except
    on Ex: Exception do begin
      Result := '';
      if FAppContext <> nil then begin
        FastSysLog(llError, Format('[TCipherMgrImpl][RSA_EncryptAndBase64] FCipherAES.Decrypt128 Exception is %s.', [Ex.Message]));
      end;
    end;
  end;
end;

function TCipherMgrImpl.RSAEncryptAndBase64(APlain: AnsiString): AnsiString;
var
  LPlainBytes, LCiperBytes: TBytes;
begin
  Result := '';
  SetLength(LPlainBytes, Length(APlain));
  CopyMemory(@LPlainBytes[0], @APlain[1], Length(APlain));
  try
    FCipherRSA.Encrypt(LPlainBytes, LCiperBytes);
  except
    on Ex: Exception do begin
      Result := '';
      FastSysLog(llError, Format('[TCipherMgrImpl][RSA_EncryptAndBase64] FCipherRSA.Encrypt Exception is %s.', [Ex.Message]));
    end;
  end;
  SetLength(Result, Length(LCiperBytes));
  CopyMemory(@Result[1], @LCiperBytes[0], Length(LCiperBytes));
  try
    Result := Base64EncodeStr(Result);
  except
    on Ex: Exception do begin
      Result := '';
      FastSysLog(llError, Format('[TCipherMgrImpl][RSA_EncryptAndBase64] Base64EncodeStr Exception is %s.', [Ex.Message]));
    end;
  end;
end;

function TCipherMgrImpl.RSABase64AndDecrypt(ACiper: AnsiString): AnsiString;
var
  LPlainBytes, LCiperBytes: TBytes;
begin
  try
    Result := Base64DecodeStr(ACiper);
  except
    on Ex: Exception do begin
      Result := '';
      FastSysLog(llError, Format('[TCipherMgrImpl][RSA_Base64AndDecrypt] Base64DecodeStr Exception is %s.', [Ex.Message]));
    end;
  end;
  SetLength(LCiperBytes, Length(Result));
  CopyMemory(@LCiperBytes[0], @Result[1], Length(Result));
  try
    FCipherRSA.Decrypt(LCiperBytes, LPlainBytes);
  except
    on Ex: Exception do begin
      Result := '';
      FastSysLog(llError, Format('[TCipherMgrImpl][RSA_Base64AndDecrypt] FCipherRSA.Decrypt Exception is %s.', [Ex.Message]));
    end;
  end;
  SetLength(Result, Length(LPlainBytes));
  CopyMemory(@Result[1], @LPlainBytes[0], Length(LPlainBytes));
end;

procedure TCipherMgrImpl.DoInitCipherRSA;
var
  LLen: Integer;
  LBytes: TBytes;
  LBase64Str: UTF8String;
  LStr, LTestStr: AnsiString;
begin
  try
    // Base64 可以
    LBase64Str := RSA_PUBLIC_KEY;
    SetLength(LBytes, (Length(LBase64Str) div 4) * 3);
    LLen := Base64Decode(@LBase64Str[1],@LBytes[0], Length(LBase64Str));
    SetLength(LBytes, LLen);
    FCipherRSA.LoadPublicKey(LBytes);

    // 客户端只需加密，不用加载私钥
    LBase64Str := RSA_PRIVATE_KEY;
    SetLength(LBytes, (Length(LBase64Str) div 4) * 3);
    LLen := Base64Decode(@LBase64Str[1],@LBytes[0], Length(LBase64Str));
    SetLength(LBytes, LLen);
    FCipherRSA.LoadPrivateKey(LBytes);

    LStr := 'Hello';
    LTestStr := LStr;
    LTestStr := RSAEncryptAndBase64(LTestStr);
    LTestStr := RSABase64AndDecrypt(LTestStr);
    if LStr = LTestStr then begin
      FIsInitRSA := True;
    end;
  except
    on Ex: Exception do begin
      FIsInitRSA := False;
      FastSysLog(llError, Format('[TCipherMgrImpl][DoInitCipherRSA] Exception is %s.', [Ex.Message]));
    end;
  end;
end;

procedure TCipherMgrImpl.DoInitCipherAES;
var
  LKEY: AnsiString;
begin
  try
    LKEY := AESEncript.EncryptString(AES_KEY, AES_KEYBIT);
    FCipherAES.LoadKey128(LKEY, AES_KEYBUF);
    FIsInitAES := True;
  except
    on Ex: Exception do begin
      FIsInitAES := False;
      FastSysLog(llError, Format('[TCipherMgrImpl][DoInitCipherAES] Exception is %s, AESEncript.EncryptString FCipherAES.LoadKey128.', [Ex.Message]));
    end;
  end;
end;

end.
