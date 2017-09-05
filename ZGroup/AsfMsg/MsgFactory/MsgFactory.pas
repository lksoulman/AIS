unit MsgFactory;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Message Factory Interface
// Author��      lksoulman
// Date��        2017-7-29
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgType,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonLock,
  CommonRefCounter;

type

  // Message Factory Interface
  IMsgFactory = Interface(IInterface)
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; safecall;
    // Create Message Extend
    function CreateMsg(AProID: Integer; AMsgType: TMsgType; AMsgInfo: string): TMsgEx; safecall;
    // DeAllocate Message Extend
    procedure DeAllocate(AMsgEx: TMsgEx); safecall;
  end;

implementation


end.
