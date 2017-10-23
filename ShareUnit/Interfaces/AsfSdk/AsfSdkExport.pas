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
  ElAES,
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

//  // AES Encrypt String 128 key
//  function AESEncryptString128(APlain: AnsiString): AnsiString; stdcall;
//  // AES Decrypt 128 key
//  function AESDecryptString128(ACiper: AnsiString): AnsiString; stdcall;
//  // AES Encrypt Stream 128 key
//  function AESEncryptStream128(APlainStream, ACiperStream: TStream; AKey: TAESKey128): Boolean; stdcall;
//  // AES Decrypt Stream 128 Key
//  function AESDecryptStream128(ACiperStream, APlainStream: TStream; AKey: TAESKey128): Boolean; stdcall;
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
//  function AESEncryptString128; external 'AsfSdk.dll' name 'AESEncryptString128';
//  function AESDecryptString128; external 'AsfSdk.dll' name 'AESDecryptString128';
//  function AESEncryptStream128; external 'AsfSdk.dll' name 'AESEncryptStream128';
//  function AESDecryptStream128; external 'AsfSdk.dll' name 'AESDecryptStream128';
  function RSAEncryptAndBase64; external 'AsfSdk.dll' name 'RSAEncryptAndBase64';
  function RSABase64AndDecrypt; external 'AsfSdk.dll' name 'RSABase64AndDecrypt';
  

end.
