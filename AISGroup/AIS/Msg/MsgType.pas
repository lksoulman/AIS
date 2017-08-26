unit MsgType;

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
  SysUtils;

type

  // ��Ϣ����
  TMsgType = (mtLoadPlugs,              // ���������Ϣ
              mtNDayModifyPassword,     // ϵͳ��ʾ��Ϣ
              mtSecuBaseDataUpdate      // ֤ȯ�������ݷ����ı䣬֪ͨ�ڴ����
              );

  TMsgTypeDynArray = Array of TMsgType;

  // ��Ϣ�ص���������
  TMsgCallBackFunc = procedure (AMsgType: TMsgType; AMsgInfo: string; var ALogTag: string) of Object;


implementation

end.
