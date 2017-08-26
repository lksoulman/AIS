unit PermissionMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-17
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  IPermissionMgr = Interface(IInterface)
    ['{31A08F64-4B97-4F26-A9E0-2241D985DFCE}']
    // �ǲ����и۹�ʵʱȨ��
    function IsHasHKReal: Boolean; safecall;
    // �ǲ����� LevelII Ȩ��
    function IsHasLevelII: Boolean; safecall;
    // ��ȡ LevelII �û���
    function GetLevelIIUserName: WideString; safecall;
    // ��ȡ LevelII �û�����
    function GetLevelIIPassword: WideString; safecall;
    // �ж��ǲ�����Ȩ��
    function IsHasPermission(APermNo: Integer): Boolean; safecall;
  end;

implementation

end.
