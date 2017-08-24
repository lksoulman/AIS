unit Config;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-24
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CfgCache,
  UserInfo,
  DllComLib,
  ProxyInfo,
  LoginInfo,
  ServerInfo,
  SyscfgInfo,
  UpdateInfo,
  CompanyInfo;

type

  IConfig = Interface(IInterface)
    ['{8E49C2C0-9AAC-4855-B3A4-9073AC5B1427}']
    // 初始化系统的目录
    procedure ForceInitSysDirectories;
    // 初始化用户的目录
    procedure ForceInitUserDirectories;
    // 获取微软工具类
    function GetDllComLib: TDllComLib;
    // 获取配置缓存接口
    function GetSysCfgCache: ICfgCache;
    // 获取用户配置缓存接口
    function GetUserCfgCache: ICfgCache;

    { Directory }

    // 获取应用程序目录
    function GetAppPath: WideString;
    // 获取应用程序执行目录
    function GetBinPath: WideString;
    // 获取应用程序系统级配置目录
    function GetCfgPath: WideString;
    // 获取应用程序日志目录
    function GetLogPath: WideString;
    // 获取应用程序皮肤目录
    function GetSkinPath: WideString;
    // 获取用户私有目录
    function GetUserPath: WideString;
    // 获取 Users 目录
    function GetUsersPath: WideString;
    // 获取应用程序系统级缓存数据目录
    function GetCachePath: WideString;
    // 获取应用程序更新的更新目录
    function GetUpdatePath: WideString;
    // 获取用户私有配置目录
    function GetUserCfgPath: WideString;
    // 获取用户私有的缓存目录
    function GetUserCachePath: WideString;

    { Info }

    // 获取用户信息
    function GetUserInfo: IUserInfo;
    // 获取代理信息
    function GetProxyInfo: IProxyInfo;
    // 获取登录信息
    function GetLoginInfo: ILoginInfo;
    // 获取系统配置信息
    function GetSyscfgInfo: ISyscfgInfo;
    // 获取更新信息
    function GetUpdateInfo: IUpdateInfo;
    // 获取公司信息
    function GetCompanyInfo: ICompanyInfo;

    { web}

    // FOF服务器信息
    function GetFOFServerInfo: IServerInfo;
    // 个股F10服务器信息
    function GetF10ServerInfo: IServerInfo;
    // 资讯服务器信息
    function GetNewsServerInfo: IServerInfo;
    // 中科服务器信息
    function GetZhongKeServerInfo: IServerInfo;
    // 资讯文件服务器信息
    function GetNewsFileServerInfo: IServerInfo;
    // 资产服务器信息
    function GetAssetWebServerInfo: IServerInfo;
    // 模拟组合服务器信息
    function GetSimulationServerInfo: IServerInfo;

    { HQ }

    // DDE行情服务器信息
    function GetDDEServerInfo: IServerInfo;
    // 美股行情
    function GetUSAServerInfo: IServerInfo;
    // 期货行情服务器信息
    function GetFutuesServerInfo: IServerInfo;
    // 港股实时服务器信息
    function GetHKRealServerInfo: IServerInfo;
    // LevelI行情服务器信息
    function GetLevelIServerInfo: IServerInfo;
    // LevelI行情服务器信息
    function GetLevelIIServerInfo: IServerInfo;
    // 港股延时服务器信息
    function GetHKDelayServerInfo: IServerInfo;

    { Indicators }

    // 公网指标服务器信息
    function GetBaseIndicatorServerInfo: IServerInfo;
    // 资产指标服务器信息
    function GetAssetIndicatorServerInfo: IServerInfo;

    { Update}

    // 升级终端服务器
    function GetUpdateServerInfo: IServerInfo;

    { hundsun}

    // 用户行为服务器信息
    function GetActionAnalysisServerInfo: IServerInfo;
  end;

implementation

end.
