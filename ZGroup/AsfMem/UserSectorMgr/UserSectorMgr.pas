unit UserSectorMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description： User Sector Manager Interface
// Author：      lksoulman
// Date：        2017-8-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils;

type

  // User Sector Manager Interface
  IUserSectorMgr = Interface(IInterface)
    ['{339180B9-E14F-4254-B7F1-FAE221385F3D}']
    // 读加锁
    procedure BeginRead; safecall;
    // 读解锁
    procedure EndRead; safecall;
    // 写加锁
    procedure BeginWrite; safecall;
    // 写解锁
    procedure EndWrite; safecall;
    // 获取根结点板块
    function GetRootSector: ISector; safecall;
  end;

implementation

end.
