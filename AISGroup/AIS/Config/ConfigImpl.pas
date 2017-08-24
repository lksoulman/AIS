unit ConfigImpl;

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
  IniFiles,
  Config,
  CfgCache,
  UserInfo,
  DllComLib,
  ProxyInfo,
  LoginInfo,
  SyncAsync,
  AppContext,
  ServerInfo,
  SyscfgInfo,
  UpdateInfo,
  CompanyInfo;

type

  // 终端配置管理
  TConfigImpl = class(TInterfacedObject, ISyncAsync, IConfig)
  private
    // 应用程序目录
    FAppPath: string;
    // 基础配置文件
    FBaseFile: string;
    // 服务器配置文件
    FServerListFile: string;
    // 动态库或者Com加载类
    FDllComLib: TDllComLib;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 系统的配置缓冲
    FSysCfgCache: ICfgCache;
    // 用户的配置缓存
    FUserCfgCache: ICfgCache;

    { Gildata }

    // 用户信息
    FUserInfo: IUserInfo;
    // 代理信息
    FProxyInfo: IProxyInfo;
    // 登录信息
    FLoginInfo: ILoginInfo;
    // 系统级别配置信息
    FSyscfgInfo: ISyscfgInfo;
    // 更新信息
    FUpdateInfo: IUpdateInfo;
    // 公司配置
    FCompanyInfo: ICompanyInfo;

    { web }

    // FOF服务器信息
    FFOFServerInfo: IServerInfo;
    // 个股F10服务器信息
    FF10ServerInfo: IServerInfo;
    // 资讯服务器信息
    FNewsServerInfo: IServerInfo;
    // 资讯文件服务器信息
    FNewsFileServerInfo: IServerInfo;
    // 资产服务器信息
    FAssetWebServerInfo: IServerInfo;
    // 模拟组合服务器信息
    FSimulationServerInfo: IServerInfo;
    // 中科服务器信息
    FZhongKeServerInfo: IServerInfo;

    { HQ }

    // DDE行情服务器信息
    FDDEServerInfo: IServerInfo;
    // 美股行情
    FUSAServerInfo: IServerInfo;
    // 期货行情服务器信息
    FFutuesServerInfo: IServerInfo;
    // 港股实时服务器信息
    FHKRealServerInfo: IServerInfo;
    // LevelI行情服务器信息
    FLevelIServerInfo: IServerInfo;
    // LevelI行情服务器信息
    FLevelIIServerInfo: IServerInfo;
    // 港股延时服务器信息
    FHKDelayServerInfo: IServerInfo;

    { Indicators }

    // 公网指标服务器信息
    FBaseIndicatorServerInfo: IServerInfo;
    // 资产指标服务器信息
    FAssetIndicatorServerInfo: IServerInfo;

    { Update }

    // 升级服务器信息
    FUpdateServerInfo: IServerInfo;

    { HS }

    // 用户行为分析
    FActionAnalysisServerInfo: IServerInfo;
  protected
    // 初始化基础信息
    procedure DoInitBaseInfos;
    // 初始化服务器信息
    procedure DoInitServerInfos;
    // 读取Json文件数据
    procedure DoReadJsonFileData;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ISyncAsync }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; safecall;
    // 同步执行方法
    procedure SyncExecute; safecall;
    // 异步执行方法
    procedure AsyncExecute; safecall;

    { IConfig  Impl }

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

uses
  Json,
  Utils,
  CfgCacheImpl,
  UserInfoImpl,
  ProxyInfoImpl,
  LoginInfoImpl,
  SyscfgInfoImpl,
  UpdateInfoImpl,
  ServerInfoImpl,
  CompanyInfoImpl;

const

  SERVER_SECTION_HS         = 'HS';
  SERVER_SECTION_HQ         = 'HQ';
  SERVER_SECTION_WEB        = 'Web';
  SERVER_SECTION_INDICATORS = 'Indicators';
  SERVER_SECTION_UPDATE     = 'UPDATE';

{ TConfigImpl }

constructor TConfigImpl.Create;
begin
  inherited;
  FAppPath := ExtractFilePath(ParamStr(0));
  FAppPath := ExpandFileName(FAppPath + '..\');

  FDllComLib := TDllComLib.Create;

  FSysCfgCache := TCfgCacheImpl.Create as ICfgCache;
  FUserCfgCache := TCfgCacheImpl.Create as ICfgCache;

  FUserInfo := TUserInfoImpl.Create as IUserInfo;
  FProxyInfo := TProxyInfoImpl.Create as IProxyInfo;
  FLoginInfo := TLoginInfoImpl.Create as ILoginInfo;
  FSyscfgInfo := TSyscfgInfoImpl.Create as ISyscfgInfo;
  FUpdateInfo := TUpdateInfoImpl.Create as IUpdateInfo;
  FCompanyInfo := TCompanyInfoImpl.Create as ICompanyInfo;

  {web}

  FFOFServerInfo := TServerInfoImpl.Create('FOF') as IServerInfo;
  FF10ServerInfo := TServerInfoImpl.Create('F10') as IServerInfo;
  FNewsServerInfo := TServerInfoImpl.Create('News') as IServerInfo;
  FNewsFileServerInfo := TServerInfoImpl.Create('NewsFile') as IServerInfo;
  FAssetWebServerInfo := TServerInfoImpl.Create('AssetWeb') as IServerInfo;
  FSimulationServerInfo := TServerInfoImpl.Create('Simulation') as IServerInfo;
  FZhongKeServerInfo := TServerInfoImpl.Create('ZhongKe') as IServerInfo;

  { HQ }

  FDDEServerInfo := TServerInfoImpl.Create('DDE') as IServerInfo;
  FUSAServerInfo := TServerInfoImpl.Create('USStock') as IServerInfo;
  FFutuesServerInfo := TServerInfoImpl.Create('Futues') as IServerInfo;
  FHKRealServerInfo := TServerInfoImpl.Create('HKReal') as IServerInfo;
  FLevelIServerInfo := TServerInfoImpl.Create('LevelI') as IServerInfo;
  FLevelIIServerInfo := TServerInfoImpl.Create('LevelII') as IServerInfo;
  FHKDelayServerInfo := TServerInfoImpl.Create('HKDelay') as IServerInfo;

  { Indicators }

  FBaseIndicatorServerInfo := TServerInfoImpl.Create('BaseIndicator') as IServerInfo;
  FAssetIndicatorServerInfo := TServerInfoImpl.Create('AssetIndicator') as IServerInfo;

  { Update }

  FUpdateServerInfo := TServerInfoImpl.Create('Upgrade') as IServerInfo;

  { HS }

  FActionAnalysisServerInfo := TServerInfoImpl.Create('ActionAnalysis') as IServerInfo;
end;

destructor TConfigImpl.Destroy;
begin
  FCompanyInfo := nil;
  FProxyInfo := nil;
  FLoginInfo := nil;
  FSyscfgInfo := nil;
  FUpdateInfo := nil;
  FCompanyInfo := nil;

  {web}

  FFOFServerInfo := nil;
  FF10ServerInfo := nil;
  FNewsServerInfo := nil;
  FNewsFileServerInfo := nil;
  FAssetWebServerInfo := nil;
  FSimulationServerInfo := nil;
  FZhongKeServerInfo := nil;

  { HQ }

  FDDEServerInfo := nil;
  FUSAServerInfo := nil;
  FFutuesServerInfo := nil;
  FHKRealServerInfo := nil;
  FLevelIServerInfo := nil;
  FLevelIIServerInfo := nil;
  FHKDelayServerInfo := nil;

  { Indicators }

  FBaseIndicatorServerInfo := nil;
  FAssetIndicatorServerInfo := nil;

  { Update }

  FUpdateServerInfo := nil;

  { HS }

  FActionAnalysisServerInfo := nil;

  FUserCfgCache := nil;
  FSysCfgCache := nil;

  FDllComLib.Free;
  inherited;
end;

procedure TConfigImpl.DoInitBaseInfos;
var
  LIniFile: TIniFile;
begin
  FBaseFile := GetCfgPath + 'CfgInfos.ini';
  LIniFile := TIniFile.Create(FBaseFile);
  try
    FUserInfo.LoadByIniFile(LIniFile);
    FProxyInfo.LoadByIniFile(LIniFile);
    FLoginInfo.LoadByIniFile(LIniFile);
    FSyscfgInfo.LoadByIniFile(LIniFile);
    FUpdateInfo.LoadByIniFile(LIniFile);
    FCompanyInfo.LoadByIniFile(LIniFile);
    FUserInfo.Initialize(FAppContext);
    FProxyInfo.Initialize(FAppContext);
    FLoginInfo.Initialize(FAppContext);
    FSyscfgInfo.Initialize(FAppContext);
    FUpdateInfo.Initialize(FAppContext);
    FCompanyInfo.Initialize(FAppContext);
  finally
    LIniFile.Free;
  end;
end;

procedure TConfigImpl.DoInitServerInfos;
var
  LIniFile: TIniFile;
begin
  FServerListFile := GetCfgPath + 'CfgServers.dat';
  LIniFile := TIniFile.Create(FServerListFile);
  try
    { Indicators }

    FBaseIndicatorServerInfo.LoadByIniFile(LIniFile);
    FAssetIndicatorServerInfo.LoadByIniFile(LIniFile);

    { HQ }

    FDDEServerInfo.LoadByIniFile(LIniFile);
    FUSAServerInfo.LoadByIniFile(LIniFile);
    FFutuesServerInfo.LoadByIniFile(LIniFile);
    FHKRealServerInfo.LoadByIniFile(LIniFile);
    FLevelIServerInfo.LoadByIniFile(LIniFile);
    FLevelIIServerInfo.LoadByIniFile(LIniFile);
    FHKDelayServerInfo.LoadByIniFile(LIniFile);

    {web}

    FFOFServerInfo.LoadByIniFile(LIniFile);
    FF10ServerInfo.LoadByIniFile(LIniFile);
    FNewsServerInfo.LoadByIniFile(LIniFile);
    FNewsFileServerInfo.LoadByIniFile(LIniFile);
    FAssetWebServerInfo.LoadByIniFile(LIniFile);
    FSimulationServerInfo.LoadByIniFile(LIniFile);

    { Update }

    FUpdateServerInfo.LoadByIniFile(LIniFile);

    { HS }

    FActionAnalysisServerInfo.LoadByIniFile(LIniFile);
  finally
    LIniFile.Free;
  end;
end;

procedure TConfigImpl.DoReadJsonFileData;
var
  LTextFile: TextFile;
  LJSONObject, LTmpObject: TJSONObject;
  LLineData, LContent: string;
begin
  AssignFile(LTextFile, FServerListFile);
  Reset(LTextFile);
  while not EOF(LTextFile) do begin

    Readln(LTextFile, LLineData);
    LContent := LContent + LLineData;
  end;
  if LContent <> '' then begin

    LJSONObject := Utils.GetJsonObjectByString(LContent);
    if LJSONObject = nil then Exit;

    try
      { Indicators }
      LTmpObject := Utils.GetJsonObjectByJsonObject(LJSONObject, SERVER_SECTION_INDICATORS);
      FBaseIndicatorServerInfo.LoadByJsonObject(LTmpObject);
      FAssetIndicatorServerInfo.LoadByJsonObject(LTmpObject);

      { HQ }
      LTmpObject := Utils.GetJsonObjectByJsonObject(LJSONObject, SERVER_SECTION_WEB);
      FDDEServerInfo.LoadByJsonObject(LTmpObject);
      FUSAServerInfo.LoadByJsonObject(LTmpObject);
      FFutuesServerInfo.LoadByJsonObject(LTmpObject);
      FHKRealServerInfo.LoadByJsonObject(LTmpObject);
      FLevelIServerInfo.LoadByJsonObject(LTmpObject);
      FLevelIIServerInfo.LoadByJsonObject(LTmpObject);
      FHKDelayServerInfo.LoadByJsonObject(LTmpObject);

      {web}
      LTmpObject := Utils.GetJsonObjectByJsonObject(LJSONObject, SERVER_SECTION_HQ);
      FFOFServerInfo.LoadByJsonObject(LTmpObject);
      FF10ServerInfo.LoadByJsonObject(LTmpObject);
      FNewsServerInfo.LoadByJsonObject(LTmpObject);
      FNewsFileServerInfo.LoadByJsonObject(LTmpObject);
      FAssetWebServerInfo.LoadByJsonObject(LTmpObject);
      FSimulationServerInfo.LoadByJsonObject(LTmpObject);

      { HS }
      LTmpObject := Utils.GetJsonObjectByJsonObject(LJSONObject, SERVER_SECTION_HS);
      FActionAnalysisServerInfo.LoadByJsonObject(LTmpObject);

      { Update }
      LTmpObject := Utils.GetJsonObjectByJsonObject(LJSONObject, SERVER_SECTION_UPDATE);
      FUpdateServerInfo.LoadByJsonObject(LTmpObject);
    finally
      LJSONObject.Free;
    end;
  end;
end;

procedure TConfigImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FSysCfgCache.Initialize(FAppContext);
  FUserCfgCache.Initialize(FAppContext);
  DoInitBaseInfos;
  DoInitServerInfos;
end;

procedure TConfigImpl.UnInitialize;
begin
  FUserCfgCache.UnInitialize;
  FSysCfgCache.UnInitialize;
  FAppContext := nil;
end;

function TConfigImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TConfigImpl.SyncExecute;
begin
  ForceInitSysDirectories;
  FUserInfo.LoadCache;
  FProxyInfo.LoadCache;
  FLoginInfo.LoadCache;
  FSyscfgInfo.LoadCache;
  FUpdateInfo.LoadCache;
  FCompanyInfo.LoadCache;
end;

procedure TConfigImpl.AsyncExecute;
begin

end;

procedure TConfigImpl.ForceInitSysDirectories;
begin
  if not DirectoryExists(GetLogPath) then begin
    ForceDirectories(GetLogPath);
  end;

  if not DirectoryExists(GetCachePath) then begin
    ForceDirectories(GetCachePath);
  end;

  if not DirectoryExists(GetUsersPath) then begin
    ForceDirectories(GetUsersPath);
  end;

  FSysCfgCache.SetCfgCachePath(GetCachePath);
  FSysCfgCache.LoadCfgCacheData;
end;

procedure TConfigImpl.ForceInitUserDirectories;
begin
  if not DirectoryExists(GetUserPath) then begin
    ForceDirectories(GetUserPath);
  end;

  if not DirectoryExists(GetUserCfgPath) then begin
    ForceDirectories(GetUserCfgPath);
  end;

  if not DirectoryExists(GetUserCachePath) then begin
    ForceDirectories(GetUserCachePath);
  end;

  FUserCfgCache.SetCfgCachePath(GetUserCachePath);
  FUserCfgCache.LoadCfgCacheData;


end;

function TConfigImpl.GetDllComLib: TDllComLib;
begin
  Result := FDllComLib;
end;

function TConfigImpl.GetSysCfgCache: ICfgCache;
begin
  Result := FSysCfgCache;
end;

function TConfigImpl.GetUserCfgCache: ICfgCache;
begin
  Result := FUserCfgCache;
end;

function TConfigImpl.GetAppPath: WideString;
begin
  Result := FAppPath;
end;

function TConfigImpl.GetBinPath: WideString;
begin
  Result := FAppPath + 'Bin\';
end;

function TConfigImpl.GetCfgPath: WideString;
begin
  Result := FAppPath + 'Cfg\';
end;

function TConfigImpl.GetLogPath: WideString;
begin
  Result := FAppPath + 'Log\';
end;

function TConfigImpl.GetSkinPath: WideString;
begin
  Result := FAppPath + 'Skin\';
end;

function TConfigImpl.GetUserPath: WideString;
begin
  if FUserInfo.GetAssetUserName <> '' then begin
    Result := GetUsersPath + FUserInfo.GetAssetUserName + '\';
  end else begin
    Result := '';
  end;
end;

function TConfigImpl.GetUsersPath: WideString;
begin
  Result := FAppPath + 'Users\';
end;

function TConfigImpl.GetCachePath: WideString;
begin
  Result := FAppPath + 'Cache\';
end;

function TConfigImpl.GetUpdatePath: WideString;
begin
  Result := FAppPath + 'Update\';
end;

function TConfigImpl.GetUserCfgPath: WideString;
begin
  Result := GetUserPath;
  if Result <> '' then begin
    Result := Result + 'Cfg\';
  end;
end;

function TConfigImpl.GetUserCachePath: WideString;
begin
  Result := GetUserPath;
  if Result <> '' then begin
    Result := Result + 'Cache\';
  end;
end;

function TConfigImpl.GetUserInfo: IUserInfo;
begin
  Result := FUserInfo;
end;

function TConfigImpl.GetProxyInfo: IProxyInfo;
begin
  Result := FProxyInfo;
end;

function TConfigImpl.GetLoginInfo: ILoginInfo;
begin
  Result := FLoginInfo;
end;

function TConfigImpl.GetSyscfgInfo: ISyscfgInfo;
begin
  Result := FSyscfgInfo;
end;

function TConfigImpl.GetUpdateInfo: IUpdateInfo;
begin
  Result := FUpdateInfo;
end;

function TConfigImpl.GetCompanyInfo: ICompanyInfo;
begin
  Result := FCompanyInfo;
end;

function TConfigImpl.GetFOFServerInfo: IServerInfo;
begin
  Result := FFOFServerInfo;
end;

function TConfigImpl.GetF10ServerInfo: IServerInfo;
begin
  Result := FF10ServerInfo;
end;

function TConfigImpl.GetNewsServerInfo: IServerInfo;
begin
  Result := FNewsServerInfo;
end;

function TConfigImpl.GetZhongKeServerInfo: IServerInfo;
begin
  Result := FZhongKeServerInfo;
end;

function TConfigImpl.GetNewsFileServerInfo: IServerInfo;
begin
  Result := FNewsFileServerInfo;
end;

function TConfigImpl.GetAssetWebServerInfo: IServerInfo;
begin
  Result := FNewsFileServerInfo;
end;

function TConfigImpl.GetSimulationServerInfo: IServerInfo;
begin
  Result := FNewsFileServerInfo;
end;

function TConfigImpl.GetDDEServerInfo: IServerInfo;
begin
  Result := FDDEServerInfo;
end;

function TConfigImpl.GetUSAServerInfo: IServerInfo;
begin
  Result := FUSAServerInfo;
end;

function TConfigImpl.GetFutuesServerInfo: IServerInfo;
begin
  Result := FFutuesServerInfo;
end;

function TConfigImpl.GetHKRealServerInfo: IServerInfo;
begin
  Result := FHKRealServerInfo;
end;

function TConfigImpl.GetLevelIServerInfo: IServerInfo;
begin
  Result := FLevelIServerInfo;
end;

function TConfigImpl.GetLevelIIServerInfo: IServerInfo;
begin
  Result := FLevelIIServerInfo;
end;

function TConfigImpl.GetHKDelayServerInfo: IServerInfo;
begin
  Result := FHKDelayServerInfo;
end;

function TConfigImpl.GetBaseIndicatorServerInfo: IServerInfo;
begin
  Result := FBaseIndicatorServerInfo;
end;

function TConfigImpl.GetAssetIndicatorServerInfo: IServerInfo;
begin
  Result := FAssetIndicatorServerInfo;
end;

function TConfigImpl.GetUpdateServerInfo: IServerInfo;
begin
  Result := FUpdateServerInfo;
end;

function TConfigImpl.GetActionAnalysisServerInfo: IServerInfo;
begin
  Result := FActionAnalysisServerInfo;
end;

end.
