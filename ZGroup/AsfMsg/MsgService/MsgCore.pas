unit MsgCore;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Message Core Inteface
// Author��      lksoulman
// Date��        2017-7-29
// Comments��    Message service Inteface
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgType,
  MsgFunc,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  MsgConsumer;

type

  // Message Core Inteface
  IMsgCore = Interface(IInterface)
    ['{7FE2D77E-1015-4591-815E-960B211D9272}']
    // New Message Consumer Interface
    function NewConsumer(ACallBack: TMsgFuncCallBack): IMsgConsumer; safecall;
    // Subcribe Message Type
    procedure Subcribe(AMsgType: TMsgType; AConsumer: IMsgConsumer); safecall;
    // Cancel Subcribe Message Type
    procedure UnSubcribe(AMsgType: TMsgType; AConsumer: IMsgConsumer); safecall;
    // Produce Message Type
    procedure ProduceMsg(AProID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
  end;

implementation

end.
