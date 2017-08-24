unit Sector;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // 板块接口
  ISector = Interface(IInterface)
    ['{1CD531FC-3B3F-49BC-B5D3-CD0AE1F59F71}']
    // 获取板块 ID
    function GetSectorID: WideString; safecall;
    // 获取板块的名称
    function GetSectorName: WideString; safecall;
    // 获取子板块成分用字符串返回
    function GetChildSectors: WideString; safecall;
    // 获取是不是存在子板块
    function GetChildSectorExist: boolean; safecall;
    // 获取子板块个数
    function GetChildSectorCount: Integer; safecall;
    // 获取子板块接口通过下表
    function GetChildSector(AIndex: Integer): ISector; safecall;
    // 获取子板块是不是存在
    function GetExistChildSectorName(AName: WideString): boolean; safecall;
    // 增加子板块
    function AddChildSectorByName(AName: WideString): ISector; safecall;
    // 设置板块 ID
    procedure SetSectorID(AID: WideString); safecall;
    // 设置板块名称
    procedure SetSectorName(AName: WideString); safecall;
    // 删除子板块
    procedure DelChildSector(ASector: ISector); safecall;
    // 删除子板块通过板块名称
    procedure DelChildSectorByName(AName: WideString); safecall;
  end;

implementation

end.
