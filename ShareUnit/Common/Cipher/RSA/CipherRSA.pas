unit CipherRSA;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-1
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Math,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  IdCTypes,
  IdGlobal,
  EncdDecd,
  NetEncoding,
  IdSSLOpenSSLHeaders;//IdSSLOpenSSLHeadersEx;

const
  RSA_KEYBITS = 2048;

  fn_RSA_sign_ex = 'RSA_sign';
  fn_RSA_verify_ex = 'RSA_verify';

  RSA_DEFAULT_FILEPATH = 'RSA\RSA';
  PUBLIC_KEY_FILENAME_SUFFIX = '.publickey';
  PRIVATE_KEY_FILENAME_SUFFIX = '.privatekey';

type

  TKey = class
  private
  protected
    // 存储 RSA 密钥信息
    FRSA: PRSA;
    // 默认文件名
    FDefaultFileName: string;

    // 获取 RSA
    function GetRSA: PRSA;
    // 设置 RSA
    procedure SetRSA(ARSA: PRSA);
    // 释放 key
    procedure ClearRSA(var ARSA: PRSA);
  public
    // 构造方法
    constructor Create;
    // 析构方法
    destructor Destroy; override;
    // 从字节数数组加载 Key
    procedure LoadKey(ABytes: TBytes); overload; virtual;
    // 从流中加载 Key
    procedure LoadKey(AStream: TStream); overload; virtual;
    // 从文件加载 Key
    procedure LoadKey(AFileName: string); overload; virtual;
    // 存储 Key 到字节数据
    procedure KeyToBytes(var ABytes: TBytes); virtual; abstract;
    // 存储 Key 到流
    procedure KeyToStream(var AStream: TStream);
    // 存储 key 到文件
    procedure KeyToFileName(AKeyFileName: string);
    // 存储 Base64 到文件
    procedure Base64KeyToFileName(AKeyFileName: string);
  end;

  TPublicKey = class(TKey)
  protected
  public
    // 构造方法
    constructor Create;
    // 析构方法
    destructor Destroy; override;
    // 从字节数数组加载 Key
    procedure LoadKey(ABytes: TBytes); override;
    // 存储 Key 到字节数据
    procedure KeyToBytes(var ABytes: TBytes); override;

    property PublicRSA: PRSA read GetRSA write SetRSA;
  end;

  TPrivateKey = class(TKey)
  protected
  public
    // 构造方法
    constructor Create;
    // 析构方法
    destructor Destroy; override;
    // 从字节数数组加载 Key
    procedure LoadKey(ABytes: TBytes); override;
    // 存储 Key 到字节数据
    procedure KeyToBytes(var ABytes: TBytes); override;

    property PrivateRSA: PRSA read GetRSA write SetRSA;
  end;

  TCipherRSA = class
  private
    FKeyBits: Integer;
    // 是不是已经初始化
    FIsInitRSA: boolean;
    // 公钥
    FPublicKey: TPublicKey;
    // 私钥
    FPrivateKey: TPrivateKey;
  protected
    // 初始化
    procedure InitRSA;
    // 释放资源
    procedure UnInitRSA;
  public
    // 构造方法
    constructor Create;
    // 析构方法
    destructor Destroy; override;
    //
    procedure LoadKeys(AFileName: string = '');
    //
    procedure PublicKeyToBytes(var ABytes: TBytes);
    //
    procedure PrivateKeyToBytes(var ABytes: TBytes);
    // 从字节数数组加载 Key
    procedure LoadPublicKey(ABytes: TBytes); overload;
    // 从字节数数组加载 Key
    procedure LoadPrivateKey(ABytes: TBytes); overload;
    // 从文件加载公钥
    procedure LoadPublicKey(AFileName: string); overload;
    // 从文件加载私钥
    procedure LoadPrivateKey(AFileName: string); overload;
    // 生成密钥对
    procedure GenerateKeyPair(AKeyBits: Integer = RSA_KEYBITS);
    // 加密
    procedure Encrypt(APlain: TBytes; var ACiper: TBytes);
    // 解密
    procedure Decrypt(ACiper: TBytes; var APlain: TBytes);
    // 签名
    function Sign(AData: TBytes; var ASigData: TBytes): boolean;
    // 认证
    function Verify(AData: TBytes; var ASigData: TBytes): boolean;
  end;

implementation

var
  RSA_sign_ex: function(_type : TIdC_INT; const m : PIdAnsiChar; m_length : TIdC_UINT;
      sigret : PIdAnsiChar; siglen : PIdC_UINT; const rsa : PRSA) : TIdC_INT; cdecl = nil;
  RSA_verify_ex : function(dtype : TIdC_INT; const m : PIdAnsiChar; m_length : PIdC_UINT;
      sigbuf : PIdAnsiChar; siglen : PIdC_UINT; const rsa :PRSA) : TIdC_INT; cdecl = nil;

{ TKey }

constructor TKey.Create;
begin
  inherited;
  FRSA := nil;
end;

destructor TKey.Destroy;
begin
  ClearRSA(FRSA);
  inherited;
end;

function TKey.GetRSA: PRSA;
begin
  Result := FRSA;
end;

procedure TKey.SetRSA(ARSA: PRSA);
begin
  ClearRSA(FRSA);
  FRSA := ARSA;
end;

procedure TKey.ClearRSA(var ARSA: PRSA);
begin
  if ARSA <> nil then begin
    RSA_free(ARSA);
    ARSA := nil;
  end;
end;

procedure TKey.LoadKey(ABytes: TBytes);
begin

end;

procedure TKey.LoadKey(AStream: TStream);
var
  LBytes: TBytes;
  LKeyLen: Integer;
begin
  if AStream = nil then Exit;
  LKeyLen := AStream.Size - AStream.Position;
  if LKeyLen <= 0 then Exit;
  SetLength(LBytes, LKeyLen);
  AStream.Write(LBytes, LKeyLen);
  LoadKey(LBytes);
end;

procedure TKey.LoadKey(AFileName: string);
var
  LBytes: TBytes;
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    SetLength(LBytes, LFileStream.Size);
    ZeroMemory(@LBytes[0], LFileStream.Size);
    LFileStream.Read(LBytes, LFileStream.Size);
    LoadKey(LBytes);
  finally
    LFileStream.Free;
  end;
end;

procedure TKey.KeyToStream(var AStream: TStream);
var
  LBytes: TBytes;
  LKeyLen: Integer;
begin
  KeyToBytes(LBytes);
  LKeyLen := Length(LBytes);
  if LKeyLen > 0 then begin
    AStream.Write(LBytes, LKeyLen);
    SetLength(LBytes, 0);
  end;
end;

procedure TKey.KeyToFileName(AKeyFileName: string);
var
  LBytes: TBytes;
  LKeyLen: Integer;
  LFilePath: string;
  LFileStream: TFileStream;
begin
  LFilePath := ExtractFilePath(AKeyFileName);
  if not FileExists(LFilePath) then begin
    ForceDirectories(LFilePath);
  end;
  KeyToBytes(LBytes);
  LKeyLen := Length(LBytes);
  if LKeyLen > 0 then begin
    LFileStream := TFileStream.Create(AKeyFileName, fmCreate);
    try
      LFileStream.Position := 0;
      LFileStream.Write(LBytes, LKeyLen);
      SetLength(LBytes, 0);
    finally
      LFileStream.Free;
    end;
  end;
end;

procedure TKey.Base64KeyToFileName(AKeyFileName: string);
var
  LBytes: TBytes;
  LKeyLen: Integer;
  LFilePath: string;
  LMStream: TMemoryStream;
  LFileStream: TFileStream;
begin
  LFilePath := ExtractFilePath(AKeyFileName);
  if not FileExists(LFilePath) then begin
    ForceDirectories(LFilePath);
  end;
  KeyToBytes(LBytes);
  LKeyLen := Length(LBytes);
  if LKeyLen > 0 then begin
    LMStream := TMemoryStream.Create;
    LFileStream := TFileStream.Create(AKeyFileName, fmCreate);
    try
      LMStream.Position := 0;
      LMStream.Write(LBytes, LKeyLen);
      LMStream.Position := 0;
      LFileStream.Position := 0;
      TNetEncoding.Base64.Encode(LMStream, LFileStream);
      SetLength(LBytes, 0);
    finally
      LFileStream.Free;
      LMStream.Free;
    end;
  end;
end;

{ TPublicKey }

constructor TPublicKey.Create;
begin
  inherited;

end;

destructor TPublicKey.Destroy;
begin

  inherited;
end;

procedure TPublicKey.LoadKey(ABytes: TBytes);
var
  ARSA: PRSA;
  LKeyLen: Integer;
  LBufAddr: PAnsiChar;
begin
  LKeyLen := Length(ABytes);
  if LKeyLen <= 0 then Exit;

  LBufAddr := Addr(ABytes[0]);
  ARSA := d2i_RSAPublicKey(nil, @LBufAddr, LKeyLen);
  if FRSA <> nil then begin
    ClearRSA(FRSA);
  end;
  FRSA := ARSA;
end;

procedure TPublicKey.KeyToBytes(var ABytes: TBytes);
var
  LKeyLen: Integer;
  LBufAddr: PAnsiChar;
begin
  SetLength(ABytes, 0);
  if FRSA = nil then Exit;

  LKeyLen := i2d_RSAPublicKey(FRSA, nil);
  SetLength(ABytes, LKeyLen);
  ZeroMemory(@ABytes[0], LKeyLen);
  LBufAddr := Addr(ABytes[0]);
  i2d_RSAPublicKey(FRSA, @LBufAddr);
end;

{ TPrivateKey }

constructor TPrivateKey.Create;
begin
  inherited;

end;

destructor TPrivateKey.Destroy;
begin

  inherited;
end;

procedure TPrivateKey.LoadKey(ABytes: TBytes);
var
  ARSA: PRSA;
  LKeyLen: Integer;
  LBufAddr: PAnsiChar;
begin
  LKeyLen := Length(ABytes);
  if LKeyLen <= 0 then  Exit;

  LBufAddr := Addr(ABytes[0]);
  ARSA := d2i_RSAPrivateKey(nil, @LBufAddr, LKeyLen);
  if FRSA <> nil then begin
    ClearRSA(FRSA);
  end;
  FRSA := ARSA;
end;

procedure TPrivateKey.KeyToBytes(var ABytes: TBytes);
var
  LKeyLen: Integer;
  LBufAddr: PAnsiChar;
begin
  SetLength(ABytes, 0);
  if FRSA = nil then Exit;

  LKeyLen := i2d_RSAPrivateKey(FRSA, nil);
  SetLength(ABytes, LKeyLen);
  ZeroMemory(@ABytes[0], LKeyLen);
  LBufAddr := Addr(ABytes[0]);
  i2d_RSAPrivateKey(FRSA, @LBufAddr);
end;

{ TCipherRSA }

constructor TCipherRSA.Create;
begin
  inherited;
  FKeyBits := RSA_KEYBITS;
  FPublicKey := TPublicKey.Create;
  FPrivateKey := TPrivateKey.Create;
  FIsInitRSA := False;
  InitRSA;
end;

destructor TCipherRSA.Destroy;
begin
  UnInitRSA;
  FPrivateKey.Free;
  FPublicKey.Free;
  inherited;
end;

procedure TCipherRSA.InitRSA;
const
  SSLCLIB_DLL_name = 'libeay32.dll';
var
  LhIdSSL: HMODULE;

  function LoadFunction(const FceName: {$IFDEF WINCE}TIdUnicodeString{$ELSE}string{$ENDIF}; const ACritical : Boolean = True): Pointer;
  begin
    LhIdSSL := SafeLoadLibrary(SSLCLIB_DLL_name);
    Result := {$IFDEF WINDOWS}Windows.{$ENDIF}GetProcAddress(LhIdSSL, {$IFDEF WINCE}PWideChar{$ELSE}PChar{$ENDIF}(FceName));
//    if (Result = nil) and ACritical then begin
//      FFailedLoadList.Add(FceName); {do not localize}
//    end;
  end;
begin
  try
    Load;
//    @RSA_sign_ex := LoadFunction(fn_RSA_sign_ex);
//    @RSA_verify_ex := LoadFunction(fn_RSA_verify_ex);
    FIsInitRSA := True;
  except

  end;
end;

procedure TCipherRSA.UnInitRSA;
begin

end;

procedure TCipherRSA.GenerateKeyPair(AKeyBits: integer = 2048);
var
  ARSA: PRSA;
begin
  FKeyBits := AKeyBits;
  if FIsInitRSA then begin
    // 生成2048位的密钥
    ARSA := RSA_generate_key(FKeyBits, 65537, nil, nil);
    if ARSA <> nil then begin
      FPublicKey.PublicRSA := ARSA;
//      FPrivateKey.PrivateRSA := ARSA;
    end;
  end;
end;

procedure TCipherRSA.Encrypt(APlain: TBytes; var ACiper: TBytes);
var
  LPublicRSA: PRSA;
  LPlainLen, LCiperLen, LRSAMaxLen: Integer;
begin
  LPlainLen := Length(APlain);
  LPublicRSA := FPublicKey.GetRSA;
  if (LPublicRSA <> nil) and (LPlainLen > 0) then begin
    LRSAMaxLen := RSA_size(LPublicRSA);
    LPlainLen := Min(LPlainLen, LRSAMaxLen - 11);
    SetLength(ACiper, LRSAMaxLen);
    LCiperLen := RSA_public_encrypt(LPlainLen, Pointer(APlain), Pointer(ACiper),
      LPublicRSA, RSA_PKCS1_PADDING);
    if LCiperLen = -1 then begin
      LCiperLen := 0;
    end;
  end else begin
    LCiperLen := 0;
  end;
  SetLength(ACiper, LCiperLen);
end;

procedure TCipherRSA.Decrypt(ACiper: TBytes; var APlain: TBytes);
var
  LPrivateRSA: PRSA;
  LPlainLen, LCiperLen, LRSAMaxLen: Integer;
begin
  LCiperLen := Length(ACiper);
  LPrivateRSA := FPrivateKey.GetRSA;
  if LPrivateRSA = nil then begin
    LPrivateRSA := FPublicKey.GetRSA;
  end;
  if (LPrivateRSA <> nil) and (LCiperLen > 0) then begin
    LRSAMaxLen := RSA_size(LPrivateRSA);
    SetLength(APlain, LRSAMaxLen);
    LPlainLen := RSA_private_decrypt(LCiperLen, Pointer(ACiper), Pointer(APlain),
      LPrivateRSA, RSA_PKCS1_PADDING);
    if LPlainLen = -1 then begin
      LPlainLen := 0;
    end;
  end else begin
    LPlainLen := 0;
  end;
  SetLength(APlain, LPlainLen);
end;

procedure TCipherRSA.LoadKeys(AFileName: string = '');
var
  LFileName: string;
begin
  LFileName := ExtractFilePath(ParamStr(0)) + RSA_DEFAULT_FILEPATH;
  FPublicKey.LoadKey(LFileName + PUBLIC_KEY_FILENAME_SUFFIX);
  FPrivateKey.LoadKey(LFileName + PRIVATE_KEY_FILENAME_SUFFIX);
end;

procedure TCipherRSA.PublicKeyToBytes(var ABytes: TBytes);
begin
  FPublicKey.KeyToBytes(ABytes);
end;

procedure TCipherRSA.PrivateKeyToBytes(var ABytes: TBytes);
begin
  FPrivateKey.KeyToBytes(ABytes);
end;

procedure TCipherRSA.LoadPublicKey(ABytes: TBytes);
begin
  FPublicKey.LoadKey(ABytes);
end;

procedure TCipherRSA.LoadPrivateKey(ABytes: TBytes);
begin
  FPrivateKey.LoadKey(ABytes);
end;

procedure TCipherRSA.LoadPublicKey(AFileName: string);
begin
  FPublicKey.LoadKey(AFileName);
end;

procedure TCipherRSA.LoadPrivateKey(AFileName: string);
begin
  FPrivateKey.LoadKey(AFileName);
end;

function TCipherRSA.Sign(AData: TBytes; var ASigData: TBytes): Boolean;
const
  BUF_LEN = 1024;
var
  LRSA: PRSA;
  LRet: Integer;
  LData: PAnsiChar;
  LMD_CTX : EVP_MD_CTX;
  LMLen, LSigLen: Cardinal;
  LMBuf, LSigBuf: array [0 .. BUF_LEN - 1] of AnsiChar;
begin
  Result := False;
  LRSA := FPrivateKey.GetRSA;
  if LRSA = nil then begin
    LRSA := FPublicKey.GetRSA;
    if LRSA = nil then Exit;
  end;
  LData := PAnsiChar(AData);
  ZeroMemory(@LMBuf, BUF_LEN);
  ZeroMemory(@LSigBuf, BUF_LEN);
//  RSA_private_encrypt
  {
    @function  EVP_SignInit
    本函数也是一个宏定义函数，其定义如下：
    #define EVP_SignInit(a,b)  EVP_DigestInit(a,b)
    所以其功能和用法跟前面介绍的EVP_DigestInit函数完全一样，使
    用缺省实现的算法初始化算法结构 ctx。
  }
  EVP_MD_CTX_init(@LMD_CTX);
  try
  {
      @function  EVP_SignInit_ex
      该函数是一个宏定义函数，其实际定义如下：
      #define EVP_SignInit_ex(a,b,c)  EVP_DigestInit_ex(a,b,c)
      可见，该函数跟前面叙述的 EVP_DigestInit_ex的功能和使用方法
      是一样的，都是使用ENGINE参数impl所代表的实现函数功能来设置
      结构ctx。在调用本函数前，参数ctx一定要经过 EVP_MD_CTX_init
      函数初始化。
      详细使用方法参看前面的文章介绍。成功返回1，失败返回0。
    }
    LRet := EVP_SignInit(@LMD_CTX, EVP_sha1());
    if LRet = 0 then Exit;

    {
      @function EVP_SignUpdate
      该函数也是一个宏定义函数，其实际定义如下：
      #define EVP_SignUpdate(a,b,c)  EVP_DigestUpdate(a,b,c)
      该函数使用方法和功能也跟前面介绍的EVP_DigestUpdate函数一样，
      将一个 cnt字节的数据经过信息摘要运算存储到结构ctx中，该函数
      可以在一个相同的ctx中调用多次来实现对更多数据的信息摘要工作。
      成功返回1，失败返回0。
    }
    LRet := EVP_SignUpdate(@LMD_CTX, LData, Length(AData));
    if LRet = 0 then Exit;
    {
      @function EVP_SignFinal and EVP_DigestFinal_ex
      该函数功能跟EVP_DigestFinal_ex 函数相同，但是ctx结构会自动
      清除。一般来说，现在新的程序应该使用 EVP_DigestInit_ex 和
      EVP_DigestFinal_ex 函数，因为这些函数可以在使用完一个
      EVP_MD_CTX结构后，不用重新声明和初始化该结构就能使用它进行
      新的数据处理，而且新的带_ex的函数也可以使用非缺省的实现算法库。

      该函数跟前面两个函数不同，这是签名系列函数跟信息摘要函数开
      始不同的地方，其实，该函数是将签名操作的信息摘要结构ctx 拷
      贝一份，然后调用EVP_DigestFinal_ex完成信息摘要工作，然后开
      始对摘要信息用私钥pkey进行签名,并将签名信息保存在参数sig里
      面。如果参数s不为 NULL，那么就会将签名信息数据的长度（单位
      字节）保存在该参数中，通常写入的数据是EVP_PKEY_size(key)。
      因为操作的时候是拷贝了一份ctx，所以，原来的ctx结构还可以继
      续使用EVP_SignUpdate和 EVP_SignFinal函数来完成更多信息的签
      名工作。不过，最后一定要使用EVP_MD_CTX_cleanup函数清除和释
      放ctx结构，否则就会造成内存泄漏。
      此外，当使用DSA 私钥签名的时候，一定要对产生的随机数进行种
      子播种工作（seeded)，否则操作就会失败。RSA算法则不一定需要
      这样做。至于使用的签名算法跟摘要算法的关系，在EVP_Digest系
      列中已经有详细说明，这里不再重复。
      本函数操作成功返回1，否则返回0。
    }
    LMLen := BUF_LEN;
    LRet := EVP_DigestFinal_ex(@LMD_CTX, LMBuf, LMLen);
    if LRet = 0 then Exit;

    LRet := RSA_sign_ex(NID_SHA1withRSA, LMBuf, LMLen, LSigBuf, @LSigLen, LRSA);
    if LRet = 1 then begin
      Result := True;
      SetLength(ASigData, LSigLen);
      CopyMemory(@ASigData[0], @LSigBuf[0], LSigLen);
    end;
  finally
    EVP_MD_CTX_cleanup(@LMD_CTX);
  end;
end;

function TCipherRSA.Verify(AData: TBytes; var ASigData: TBytes): Boolean;
const
  BUF_LEN = 1024;
var
  LRSA: PRSA;
  LRet: Integer;
  LData: PAnsiChar;
  LMD_CTX : EVP_MD_CTX;
  LMLen, LSigLen, LError: Cardinal;
  LMBuf, LSigBuf, LErrBuf: array [0 .. BUF_LEN - 1] of AnsiChar;
begin
  Result := False;
  LRSA := FPublicKey.GetRSA;
  if LRSA = nil then begin
    LRSA := FPrivateKey.GetRSA;
    if LRSA = nil then Exit;
  end;
  LData := PAnsiChar(AData);
  ZeroMemory(@LMBuf, BUF_LEN);
  ZeroMemory(@LSigBuf, BUF_LEN);
  LSigLen := Length(ASigData);
  CopyMemory(@LSigBuf[0], @ASigData[0], Length(ASigData));
  EVP_MD_CTX_init(@LMD_CTX);
  try
    LRet := EVP_VerifyInit(@LMD_CTX, EVP_sha1());
    if LRet = 0 then Exit;
    LRet := EVP_VerifyUpdate(@LMD_CTX, LData, Length(AData));
    if LRet = 0 then Exit;

//    LRet := EVP_VerifyFinal(LMD_CTX, LSigBuf, LSigLen, LRSA);
    LRet := EVP_DigestFinal_ex(@LMD_CTX, LMBuf, LMLen);

//    LRet := EVP_DigestVerifyFinal(@LMD_CTX, LSigBuf, LSigLen);
    if LRet = 0 then Exit;

    LRet := RSA_verify_ex(EVP_sha1()._type, LMBuf, @LMLen, LSigBuf, @LSigLen, LRSA);
    if LRet = 1 then begin
      Result := True;
    end else begin
      LError := ERR_get_error;
      ZeroMemory(@LErrBuf, BUF_LEN);
      ERR_error_string(LError, LErrBuf);
    end;
  finally
    EVP_MD_CTX_cleanup(@LMD_CTX);
  end;
end;

end.
