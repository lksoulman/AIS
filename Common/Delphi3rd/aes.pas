(**************************************************)
(*                                                *)
(*     Advanced Encryption Standard (AES)         *)
(*     Interface Unit v1.3                        *)
(*                                                *)
(*                                                *)
(*     Copyright (c) 2002 Jorlen Young            *)
(*                                                *)
(*                                                *)
(*                                                *)
(*说明：                                          *)
(*                                                *)
(*   基于 ElASE.pas 单元封装                      *)
(*                                                *)
(*   这是一个 AES 加密算法的标准接口。            *)
(*                                                *)
(*                                                *)
(*   作者：杨泽晖      2004.12.04                 *)
(*                                                *)
(*   支持 128 / 192 / 256 位的密匙                *)                
(*   默认情况下按照 128 位密匙操作                *)
(*                                                *)
(**************************************************)

unit aes;// 申明文件名称

interface

uses
  SysUtils, Classes, Math, ElAES;

const
  IV = 'L+\~f4,Ir)b$=pkf';
  IV_U8: UTF8String = 'L+\~f4,Ir)b$=pkf';

type
  TKeyBit = (kb128, kb192, kb256);

function StrToHex(Value: AnsiString): AnSiString;
function HexToStr(Value: AnsiString): AnSiString;
function EncryptString(Value: AnSiString; Key: AnSiString;
  KeyBit: TKeyBit = kb128): AnSiString;
function DecryptString(Value: AnSiString; Key: AnSiString;
  KeyBit: TKeyBit = kb128): AnSiString;
function EncryptStringCBC(Value: AnSiString; Key: AnSiString;
  KeyBit: TKeyBit = kb128): AnSiString;
function DecryptStringCBC(Value: AnSiString; Key: AnSiString;
  KeyBit: TKeyBit = kb128): AnSiString;
function EncryptStream(Stream: TStream; Key: AnSiString;
  KeyBit: TKeyBit = kb128): TStream;
function DecryptStream(Stream: TStream; Key: AnSiString;
  KeyBit: TKeyBit = kb128): TStream;
procedure EncryptFile(SourceFile, DestFile: AnSiString;
  Key: AnSiString; KeyBit: TKeyBit = kb128);
procedure DecryptFile(SourceFile, DestFile: AnSiString;
  Key: AnSiString; KeyBit: TKeyBit = kb128);
function EncryptStringCBC2(Value: string; Key: string;
  KeyBit: TKeyBit = kb128): string;
function DecryptStringCBC2(Value: string; Key: string;
  KeyBit: TKeyBit = kb128): string;

function EncryptBinaryCBC(Value: RawByteString; Key: RawByteString;
  KeyBit: TKeyBit = kb128): RawByteString;
function DecryptBinaryCBC(Value: RawByteString; Key: RawByteString;
  KeyBit: TKeyBit = kb128): RawByteString;
function EncryptBinaryECB(Value: RawByteString; Key: RawByteString;
  KeyBit: TKeyBit = kb128): RawByteString;
function DecryptBinaryECB(Value: RawByteString; Key: RawByteString;
  KeyBit: TKeyBit = kb128): RawByteString;

implementation

function StrToHex(Value: AnsiString): AnSiString;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Value) do
    Result := Result + IntToHex(Ord(Value[I]), 2);
end;

function HexToStr(Value: AnsiString): AnSiString;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Value) do
  begin
    if ((I mod 2) = 1) then
      Result := Result + Chr(StrToInt('0x'+ Copy(Value, I, 2)));
  end;
end;

{  --  字符串加密函数 默认按照 128 位密匙加密 --  }
function EncryptString(Value: AnSiString; Key: AnSiString;
  KeyBit: TKeyBit = kb128): AnSiString;
var
  SS, DS: TStringStream;
  Size: Int64;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
begin
  Result := '';
  SS := TStringStream.Create(Value);
  DS := TStringStream.Create('');
  try
    Size := SS.Size;
    DS.WriteBuffer(Size, SizeOf(Size));
    {  --  128 位密匙最大长度为 16 个字符 --  }
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      Move(PChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
      EncryptAESStreamECB(SS, 0, AESKey128, DS);
    end;
    {  --  192 位密匙最大长度为 24 个字符 --  }
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      EncryptAESStreamECB(SS, 0, AESKey192, DS);
    end;
    {  --  256 位密匙最大长度为 32 个字符 --  }
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      EncryptAESStreamECB(SS, 0, AESKey256, DS);
    end;
    Result := StrToHex(DS.DataString);
  finally
    SS.Free;
    DS.Free;
  end;
end;

{  --  字符串解密函数 默认按照 128 位密匙解密 --  }
function DecryptString(Value: AnSiString; Key: AnSiString;
  KeyBit: TKeyBit = kb128): AnSiString;
var
  SS, DS: TStringStream;
  Size: Int64;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
begin
  Result := '';
  SS := TStringStream.Create(HexToStr(Value));
  DS := TStringStream.Create('');
  try
    Size := SS.Size;
    SS.ReadBuffer(Size, SizeOf(Size));
    {  --  128 位密匙最大长度为 16 个字符 --  }
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      Move(PChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
      DecryptAESStreamECB(SS, SS.Size - SS.Position, AESKey128, DS);
    end;
    {  --  192 位密匙最大长度为 24 个字符 --  }
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      DecryptAESStreamECB(SS, SS.Size - SS.Position, AESKey192, DS);
    end;
    {  --  256 位密匙最大长度为 32 个字符 --  }
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      DecryptAESStreamECB(SS, SS.Size - SS.Position, AESKey256, DS);
    end;
    Result := DS.DataString;
  finally
    SS.Free;
    DS.Free;
  end;
end;

{  --  字符串加密函数 默认按照 128 位密匙加密 CBC Mode--  }
function EncryptStringCBC(Value: AnSiString; Key: AnSiString;
  KeyBit: TKeyBit = kb128): AnSiString;
var
  SS, DS: TStringStream;
  Size: Int64;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  AESBuffer: TAESBuffer;
  utf8str : AnsiString;
begin
  Result := '';
  SS := TStringStream.Create(AnsiString(Value));
  DS := TStringStream.Create('');
  try
    Size := SS.Size;
    DS.WriteBuffer(Size, SizeOf(Size));

    FillChar(AESBuffer, SizeOf(AESBuffer), 0 );
    utf8str := AnsiString(IV);
    Move(utf8str[1], AESBuffer, Min(SizeOf(AESBuffer), Length(utf8str)));
    {  --  128 位密匙最大长度为 16 个字符 --  }
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      utf8str := AnsiString(key);
      Move(utf8str[1], AESKey128[0], Min(SizeOf(AESKey128), Length(utf8str)));
      EncryptAESStreamCBC(SS, 0, AESKey128, AESBuffer, DS);
    end;
    {  --  192 位密匙最大长度为 24 个字符 --  }
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      EncryptAESStreamCBC(SS, 0, AESKey192, AESBuffer, DS);
    end;
    {  --  256 位密匙最大长度为 32 个字符 --  }
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      EncryptAESStreamCBC(SS, 0, AESKey256, AESBuffer, DS);
    end;
    Result := StrToHex(AnsiString(DS.DataString));
  finally
    SS.Free;
    DS.Free;
  end;
end;

{  --  字符串解密函数 默认按照 128 位密匙解密 CBC Mode--  }
function DecryptStringCBC(Value: AnSiString; Key: AnSiString;
  KeyBit: TKeyBit = kb128): AnSiString;
var
  SS, DS: TStringStream;
  Size: Int64;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  AESBuffer: TAESBuffer;
  utf8str : AnsiString;
begin
  Result := '';
  SS := TStringStream.Create(Value);
  DS := TStringStream.Create('');
  try
    Size := SS.Size;
    SS.ReadBuffer(Size, SizeOf(Size));

    FillChar(AESBuffer, SizeOf(AESBuffer), 0 );
    utf8str := AnsiString(IV);
    Move(utf8str[1], AESBuffer[0], Min(SizeOf(AESBuffer), Length(utf8str)));
    {  --  128 位密匙最大长度为 16 个字符 --  }
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      utf8str := AnsiString(Key);
      Move(utf8str[1], AESKey128[0], Min(SizeOf(AESKey128), Length(utf8str)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey128, AESBuffer, DS);
    end;
    {  --  192 位密匙最大长度为 24 个字符 --  }
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey192, AESBuffer, DS);
    end;
    {  --  256 位密匙最大长度为 32 个字符 --  }
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey256, AESBuffer, DS);
    end;
    Result := DS.DataString;
  finally
    SS.Free;
    DS.Free;
  end;
end;

{  --  字符串加密函数 默认按照 128 位密匙加密 CBC Mode--  }
function EncryptStringCBC2(Value: string; Key: string;
  KeyBit: TKeyBit = kb128): string;
var
  SS, DS: TMemoryStream;
  Size: Int64;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  AESBuffer: TAESBuffer;
  ansistr, hexstr : RawByteString;
begin
  Result := '';
  SS := TMemoryStream.Create;
  ansistr := UTF8Encode(Value);
  SS.Write(PAnsiChar(ansistr)^, Length(ansistr));
  SS.Position := 0;
  DS := TMemoryStream.Create;
  try
    Size := SS.Size;
    DS.WriteBuffer(Size, SizeOf(Size));

    FillChar(AESBuffer, SizeOf(AESBuffer), 0 );
    ansistr := AnsiString(IV);
    Move(ansistr[1], AESBuffer, Min(SizeOf(AESBuffer), Length(ansistr)));
    {  --  128 位密匙最大长度为 16 个字符 --  }
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      ansistr := AnsiString(key);
      Move(ansistr[1], AESKey128[0], Min(SizeOf(AESKey128), Length(ansistr)));
      EncryptAESStreamCBC(SS, 0, AESKey128, AESBuffer, DS);
    end;
    {  --  192 位密匙最大长度为 24 个字符 --  }
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      EncryptAESStreamCBC(SS, 0, AESKey192, AESBuffer, DS);
    end;
    {  --  256 位密匙最大长度为 32 个字符 --  }
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      EncryptAESStreamCBC(SS, 0, AESKey256, AESBuffer, DS);
    end;
	  SetString(ansistr, PAnsiChar(DS.Memory), DS.Size);
    SetLength(hexstr, Length(ansistr) * 2);
    BinToHex(PAnsiChar(ansistr), PAnsiChar(hexstr), Length(ansistr));
    Result := string(hexstr);
  finally
    SS.Free;
    DS.Free;
  end;
end;

{  --  字符串解密函数 默认按照 128 位密匙解密 CBC Mode--  }
function DecryptStringCBC2(Value: string; Key: string;
  KeyBit: TKeyBit = kb128): string;
var
  SS, DS: TMemoryStream;
  Size: Int64;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  AESBuffer: TAESBuffer;
  ansistr : RawByteString;
begin
  Result := '';
  SS := TMemoryStream.Create;

  SetLength(ansistr, Length(Value) div 2);
  HexToBin(PWideChar(Value), PAnsiChar(ansistr), Length(ansistr));
  SS.Write(PAnsiChar(ansistr)^, Length(ansistr));
  SS.Position := 0;
  DS := TMemoryStream.Create;
  try
    Size := SS.Size;
    SS.ReadBuffer(Size, SizeOf(Size));

    FillChar(AESBuffer, SizeOf(AESBuffer), 0 );
    ansistr := AnsiString(IV);
    Move(ansistr[1], AESBuffer[0], Min(SizeOf(AESBuffer), Length(ansistr)));
    {  --  128 位密匙最大长度为 16 个字符 --  }
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      ansistr := AnsiString(Key);
      Move(ansistr[1], AESKey128[0], Min(SizeOf(AESKey128), Length(ansistr)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey128, AESBuffer, DS);
    end;
    {  --  192 位密匙最大长度为 24 个字符 --  }
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey192, AESBuffer, DS);
    end;
    {  --  256 位密匙最大长度为 32 个字符 --  }
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey256, AESBuffer, DS);
    end;
	  SetString(ansistr, PAnsiChar(DS.Memory), Size);
    Result := UTF8ToString(ansistr);
  finally
    SS.Free;
    DS.Free;
  end;
end;

{  --  流加密函数 默认按照 128 位密匙解密 --  }
function EncryptStream(Stream: TStream; Key: AnSiString;
  KeyBit: TKeyBit = kb128): TStream;
var
  Count: Int64;
  OutStrm: TStream;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
begin
  OutStrm := TStream.Create;
  Stream.Position := 0;
  Count := Stream.Size;
  OutStrm.Write(Count, SizeOf(Count));
  try
    {  --  128 位密匙最大长度为 16 个字符 --  }
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      Move(PChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
      EncryptAESStreamECB(Stream, 0, AESKey128, OutStrm);
    end;
    {  --  192 位密匙最大长度为 24 个字符 --  }
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      EncryptAESStreamECB(Stream, 0, AESKey192, OutStrm);
    end;
    {  --  256 位密匙最大长度为 32 个字符 --  }
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      EncryptAESStreamECB(Stream, 0, AESKey256, OutStrm);
    end;
    Result := OutStrm;
  finally
    OutStrm.Free;
  end;
end;

{  --  流解密函数 默认按照 128 位密匙解密 --  }
function DecryptStream(Stream: TStream; Key: AnSiString;
  KeyBit: TKeyBit = kb128): TStream;
var
  Count, OutPos: Int64;
  OutStrm: TStream;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
begin
  OutStrm := TStream.Create;
  Stream.Position := 0;
  OutPos :=OutStrm.Position;
  Stream.ReadBuffer(Count, SizeOf(Count));
  try
    {  --  128 位密匙最大长度为 16 个字符 --  }
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      Move(PChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
      DecryptAESStreamECB(Stream, Stream.Size - Stream.Position,
        AESKey128, OutStrm);
    end;
    {  --  192 位密匙最大长度为 24 个字符 --  }
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      DecryptAESStreamECB(Stream, Stream.Size - Stream.Position,
        AESKey192, OutStrm);
    end;
    {  --  256 位密匙最大长度为 32 个字符 --  }
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      DecryptAESStreamECB(Stream, Stream.Size - Stream.Position,
        AESKey256, OutStrm);
    end;
    OutStrm.Size := OutPos + Count;
    OutStrm.Position := OutPos;
    Result := OutStrm;
  finally
    OutStrm.Free;
  end;
end;

{  --  文件加密函数 默认按照 128 位密匙解密 --  }
procedure EncryptFile(SourceFile, DestFile: AnSiString;
  Key: AnSiString; KeyBit: TKeyBit = kb128);
var
  SFS, DFS: TFileStream;
  Size: Int64;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
begin
  SFS := TFileStream.Create(SourceFile, fmOpenRead);
  try
    DFS := TFileStream.Create(DestFile, fmCreate);
    try
      Size := SFS.Size;
      DFS.WriteBuffer(Size, SizeOf(Size));
      {  --  128 位密匙最大长度为 16 个字符 --  }
      if KeyBit = kb128 then
      begin
        FillChar(AESKey128, SizeOf(AESKey128), 0 );
        Move(PChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
        EncryptAESStreamECB(SFS, 0, AESKey128, DFS);
      end;
      {  --  192 位密匙最大长度为 24 个字符 --  }
      if KeyBit = kb192 then
      begin
        FillChar(AESKey192, SizeOf(AESKey192), 0 );
        Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
        EncryptAESStreamECB(SFS, 0, AESKey192, DFS);
      end;
      {  --  256 位密匙最大长度为 32 个字符 --  }
      if KeyBit = kb256 then
      begin
        FillChar(AESKey256, SizeOf(AESKey256), 0 );
        Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
        EncryptAESStreamECB(SFS, 0, AESKey256, DFS);
      end;
    finally
      DFS.Free;
    end;
  finally
    SFS.Free;
  end;
end;

{  --  文件解密函数 默认按照 128 位密匙解密 --  }
procedure DecryptFile(SourceFile, DestFile: AnSiString;
  Key: AnSiString; KeyBit: TKeyBit = kb128);
var
  SFS, DFS: TFileStream;
  Size: Int64;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
begin
  SFS := TFileStream.Create(SourceFile, fmOpenRead);
  try
    SFS.ReadBuffer(Size, SizeOf(Size));
    DFS := TFileStream.Create(DestFile, fmCreate);
    try
      {  --  128 位密匙最大长度为 16 个字符 --  }
      if KeyBit = kb128 then
      begin
        FillChar(AESKey128, SizeOf(AESKey128), 0 );
        Move(PChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
        DecryptAESStreamECB(SFS, SFS.Size - SFS.Position, AESKey128, DFS);
      end;
      {  --  192 位密匙最大长度为 24 个字符 --  }
      if KeyBit = kb192 then
      begin
        FillChar(AESKey192, SizeOf(AESKey192), 0 );
        Move(PChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
        DecryptAESStreamECB(SFS, SFS.Size - SFS.Position, AESKey192, DFS);
      end;
      {  --  256 位密匙最大长度为 32 个字符 --  }
      if KeyBit = kb256 then
      begin
        FillChar(AESKey256, SizeOf(AESKey256), 0 );
        Move(PChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
        DecryptAESStreamECB(SFS, SFS.Size - SFS.Position, AESKey256, DFS);
      end;
      DFS.Size := Size;
    finally
      DFS.Free;
    end;
  finally
    SFS.Free;
  end;
end;

function EncryptBinaryCBC(Value: RawByteString; Key: RawByteString;
  KeyBit: TKeyBit = kb128): RawByteString;
var
  SS, DS: TMemoryStream;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  AESBuffer: TAESBuffer;
  valueLen, numBlocks, padLen, i: integer;
  p, q: PAnsiChar;
  padding: array[0..15] of AnsiChar;
begin
  if Length(Value) = 0 then exit;

  valueLen := Length(Value);
  numBlocks := valueLen div 16;
  padLen := 16 - (valueLen - numBlocks * 16);

  SS := TMemoryStream.Create;
  p := PAnsiChar(Value);
  q := @padding[0];
  SS.Write(p^, numBlocks * 16); inc(p, numBlocks * 16);
  Move(p^, q^, 16 - padLen); inc(q, 16 - padLen);
  for i := 0 to padLen - 1 do
  begin
    q^ := AnsiChar(Byte(padLen)); inc(q);
  end;
  SS.Write(padding, 16);
  SS.Position := 0;
  DS := TMemoryStream.Create;
  try
    FillChar(AESBuffer, SizeOf(AESBuffer), 0 );
    Move(PAnsiChar(IV_U8)^, AESBuffer, Min(SizeOf(AESBuffer), Length(IV_U8)));
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      Move(PAnsiChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
      EncryptAESStreamCBC(SS, 0, AESKey128, AESBuffer, DS);
    end;
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PAnsiChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      EncryptAESStreamCBC(SS, 0, AESKey192, AESBuffer, DS);
    end;
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PAnsiChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      EncryptAESStreamCBC(SS, 0, AESKey256, AESBuffer, DS);
    end;
	  SetString(result, PAnsiChar(DS.Memory), DS.Size);
  finally
    SS.Free;
    DS.Free;
  end;
end;

function DecryptBinaryCBC(Value: RawByteString; Key: RawByteString;
  KeyBit: TKeyBit = kb128): RawByteString;
var
  SS, DS: TMemoryStream;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  AESBuffer: TAESBuffer;
  padLen: integer;
  p: PAnsiChar;
begin
  Result := '';
  SS := TMemoryStream.Create;
  SS.Write(PAnsiChar(Value)^, Length(Value));
  SS.Position := 0;
  DS := TMemoryStream.Create;
  try
    FillChar(AESBuffer, SizeOf(AESBuffer), 0 );
    Move(PAnsiChar(IV_U8)^, AESBuffer, Min(SizeOf(AESBuffer), Length(IV_U8)));
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      Move(PAnsiChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey128, AESBuffer, DS);
    end;
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PAnsiChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey192, AESBuffer, DS);
    end;
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PAnsiChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      DecryptAESStreamCBC(SS, SS.Size - SS.Position, AESKey256, AESBuffer, DS);
    end;
    p := PAnsiChar(DS.Memory);
    padLen := Byte((p + DS.Size - 1)^);
	  SetString(result, PAnsiChar(DS.Memory), DS.Size - padLen);
  finally
    SS.Free;
    DS.Free;
  end;
end;

function EncryptBinaryECB(Value: RawByteString; Key: RawByteString;
  KeyBit: TKeyBit = kb128): RawByteString;
var
  SS, DS: TMemoryStream;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  valueLen, numBlocks, padLen, i: integer;
  p, q: PAnsiChar;
  padding: array[0..15] of AnsiChar;
begin
  if Length(Value) = 0 then exit;

  valueLen := Length(Value);
  numBlocks := valueLen div 16;
  padLen := 16 - (valueLen - numBlocks * 16);

  SS := TMemoryStream.Create;
  p := PAnsiChar(Value);
  q := @padding[0];
  SS.Write(p^, numBlocks * 16); inc(p, numBlocks * 16);
  Move(p^, q^, 16 - padLen); inc(q, 16 - padLen);
  for i := 0 to padLen - 1 do
  begin
    q^ := AnsiChar(Byte(padLen)); inc(q);
  end;
  SS.Write(padding, 16);
  SS.Position := 0;
  DS := TMemoryStream.Create;
  try
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      Move(PAnsiChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
      EncryptAESStreamECB(SS, 0, AESKey128, DS);
    end;
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PAnsiChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      EncryptAESStreamECB(SS, 0, AESKey192, DS);
    end;
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PAnsiChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      EncryptAESStreamECB(SS, 0, AESKey256, DS);
    end;
	  SetString(result, PAnsiChar(DS.Memory), DS.Size);
  finally
    SS.Free;
    DS.Free;
  end;
end;

function DecryptBinaryECB(Value: RawByteString; Key: RawByteString;
  KeyBit: TKeyBit = kb128): RawByteString;
var
  SS, DS: TMemoryStream;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  padLen: integer;
  p: PAnsiChar;
begin
  Result := '';
  SS := TMemoryStream.Create;
  SS.Write(PAnsiChar(Value)^, Length(Value));
  SS.Position := 0;
  DS := TMemoryStream.Create;
  try
    if KeyBit = kb128 then
    begin
      FillChar(AESKey128, SizeOf(AESKey128), 0 );
      Move(PAnsiChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
      DecryptAESStreamECB(SS, SS.Size - SS.Position, AESKey128, DS);
    end;
    if KeyBit = kb192 then
    begin
      FillChar(AESKey192, SizeOf(AESKey192), 0 );
      Move(PAnsiChar(Key)^, AESKey192, Min(SizeOf(AESKey192), Length(Key)));
      DecryptAESStreamECB(SS, SS.Size - SS.Position, AESKey192, DS);
    end;
    if KeyBit = kb256 then
    begin
      FillChar(AESKey256, SizeOf(AESKey256), 0 );
      Move(PAnsiChar(Key)^, AESKey256, Min(SizeOf(AESKey256), Length(Key)));
      DecryptAESStreamECB(SS, SS.Size - SS.Position, AESKey256, DS);
    end;
    p := PAnsiChar(DS.Memory);
    padLen := Byte((p + DS.Size - 1)^);
	  SetString(result, PAnsiChar(DS.Memory), DS.Size - padLen);
  finally
    SS.Free;
    DS.Free;
  end;
end;

end.
