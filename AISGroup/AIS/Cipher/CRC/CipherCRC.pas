unit CipherCRC;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-4
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IdHashCRC,
  IdHashMessageDigest;

type

  TCipherCRC = class
  private
  protected
  public
    // 构造方法
    constructor Create;
    // 析构方法
    destructor Destroy; override;
    // 获取文件的 CRC
    function GetFileCRC(AFile: string): string;
    // 获取字符串的 CRC
    function GetStringCRC(AValue: string): string;
    // 获取流的 CRC
    function GetStreamCRC(AStream: TStream): string;
  end;


implementation

{ TCipherCRC }

constructor TCipherCRC.Create;
begin
  inherited;

end;

destructor TCipherCRC.Destroy;
begin

  inherited;
end;

function TCipherCRC.GetFileCRC(AFile: string): string;
var
  LStream: TFileStream;
begin
  Result := '';
  if not FileExists(AFile) then Exit;
  LStream := TFileStream.Create(AFile, fmopenread or fmshareExclusive);
  try
    Result := GetStreamCRC(LStream);
  finally
    LStream.Free;
  end;
end;

function TCipherCRC.GetStringCRC(AValue: string): string;
var
  LIdHashCRC32: TIdHashCRC32;
begin
  Result := '';
  if AValue = '' then Exit;
  LIdHashCRC32 := TIdHashCRC32.Create;
  try
    Result := LIdHashCRC32.HashStringAsHex(AValue);
  finally
    LIdHashCRC32.Free;
  end;
end;

function TCipherCRC.GetStreamCRC(AStream: TStream): string;
var
  LIdHashCRC32: TIdHashCRC32;
begin
  Result := '';
  if AStream = nil then Exit;
  LIdHashCRC32 := TIdHashCRC32.Create;
  try
    Result := LIdHashCRC32.HashStreamAsHex(AStream);
  finally
    LIdHashCRC32.Free;
  end;
end;

end.
