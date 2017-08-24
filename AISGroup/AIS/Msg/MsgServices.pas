unit MsgServices;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-29
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgType,
  AppContext,
  MsgReceiver;

type

  // 消息服务接口
  IMsgServices = Interface(IInterface)
    ['{7FE2D77E-1015-4591-815E-960B211D9272}']
    // 创建一个消息接收者
    function CreateMsgReceiver(ACallBack: TMsgCallBackFunc): IMsgReceiver; safecall;
    // 生产消息
    procedure Producer(AProduceID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
    // 订阅消息
    procedure Subcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver); safecall;
    // 取消订阅
    procedure DisSubcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver); safecall;
  end;

implementation

end.
