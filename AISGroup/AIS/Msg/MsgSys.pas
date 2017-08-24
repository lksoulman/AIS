unit MsgSys;

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
  AppContext;

type

  IMsgSys = Interface(IInterface)
    ['{85D1204E-01AE-474D-B3D1-1D34781434BF}']
    // ��ʼ��
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŽӿ���Դ
    procedure UnInitialize; safecall;
    // ��Ϣ����
    function MsgType: TMsgType; safecall;
    // ��Ϣ��Ϣ
    function MsgInfo: WideString; safecall;
    // ��Ϣ������ ID
    function ProducerID: Integer; safecall;
    // ��Ϣ����ʱ��
    function ProduceDate: TDateTime; safecall;
    // ִ�в�������
    function OperateName: WideString; safecall;
    // ִ�в���ʵ�ַ���
    function ExecuteOperate: WordBool; safecall;
  end;

implementation

end.
