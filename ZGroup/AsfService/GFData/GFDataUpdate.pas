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
    // Set Cancel
    function SetCancel: Boolean; safecall;
    // Is Canceled
    function IsCanceled: Boolean; safecall;
    // Set Success
    function SetSuccess: Boolean; safecall;
    // Is Successed
    function IsSuccessed: Boolean; safecall;
    // Set Response
    function SetResponse(AStream: TStream): Boolean; safecall;
    // Set ErrorCode
    function SetErrorCode(AErrorCode: Integer): Boolean; safecall;
    // Set Error Info
    function SetErrorInfo(AErrorInfo: WideString): Boolean; safecall;
  end;

implementation

end.
