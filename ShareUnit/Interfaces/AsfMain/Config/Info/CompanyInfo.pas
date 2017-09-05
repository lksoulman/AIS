unit CompanyInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-20
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

  ICompanyInfo = Interface(IInterface)
    ['{8266E637-A200-4CD9-A9B6-7FCD35B79318}']
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
