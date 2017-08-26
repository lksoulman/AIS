unit SyscfgInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-21
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  FastLogLevel,
  LanguageType;

type

  ISyscfgInfo = Interface(IInterface)
    ['{694C57FE-D4B2-416B-B33C-16CD955B4113}']
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // 保存数据
    procedure SaveCache; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 设置字体比例
    procedure SetFontRatio(AFontRatio: WideString); safecall;
    // 获取字体比例
    function GetFontRatio: WideString; safecall;
    // 设置皮肤样式
    procedure SetSkinStyle(ASkinStyle: WideString); safecall;
    // 获取皮肤样式
    function GetSkinStyle: WideString; safecall;
    // 设置日志级别
    procedure SetLogLevel(ALogLevel: TLogLevel); safecall;
    // 获取日志级别
    function GetLogLevel: TLogLevel; safecall;
    // 设置语言类型
    procedure SetLanguageType(ALanguageType: TLanguageType); safecall;
    // 获取语言类型
    function GetLanguageType: TLanguageType; safecall;
  end;

implementation

end.
