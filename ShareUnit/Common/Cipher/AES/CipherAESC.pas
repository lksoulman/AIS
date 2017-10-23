unit CipherAES;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Cipher AES
// Author：      lksoulman
// Date：        2017-8-2
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  AES,
  ElAES,
  Windows,
  Classes,
  SysUtils,
  AESEncript;

type

  // Cipher AES
  TCipherAES = class
  private
    // Key Buf
    FKey128Buf: TAESBuffer;
    //

  protected
  public
    // 构造方法
    constructor Create;
    // 析构方法
    destructor Destroy; override;
    // 加载 Key 128
    procedure LoadKey128(AKey: AnsiString; ABuffer: TAESBuffer);
    // 加密方法
    function Encrypt128(APlain: AnsiString): AnsiString;
    // 解密方法
    function Decrypt128(ACiper: AnsiString): AnsiString;
  end;

implementation

{ TCipherAES }

constructor TCipherAES.Create;
begin
  inherited;

end;

destructor TCipherAES.Destroy;
begin

  inherited;
end;

procedure TCipherAES.LoadKey128(AKey: AnsiString);
begin
  CopyMemory(@FKey128Buf[0], @AKey[0], Length(AKey));
end;

function TCipherAES.Encrypt128(APlain: AnsiString): AnsiString;
begin
  Result := AES.EncryptString128B64(APlain, FKey128B, FKey128Buf);
end;

function TCipherAES.Decrypt128(ACiper: AnsiString): AnsiString;
begin
  Result := AESEncript.DecryptString128B64(ACiper, FKey128B, FKey128Buf);
end;

end.
