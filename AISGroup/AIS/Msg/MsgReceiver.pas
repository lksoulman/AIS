unit MsgReceiver;

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
  MsgType;

type

  // 消息接收者接口
  IMsgReceiver = Interface
    ['{A36297F2-1A0B-4FAA-94E1-AF381B196C62}']
    // 消息接收者的状态
    function Active: Wordbool; safecall;
    // 获取接收者的ID
    function GetReceiverID: Integer; safecall;
    // 设置消息接收者的状态
    procedure SetActive(Active: Wordbool); safecall;
    // 接收消息方法
    procedure Receive(AProdurerID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
  end;

implementation

end.
