unit MsgReceiver;

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
  MsgType;

type

  // ��Ϣ�����߽ӿ�
  IMsgReceiver = Interface
    ['{A36297F2-1A0B-4FAA-94E1-AF381B196C62}']
    // ��Ϣ�����ߵ�״̬
    function Active: Wordbool; safecall;
    // ��ȡ�����ߵ�ID
    function GetReceiverID: Integer; safecall;
    // ������Ϣ�����ߵ�״̬
    procedure SetActive(Active: Wordbool); safecall;
    // ������Ϣ����
    procedure Receive(AProdurerID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
  end;

implementation

end.
