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
    // Cancel Call back
    function Cancel: Boolean; safecall;
    // Is Successed
    function IsSuccessed: Boolean; safecall;
    // Get Error Code
    function GetErrorCode: Integer; safecall;
    // Get Error Info
    function GetErrorInfo: WideString; safecall;
    // Get Response Stream
    function GetResponseStream: TStream; safecall;
  end;

  // Finance Data Arrive Notify Event
  TGFDataEvent = procedure (AGFData: IGFData) of object;

  // Re Login Event
  TReLoginEvent = procedure (AErrorCode: Integer; AErrorInfo: WideString) of object;

implementation

end.
