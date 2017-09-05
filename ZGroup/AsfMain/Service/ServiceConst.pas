unit ServiceConst;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

const

  ECODE_SUCCESS                       = 0;  // �ɹ�

  ECODE_BIND_BASE_NEED                = 11; // ��Ҫ��
  ECODE_BIND_BASE_NEED_REPEAT         = 12; // ��Ҫ���°�
  ECODE_BIND_BASE_RETURN_NIL          = 13; // �󶨷���ӿڷ�������Ϊ NIL
  ECODE_BIND_BASE_RETURN_FIELD        = 14; // �󶨷���ӿڷ��������ֶ�������
  ECODE_BIND_BASE_USER_EXIST          = 15; // �˺��ѱ���
  ECODE_BIND_BASE_USER_NOEXIST        = 16; // ���û�������

  ECODE_PASSWORD_ERROR                = 21; // �������
  ECODE_PASSWORD_RESET                = 22; // �����Ѿ������ã���Ҫ���޸�
  ECODE_PASSWORD_EXPIRE               = 23; // �����Ѿ����ڣ���Ҫ�޸ı��޸�
  ECODE_PASSWORD_NDAY_EXPIRE          = 24; // ���뻹��N����ڣ���Ҫ��ʾ�޸�����

  ECODE_SERVICE_BASE_NETWORK_EXCEPT   = 31; // GF �������������쳣
  ECODE_SERVICE_ASSET_NETWORK_EXCEPT  = 32; // GF �ʲ����������쳣
  ECODE_SERVICE_BASE_NIL              = 33; // GF ��������ӿ��� NIL
  ECODE_SERVICE_ASSET_NIL             = 34; // GF �ʲ�����ӿ��� NIL
  ECODE_SERVICE_BASE_EXEC_EXCEPT      = 35; // GF ��������ӿ�ִ���쳣
  ECODE_SERVICE_ASSET_EXEC_EXCEPT     = 36; // GF �ʲ�����ӿ�ִ���쳣

  ECODE_SERVICE_ASSET_NO_INIT         = 36; // �ʲ�����δ��ʼ��

  ECODE_OTHER                         = 50; // ��������


implementation

end.
