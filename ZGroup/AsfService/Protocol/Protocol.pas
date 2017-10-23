unit Protocol;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Protocol
// Author：      lksoulman
// Date：        2017-9-8
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

const

  // 协议标志
  PROTOCOL_SIGN          = $01;

  // 协议版本
  PROTOCOL_VERSION       = $01;             // 协议版本

  // 校验标志
  PROTOCOL_CRCSUM        = $00;             // 不做校验

  // 协议加密
  PROTOCOL_ENCRYPT_NO    = $00;             // 协议不加密
  PROTOCOL_ENCRYPT_AES   = $01;             // 协议用 AES 加密

  // 协议压缩
  PROTOCOL_COMPRESS_NO   = $00;             // 协议不压缩
  PROTOCOL_COMPRESS_ZIP  = $01;             // 协议用 ZIP 压缩
  PROTOCOL_COMPRESS_GZIP = $02;             // 协议用 GZIP 压缩

  // 错误码
  ErrorCode_OK           = 0;               // 无错误
  ErrorCode_NoService    = 1;               // 无服务

  ErrorMsg_Ok            = '';              //
  ErrorMsg_NoService     = '没有此服务';    //

type

  // Request Header Data
  TReqHead = packed record
    FSig: Int16;                      // Sign
    FVers: Byte;                      // Version
    FCrcSum: Int32;                   // Crc Check Sum
    FDataLen: Int32;                  // Data Len
    FEncrypt: Byte;                   // Encrypt Flag
    FCompress: Byte;                  // Compress Flag
    FDecryptLen: Int32;               // Decrypt Data Len
    FOriginDataLen: Int32;            // Origin Data Len
    FType: Byte;                      // Type
    FKey: Int64;                      // Extend Key
    FExtKey: Int64;                   // Error Code
  end;

  // Request Header Data Pointer
  PReqHead = ^TReqHead;

  // Response Header Data
  TRepHead = packed record
    FSig: Int16;                      // Sign
    FVers: Byte;                      // Version
    FCrcSum: Int32;                   // Crc Check Sum
    FDataLen: Int32;                  // Data Len
    FEncrypt: Byte;                   // Encrypt Flag
    FCompress: Byte;                  // Compress Flag
    FDecryptLen: Int32;               // Decrypt Data Len
    FOriginDataLen: Int32;            // Origin Data Len
    FType: Byte;                      // Type
    FKey: Int64;                      // Key
    FExtKey: Int64;                   // Extend Key
    FErrorCode: Int16;                // Error Code
  end;

  // Response Header Data Pointer
  PRepHead = ^TRepHead;

implementation

end.
