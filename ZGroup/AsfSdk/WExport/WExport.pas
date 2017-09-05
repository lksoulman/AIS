unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Export Function
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    AsfSdk project export function.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  FastLogLevel;

  // Get factory funciton
  function GetWFactory: IInterface; stdcall;

  // Global Function Export
  // Set global LogLevel
  procedure FastSetLogLevel(ALevel: TLogLevel); stdcall;
  // HQ log output
  procedure FastHQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); stdcall;
  // System log output
  procedure FastSysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); stdcall;
  // Web log output
  procedure FastWebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); stdcall;
  // Indicator log output
  procedure FastIndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); stdcall;

  // AES Encrypt 128 key
  function AESEncrypt128(APlain: AnsiString): AnsiString; stdcall;
  // AES Decrypt 128 key
  function AESDecrypt128(ACiper: AnsiString): AnsiString; stdcall;
  // RSA Encrypt and Base64
  function RSAEncryptAndBase64(APlain: AnsiString): AnsiString; stdcall;
  // Base64 and RSA Decrypt
  function RSABase64AndDecrypt(ACiper: AnsiString): AnsiString; stdcall;

exports

  GetWFactory           name 'GetWFactory',
  FastSetLogLevel       name 'FastSetLogLevel',
  FastHQLog             name 'FastHQLog',
  FastSysLog            name 'FastSysLog',
  FastWebLog            name 'FastWebLog',
  FastIndicatorLog      name 'FastIndicatorLog',
  AESEncrypt128         name 'AESEncrypt128',
  AESDecrypt128         name 'AESDecrypt128',
  RSAEncryptAndBase64   name 'RSAEncryptAndBase64',
  RSABase64AndDecrypt   name 'RSABase64AndDecrypt';

implementation

uses
  CipherMgr,
  FastLogMgr,
  FactoryAsfSdkImpl;

  // Get factory interface funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;


  // Set global LogLevel
  procedure FastSetLogLevel(ALevel: TLogLevel);
  begin
    if G_FastLogMgr = nil then Exit;

    G_FastLogMgr.SetLogLevel(ALevel);
  end;

  // HQ log output
  procedure FastHQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  begin
    if G_FastLogMgr = nil then Exit;

    G_FastLogMgr.HQLog(ALevel, ALog, AUseTime);
  end;

  // System log output
  procedure FastSysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  begin
    if G_FastLogMgr = nil then Exit;

    G_FastLogMgr.SysLog(ALevel, ALog, AUseTime);
  end;

  // Web log output
  procedure FastWebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  begin
    if G_FastLogMgr = nil then Exit;

    G_FastLogMgr.WebLog(ALevel, ALog, AUseTime);
  end;

  // Indicator log output
  procedure FastIndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  begin
    if G_FastLogMgr = nil then Exit;

    G_FastLogMgr.IndicatorLog(ALevel, ALog, AUseTime);
  end;

  // AES Encrypt 128 key
  function AESEncrypt128(APlain: AnsiString): AnsiString;
  begin
    Result := '';
    if G_CipherMgr = nil then Exit;
    Result := G_CipherMgr.AESEncrypt128(APlain);
  end;

  // AES Decrypt 128 key
  function AESDecrypt128(ACiper: AnsiString): AnsiString;
  begin
    Result := '';
    if G_CipherMgr = nil then Exit;
    Result := G_CipherMgr.AESDecrypt128(ACiper);
  end;

  // RSA Encrypt and Base64
  function RSAEncryptAndBase64(APlain: AnsiString): AnsiString;
  begin
    Result := '';
    if G_CipherMgr = nil then Exit;
    Result := G_CipherMgr.RSAEncryptAndBase64(APlain);
  end;

  // Base64 and RSA Decrypt
  function RSABase64AndDecrypt(ACiper: AnsiString): AnsiString;
  begin
    Result := '';
    if G_CipherMgr = nil then Exit;
    Result := G_CipherMgr.RSABase64AndDecrypt(ACiper);
  end;

end.
