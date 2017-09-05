unit AsfSdkExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Export Function
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    AsfCache project export function, the export function can be
//               called publicly.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  FastLogLevel;

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

implementation

  procedure FastSetLogLevel; external 'AsfSdk.dll' name 'FastSetLogLevel';
  procedure FastHQLog; external 'AsfSdk.dll' name 'FastHQLog';
  procedure FastSysLog; external 'AsfSdk.dll' name 'FastSysLog';
  procedure FastWebLog; external 'AsfSdk.dll' name 'FastWebLog';
  procedure FastIndicatorLog; external 'AsfSdk.dll' name 'FastIndicatorLog';
  function AESEncrypt128; external 'AsfSdk.dll' name 'AESEncrypt128';
  function AESDecrypt128; external 'AsfSdk.dll' name 'AESDecrypt128';
  function RSAEncryptAndBase64; external 'AsfSdk.dll' name 'RSAEncryptAndBase64';
  function RSABase64AndDecrypt; external 'AsfSdk.dll' name 'RSABase64AndDecrypt';
  

end.
