unit MsgReceiver;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message Receiver interface
// Author£º      lksoulman
// Date£º        2017-7-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgType,
  Windows,
  Classes,
  SysUtils;

type

  // Message Receiver interface
  IMsgReceiver = Interface
    ['{39E66A1F-88CB-47D2-B98E-F2DB16A5C7B3}']
    // Lock
    procedure Lock; safecall;
    // Un Lock
    procedure UnLock; safecall;
    // Get Consumer Id
    function GetId: Integer; safecall;
    // Get Active State
    function GetActive: Boolean; safecall;
    // Set Active State
    procedure SetActive(Active: Boolean); safecall;
    // Invoke Notification
    procedure InvokeNotify(AMsgEx: TMsgEx); safecall;
    // Clear Pending Message
    function ClearPendMsg: Boolean; safecall;
    // Get Pending Message Count (No Safe, Lock)
    function GetPendMsgCount: Integer; safecall;
    // Get Pending Message Type (No Safe, Lock)
    function GetPendMsg(AIndex: Integer): TMsgEx; safecall;
    // Get Pending Message Type Count (No Safe, Lock)
    function GetPendMsgTypeCount: Integer; safecall;
    // Get Pending Message Type (No Safe, Lock)
    function GetPendMsgType(AIndex: Integer): TMsgType; safecall;
    // Is Exist Message Type
    function IsExistsMsgType(AMsgType: TMsgType): Boolean; safecall;
  end;

implementation

end.
