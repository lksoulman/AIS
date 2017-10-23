unit GFData;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Finance Data Interface
// Author£º      lksoulman
// Date£º        2017-9-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Finance Data Interface
  IGFData = Interface(IInterface)
    ['{63FB696D-2378-4907-86BC-4D1E9593E2D0}']
    // Get Key
    function GetKey: Int64; safecall;
    // Cancel
    function Cancel: Boolean; safecall;
    // Get Error Code
    function GetErrorCode: Integer; safecall;
    // Get Error Info
    function GetErrorInfo: WideString; safecall;
    // Get Data Stream
    function GetDataStream: TStream; safecall;
    // Get Request Size
    function GetRequestSize: Cardinal; safecall;
    // Get Request Compress Size
    function GetRequestCompressSize: Cardinal; safecall;
    // Get Compress Ratio
    function GetRequestCompressRatio: Double; safecall;
    // Get Response Size
    function GetResponseSize: Cardinal; safecall;
    // Get Response Compress Size
    function GetResponseCompressSize: Cardinal; safecall;
    // Get Compress Ratio
    function GetResponseCompressRatio: Double; safecall;
    // Get Queue Wait Use Time
    function GetQueueWaitUseTime: Cardinal; safecall;
    // Get Execute Post Use Time
    function GetExecutePostUseTime: Cardinal; safecall;
    // Get Request Compress Use Time
    function GetRequestCompressUseTime: Cardinal; safecall;
    // Get Response Uncompress Use Time
    function GetResponseUncompressUseTime: Cardinal; safecall;
  end;

  // Finance Data Arrive Notify Event
  TGFDataEvent = procedure (AGFData: IGFData) of object;

  // Re Login Event
  TReLoginEvent = procedure (AErrorCode: Integer; AErrorInfo: WideString) of object;

implementation

end.
