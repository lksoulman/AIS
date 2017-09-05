unit HqServerTypeInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-28
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  QuoteMngr_TLB;

type

  // �������������״̬
  THqServerStatus = ( ssInit,
                      ssConnecting,      // ��������
                      ssConnected,       // ������
                      ssDisConnected     // ���ӶϿ�
                      );

  // �������������
  THqServerTypeItem = packed record
    FName: string;
    FIsUsed: Boolean;
    FServers: string;
    FTypeEnum: ServerTypeEnum;
    FServerStatus: THqServerStatus;
    FLastHeartBeatTime: Cardinal;
  end;

  // ������������ͽӿ�
  PHqServerTypeItem = ^THqServerTypeItem;

  // ���������������Ϣ�ӿ�
  IHqServerTypeInfo = Interface(IInterface)
    ['{7F5600EE-0ADA-4995-A364-248ADE6940A3}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��������
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // ����
    procedure Lock; safecall;
    // ����
    procedure UnLock; safecall;
    // ��ȡ������������͸���
    function GetHqServerTypeItemCount: Integer; safecall;
    // ��ȡ�������������ָ��
    function GetHqServerTypeItem(AIndex: Integer): PHqServerTypeItem; safecall;
    // ��ȡ�������������ָ��ͨ��ö��
    function GetHqServerTypeNameByEnum(AEnum: ServerTypeEnum): WideString; safecall;
    // ��ȡ�������������ָ��ͨ��ö��
    function GetHqServerTypeItemByEnum(AEnum: ServerTypeEnum): PHqServerTypeItem; safecall;
  end;


implementation

end.
