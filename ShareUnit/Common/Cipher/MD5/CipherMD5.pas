unit CipherMD5;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-6
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IdHash,
  IdGlobal,
  IdHashMessageDigest;

type

  TCipherMD5 = class
  private
  protected
  public
    // 构造方法
    constructor Create;
    // 析构方法
    destructor Destroy; override;
    // 获取文件的 MD5
    function GetFileMD5(AFile: string): string;
    // 获取流的 MD5
    function GetStreamMD5(AStream: TStream): string;
  end;

implementation

{ TCipherMD5 }

constructor TCipherMD5.Create;
begin
  inherited;
end;

destructor TCipherMD5.Destroy;
begin

  inherited;
end;

function TCipherMD5.GetFileMD5(AFile: string): string;
var
  LStream: TFileStream;
begin
  Result := '';
  if not FileExists(AFile) then Exit;
  LStream := TFileStream.Create(AFile, fmopenread or fmshareExclusive);
  try
    Result := GetStreamMD5(LStream);
  finally
    LStream.Free;
  end;
end;

function TCipherMD5.GetStreamMD5(AStream: TStream): string;
var
  LMD5Encode: TIdHashMessageDigest5;
begin
  Result := '';
  if AStream = nil then Exit;
  LMD5Encode:= TIdHashMessageDigest5.Create;
  try
    Result := LMD5Encode.HashStreamAsHex(AStream);
    Result := UpperCase(Result);
  finally
    LMD5Encode.Free;
  end;
end;

end.
