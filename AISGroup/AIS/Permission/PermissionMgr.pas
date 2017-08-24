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
    // 判断是不是有权限
    function IsHasPermission(APermNo: Integer): Boolean; safecall;
  end;

implementation

end.
