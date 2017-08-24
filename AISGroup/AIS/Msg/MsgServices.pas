unit MsgServices;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-29
// Comments��
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

  // ��Ϣ����ӿ�
  IMsgServices = Interface(IInterface)
    ['{7FE2D77E-1015-4591-815E-960B211D9272}']
    // ����һ����Ϣ������
    function CreateMsgReceiver(ACallBack: TMsgCallBackFunc): IMsgReceiver; safecall;
    // ������Ϣ
    procedure Producer(AProduceID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
    // ������Ϣ
    procedure Subcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver); safecall;
    // ȡ������
    procedure DisSubcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver); safecall;
  end;

implementation

end.
