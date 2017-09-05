unit MsgReceiverPend;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Message Receiver Pending Interface
// Author��      lksoulman
// Date��        2017-7-29
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  Windows,
  Classes,
  SysUtils;

type

  // Message Receiver Pending Interface
  IMsgReceiverPend = Interface(IInterface)
    ['{DEB9CB42-BD36-4B85-AB25-31E4872B374F}']
    // Add Pending Message Extend
    function AddPendMsg(AMsgEx: TMsgEx): Boolean; safecall;
  end;

implementation

end.
