unit CipherMD5;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Cipher MD5
// Author£º      lksoulman
// Date£º        2017-8-6
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IdHash,
  IdGlobal,
  CommonRefCounter,
  IdHashMessageDigest;

type

  TCipherMD5 = class(TAutoObject)
  private
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Get File MD5
    function GetFileMD5(AFile: string): string;
    // Get String MD5
    function GetStringMD5(AString: string): string;
    // Get Stream MD5
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

function TCipherMD5.GetStringMD5(AString: string): string;
var
  LMD5Encode: TIdHashMessageDigest5;
begin
  Result := '';
  if AString = '' then Exit;

  LMD5Encode:= TIdHashMessageDigest5.Create;
  try
    Result := LMD5Encode.HashStringAsHex(AString);
    Result := UpperCase(Result);
  finally
    LMD5Encode.Free;
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
