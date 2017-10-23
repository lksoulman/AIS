unit Cfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Config Interface
// Author£º      lksoulman
// Date£º        2017-7-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  WebCfg,
  SysCfg,
  Windows,
  Classes,
  SysUtils,
  CacheCfg,
  ServerCfg;

type

  // Config Interface
  ICfg = Interface(IInterface)
    ['{8E49C2C0-9AAC-4855-B3A4-9073AC5B1427}']
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Force User Dirs
    function InitUserDirs: Boolean;
    // Get System Cfg
    function GetSysCfg: ISysCfg;
    // Get Web Cfg
    function GetWebCfg: IWebCfg;
    // Get Server Cfg
    function GetServerCfg: IServerCfg;
    // Get Sys Cache Cfg
    function GetSysCacheCfg: ICacheCfg;
    // Get User Cache Cfg
    function GetUserCacheCfg: ICacheCfg;
    // Get App Path
    function GetAppPath: WideString;
    // Get Bin Path
    function GetBinPath: WideString;
    // Get Cfg Path
    function GetCfgPath: WideString;
    // Get Log Path
    function GetLogPath: WideString;
    // Get Skin Path
    function GetSkinPath: WideString;
    // Get User Path
    function GetUserPath: WideString;
    // Get Users Path
    function GetUsersPath: WideString;
    // Get User Cfg Path
    function GetUserCfgPath: WideString;
    // Get Cache Path
    function GetCachePath: WideString;
    // Get HQ Cache Path
    function GetHQCachePath: WideString;
    // Get Base Cache Path
    function GetBaseCachePath: WideString;
    // Get User Cache Path
    function GetUserCachePath: WideString;
    // Get System Update Path
    function GetSysUpdatePath: WideString;
  end;

implementation

end.
