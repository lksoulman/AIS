unit PermissionMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-17
// Comments：
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
    // 是不是有港股实时权限
    function IsHasHKReal: Boolean; safecall;
    // 是不是有 LevelII 权限
    function IsHasLevelII: Boolean; safecall;
    // 获取 LevelII 用户名
    function GetLevelIIUserName: WideString; safecall;
    // 获取 LevelII 用户密码
    function GetLevelIIPassword: WideString; safecall;
    // 判断是不是有权限
    function IsHasPermission(APermNo: Integer): Boolean; safecall;
  end;

implementation

end.
