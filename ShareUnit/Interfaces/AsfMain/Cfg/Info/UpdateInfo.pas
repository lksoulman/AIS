unit UpdateInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  IUpdateInfo = Interface(IInterface)
    ['{165324E7-CDE1-410E-97FD-00B2B24220B5}']
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
  end;

implementation

end.
