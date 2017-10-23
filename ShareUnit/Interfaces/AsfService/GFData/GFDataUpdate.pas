unit GFDataUpdate;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Finance Data Update Interface
// Author£º      lksoulman
// Date£º        2017-9-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ExecutorTask;

type

  // Finance Data Update Interface
  IGFDataUpdate = Interface(IInterface)
    ['{503963C3-63F2-4307-9126-903E2F1D6285}']
    // Get Is Canceled
    function GetIsCancel: Boolean; safecall;
    // Get Error Code
    function GetErrorCode: Integer; safecall;
    // Set Key
    function SetKey(AKey: Int64): Boolean; safecall;
    // Set Cancel
    function SetCancel(ACancel: Boolean = True): Boolean; safecall;
    // Set ErrorCode
    function SetErrorCode(AErrorCode: Integer): Boolean; safecall;
    // Set Error Info
    function SetErrorInfo(AErrorInfo: WideString): Boolean; safecall;
    // Set Response Stream
    function SetResponseStream(AResponseStream: TStream): Boolean; safecall;
    // Set Request Size
    function SetRequestSize(ASize: Cardinal): Boolean; safecall;
    // Set Request Compress Size
    function SetRequestCompressSize(ASize: Cardinal): Boolean; safecall;
    // Set Response Size
    function SetResponseSize(ASize: Cardinal): Boolean; safecall;
    // Set Response Compress Size
    function SetResponseCompressSize(ASize: Cardinal): Boolean; safecall;
    // Set Queue Wait Use Time
    function SetQueueWaitUseTime(AUseTime: Cardinal): Boolean; safecall;
    // Set Execute Post Use Time
    function SetExecutePostUseTime(AUseTime: Cardinal): Boolean; safecall;
    // Set Request Compress Use Time
    function SetRequestCompressUseTime(AUseTime: Cardinal): Boolean; safecall;
    // Set Response Uncompress Use Time
    function SetResponseUncompressUseTime(AUseTime: Cardinal): Boolean; safecall;
  end;

implementation

end.
