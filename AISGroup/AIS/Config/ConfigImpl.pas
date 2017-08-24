unit ConfigImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-24
// Comments��
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

  // �ն����ù���
  TConfigImpl = class(TInterfacedObject, ISyncAsync, IConfig)
  private
    // Ӧ�ó���Ŀ¼
    FAppPath: string;
    // ���������ļ�
    FBaseFile: string;
    // �����������ļ�
    FServerListFile: string;
    // ��̬�����Com������
    FDllComLib: TDllComLib;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ϵͳ�����û���
    FSysCfgCache: ICfgCache;
    // �û������û���
    FUserCfgCache: ICfgCache;

    { Gildata }

    // �û���Ϣ
    FUserInfo: IUserInfo;
    // ������Ϣ
    FProxyInfo: IProxyInfo;
    // ��¼��Ϣ
    FLoginInfo: ILoginInfo;
    // ϵͳ����������Ϣ
    FSyscfgInfo: ISyscfgInfo;
    // ������Ϣ
    FUpdateInfo: IUpdateInfo;
    // ��˾����
    FCompanyInfo: ICompanyInfo;

    { web }

    // FOF��������Ϣ
    FFOFServerInfo: IServerInfo;
    // ����F10��������Ϣ
    FF10ServerInfo: IServerInfo;
    // ��Ѷ��������Ϣ
    FNewsServerInfo: IServerInfo;
    // ��Ѷ�ļ���������Ϣ
    FNewsFileServerInfo: IServerInfo;
    // �ʲ���������Ϣ
    FAssetWebServerInfo: IServerInfo;
    // ģ����Ϸ�������Ϣ
    FSimulationServerInfo: IServerInfo;
    // �пƷ�������Ϣ
    FZhongKeServerInfo: IServerInfo;

    { HQ }

    // DDE�����������Ϣ
    FDDEServerInfo: IServerInfo;
    // ��������
    FUSAServerInfo: IServerInfo;
    // �ڻ������������Ϣ
    FFutuesServerInfo: IServerInfo;
    // �۹�ʵʱ��������Ϣ
    FHKRealServerInfo: IServerInfo;
    // LevelI�����������Ϣ
    FLevelIServerInfo: IServerInfo;
    // LevelI�����������Ϣ
    FLevelIIServerInfo: IServerInfo;
    // �۹���ʱ��������Ϣ
    FHKDelayServerInfo: IServerInfo;

    { Indicators }

    // ����ָ���������Ϣ
    FBaseIndicatorServerInfo: IServerInfo;
    // �ʲ�ָ���������Ϣ
    FAssetIndicatorServerInfo: IServerInfo;

    { Update }

    // ������������Ϣ
    FUpdateServerInfo: IServerInfo;

    { HS }

    // �û���Ϊ����
    FActionAnalysisServerInfo: IServerInfo;
  protected
    // ��ʼ��������Ϣ
    procedure DoInitBaseInfos;
    // ��ʼ����������Ϣ
    procedure DoInitServerInfos;
    // ��ȡJson�ļ�����
    procedure DoReadJsonFileData;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISyncAsync }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; safecall;
    // ͬ��ִ�з���
    procedure SyncExecute; safecall;
    // �첽ִ�з���
    procedure AsyncExecute; safecall;

    { IConfig  Impl }

    // ��ʼ��ϵͳ��Ŀ¼
    procedure ForceInitSysDirectories;
    // ��ʼ���û���Ŀ¼
    procedure ForceInitUserDirectories;
    // ��ȡ΢������
    function GetDllComLib: TDllComLib;
    // ��ȡ���û���ӿ�
    function GetSysCfgCache: ICfgCache;
    // ��ȡ�û����û���ӿ�
    function GetUserCfgCache: ICfgCache;

    { Directory }

    // ��ȡӦ�ó���Ŀ¼
    function GetAppPath: WideString;
    // ��ȡӦ�ó���ִ��Ŀ¼
    function GetBinPath: WideString;
    // ��ȡӦ�ó���ϵͳ������Ŀ¼
    function GetCfgPath: WideString;
    // ��ȡӦ�ó�����־Ŀ¼
    function GetLogPath: WideString;
    // ��ȡӦ�ó���Ƥ��Ŀ¼
    function GetSkinPath: WideString;
    // ��ȡ�û�˽��Ŀ¼
    function GetUserPath: WideString;
    // ��ȡ Users Ŀ¼
    function GetUsersPath: WideString;
    // ��ȡӦ�ó���ϵͳ����������Ŀ¼
    function GetCachePath: WideString;
    // ��ȡӦ�ó�����µĸ���Ŀ¼
    function GetUpdatePath: WideString;
    // ��ȡ�û�˽������Ŀ¼
    function GetUserCfgPath: WideString;
    // ��ȡ�û�˽�еĻ���Ŀ¼
    function GetUserCachePath: WideString;

    { Info }

    // ��ȡ�û���Ϣ
    function GetUserInfo: IUserInfo;
    // ��ȡ������Ϣ
    function GetProxyInfo: IProxyInfo;
    // ��ȡ��¼��Ϣ
    function GetLoginInfo: ILoginInfo;
    // ��ȡϵͳ������Ϣ
    function GetSyscfgInfo: ISyscfgInfo;
    // ��ȡ������Ϣ
    function GetUpdateInfo: IUpdateInfo;
    // ��ȡ��˾��Ϣ
    function GetCompanyInfo: ICompanyInfo;

    { web}

    // FOF��������Ϣ
    function GetFOFServerInfo: IServerInfo;
    // ����F10��������Ϣ
    function GetF10ServerInfo: IServerInfo;
    // ��Ѷ��������Ϣ
    function GetNewsServerInfo: IServerInfo;
    // �пƷ�������Ϣ
    function GetZhongKeServerInfo: IServerInfo;
    // ��Ѷ�ļ���������Ϣ
    function GetNewsFileServerInfo: IServerInfo;
    // �ʲ���������Ϣ
    function GetAssetWebServerInfo: IServerInfo;
    // ģ����Ϸ�������Ϣ
    function GetSimulationServerInfo: IServerInfo;

    { HQ }

    // DDE�����������Ϣ
    function GetDDEServerInfo: IServerInfo;
    // ��������
    function GetUSAServerInfo: IServerInfo;
    // �ڻ������������Ϣ
    function GetFutuesServerInfo: IServerInfo;
    // �۹�ʵʱ��������Ϣ
    function GetHKRealServerInfo: IServerInfo;
    // LevelI�����������Ϣ
    function GetLevelIServerInfo: IServerInfo;
    // LevelI�����������Ϣ
    function GetLevelIIServerInfo: IServerInfo;
    // �۹���ʱ��������Ϣ
    function GetHKDelayServerInfo: IServerInfo;

    { Indicators }

    // ����ָ���������Ϣ
    function GetBaseIndicatorServerInfo: IServerInfo;
    // �ʲ�ָ���������Ϣ
    function GetAssetIndicatorServerInfo: IServerInfo;

    { Update}

    // �����ն˷�����
    function GetUpdateServerInfo: IServerInfo;

    { hundsun}

    // �û���Ϊ��������Ϣ
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
