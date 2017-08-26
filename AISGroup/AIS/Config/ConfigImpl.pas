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
  Config,
  WebInfo,
  Windows,
  Classes,
  SysUtils,
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
  CompanyInfo,
  Generics.Collections;

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
    // �������ֵ�
    FServerInfoDic: TDictionary<string, IServerInfo>;

    { Gildata }

    // Web ��Ϣ
    FWebInfo: IWebInfo;
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

    { Indicators }

    // ����ָ���������Ϣ
    FBaseIndicatorServerInfo: IServerInfo;
    // �ʲ�ָ���������Ϣ
    FAssetIndicatorServerInfo: IServerInfo;

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
    // ���м䱨��
    FInterBankPriceServerInfo: IServerInfo;
    // Fly����
    FFlyQuantificationServerInfo: IServerInfo;

    { Update }

    // ������������Ϣ
    FUpdateServerInfo: IServerInfo;

    { HS }

    // �û���Ϊ����
    FActionAnalysisServerInfo: IServerInfo;
  protected
    // ��ʼ��web��Ϣ
    procedure DoInitWebInfos;
    // ��ʼ��������Ϣ
    procedure DoInitBaseInfos;
    // ��ʼ����������Ϣ
    procedure DoInitServerInfos;
    // ��ʼ����������Ϣ�ֵ�
    procedure DoInitServerInfoDic;
    // ��ȡJson�ļ�����
    procedure DoReadJsonFileData;

    // ��ʼ����Ҫ����Դ
    procedure DoInitialize;
    // �ͷŲ���Ҫ�Ķ���
    procedure DoUnInitialize;
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
    // ��ȡ������ IP
    function GetServerIP(AServerName: WideString): WideString;

    { Indicators }

    // ����ָ���������Ϣ
    function GetBaseIndicatorServerInfo: IServerInfo;
    // �ʲ�ָ���������Ϣ
    function GetAssetIndicatorServerInfo: IServerInfo;

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

    { Info }

    // ��ȡ web ��Ϣ
    function GetWebInfo: IWebInfo;
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

    // ��ȡFOF��������Ϣ
    function GetFOFServerInfo: IServerInfo;
    // ��ȡ����F10��������Ϣ
    function GetF10ServerInfo: IServerInfo;
    // ��ȡ��ȡ��Ѷ��������Ϣ
    function GetNewsServerInfo: IServerInfo;
    // ��ȡ�пƷ�������Ϣ
    function GetZhongKeServerInfo: IServerInfo;
    // ��ȡ��Ѷ�ļ���������Ϣ
    function GetNewsFileServerInfo: IServerInfo;
    // ��ȡ�ʲ���������Ϣ
    function GetAssetWebServerInfo: IServerInfo;
    // ��ȡģ����Ϸ�������Ϣ
    function GetSimulationServerInfo: IServerInfo;
    // ��ȡ���м䱨��
    function GetInterBankPriceServerInfo: IServerInfo;
    // ��ȡFly����
    function GetFlyQuantificationServerInfo: IServerInfo;

    { Update}

    // ��ȡ�����ն˷�����
    function GetUpdateServerInfo: IServerInfo;

    { hundsun}

    // ��ȡ�û���Ϊ��������Ϣ
    function GetActionAnalysisServerInfo: IServerInfo;
  end;

implementation

uses
  Json,
  Utils,
  IniFiles,
  NativeXml,
  WebInfoImpl,
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

  FWebInfo := TWebInfoImpl.Create as IWebInfo;
  FUserInfo := TUserInfoImpl.Create as IUserInfo;
  FProxyInfo := TProxyInfoImpl.Create as IProxyInfo;
  FLoginInfo := TLoginInfoImpl.Create as ILoginInfo;
  FSyscfgInfo := TSyscfgInfoImpl.Create as ISyscfgInfo;
  FUpdateInfo := TUpdateInfoImpl.Create as IUpdateInfo;
  FCompanyInfo := TCompanyInfoImpl.Create as ICompanyInfo;

  FServerInfoDic := TDictionary<string, IServerInfo>.Create(25);
  {web}

  FFOFServerInfo := TServerInfoImpl.Create('FOF') as IServerInfo;
  FF10ServerInfo := TServerInfoImpl.Create('F10') as IServerInfo;
  FNewsServerInfo := TServerInfoImpl.Create('News') as IServerInfo;
  FNewsFileServerInfo := TServerInfoImpl.Create('NewsFile') as IServerInfo;
  FAssetWebServerInfo := TServerInfoImpl.Create('AssetWeb') as IServerInfo;
  FSimulationServerInfo := TServerInfoImpl.Create('Simulation') as IServerInfo;
  FZhongKeServerInfo := TServerInfoImpl.Create('ZhongKe') as IServerInfo;
  FInterBankPriceServerInfo := TServerInfoImpl.Create('InterBankPrice') as IServerInfo;
  FFlyQuantificationServerInfo := TServerInfoImpl.Create('FlyQuantification') as IServerInfo;

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
  FWebInfo := nil;
  FUserINfo := nil;
  FProxyInfo := nil;
  FLoginInfo := nil;
  FSyscfgInfo := nil;
  FUpdateInfo := nil;
  FCompanyInfo := nil;

  { Indicators }

  FBaseIndicatorServerInfo := nil;
  FAssetIndicatorServerInfo := nil;

  { HQ }

  FDDEServerInfo := nil;
  FUSAServerInfo := nil;
  FFutuesServerInfo := nil;
  FHKRealServerInfo := nil;
  FLevelIServerInfo := nil;
  FLevelIIServerInfo := nil;
  FHKDelayServerInfo := nil;

  {web}

  FFOFServerInfo := nil;
  FF10ServerInfo := nil;
  FNewsServerInfo := nil;
  FNewsFileServerInfo := nil;
  FAssetWebServerInfo := nil;
  FSimulationServerInfo := nil;
  FZhongKeServerInfo := nil;
  FInterBankPriceServerInfo := nil;
  FFlyQuantificationServerInfo := nil;

  { Update }

  FUpdateServerInfo := nil;

  { HS }

  FActionAnalysisServerInfo := nil;

  FUserCfgCache := nil;
  FSysCfgCache := nil;

  FServerInfoDic.Free;

  FDllComLib.Free;
  inherited;
end;

procedure TConfigImpl.DoInitWebInfos;
var
  LFile: string;
  LNode: TXmlNode;
  LXml: TNativeXml;
  LNodeList: TList;
begin
  if FAppContext.GetConfig <> nil then begin
    LFile := (FAppContext.GetConfig as IConfig).GetCfgPath + 'WebCfg.xml';
    if FileExists(LFile) then begin
      LXml := TNativeXml.Create(nil);
      try
        LXml.LoadFromFile(LFile);
        LXml.XmlFormat := xfReadable;
        LNode := LXml.Root;
        LNodeList := TList.Create;
        try
          LNode.FindNodes('UrlInfo', LNodeList);
          FWebInfo.LoadXmlNodes(LNodeList);
        finally
          LNodeList.Free;
        end;
      finally
        LXml.Free;
      end;
    end;
  end;
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
    FInterBankPriceServerInfo.LoadByIniFile(LIniFile);
    FFlyQuantificationServerInfo.LoadByIniFile(LIniFile);

    { Update }

    FUpdateServerInfo.LoadByIniFile(LIniFile);

    { HS }

    FActionAnalysisServerInfo.LoadByIniFile(LIniFile);
  finally
    LIniFile.Free;
  end;
end;

procedure TConfigImpl.DoInitServerInfoDic;
begin
  { Indicators }

  FServerInfoDic.AddOrSetValue(FBaseIndicatorServerInfo.GetServerName, FBaseIndicatorServerInfo);
  FServerInfoDic.AddOrSetValue(FAssetIndicatorServerInfo.GetServerName, FAssetIndicatorServerInfo);

  { HQ }

  FServerInfoDic.AddOrSetValue(FDDEServerInfo.GetServerName, FDDEServerInfo);
  FServerInfoDic.AddOrSetValue(FUSAServerInfo.GetServerName, FUSAServerInfo);
  FServerInfoDic.AddOrSetValue(FFutuesServerInfo.GetServerName, FFutuesServerInfo);
  FServerInfoDic.AddOrSetValue(FHKRealServerInfo.GetServerName, FHKRealServerInfo);
  FServerInfoDic.AddOrSetValue(FLevelIServerInfo.GetServerName, FLevelIServerInfo);
  FServerInfoDic.AddOrSetValue(FLevelIIServerInfo.GetServerName, FLevelIIServerInfo);
  FServerInfoDic.AddOrSetValue(FHKDelayServerInfo.GetServerName, FHKDelayServerInfo);

  { web }

  FServerInfoDic.AddOrSetValue(FFOFServerInfo.GetServerName, FFOFServerInfo);
  FServerInfoDic.AddOrSetValue(FF10ServerInfo.GetServerName, FF10ServerInfo);
  FServerInfoDic.AddOrSetValue(FNewsServerInfo.GetServerName, FNewsServerInfo);
  FServerInfoDic.AddOrSetValue(FNewsFileServerInfo.GetServerName, FNewsFileServerInfo);
  FServerInfoDic.AddOrSetValue(FAssetWebServerInfo.GetServerName, FAssetWebServerInfo);
  FServerInfoDic.AddOrSetValue(FSimulationServerInfo.GetServerName, FSimulationServerInfo);
  FServerInfoDic.AddOrSetValue(FZhongKeServerInfo.GetServerName, FZhongKeServerInfo);
  FServerInfoDic.AddOrSetValue(FInterBankPriceServerInfo.GetServerName, FInterBankPriceServerInfo);
  FServerInfoDic.AddOrSetValue(FFlyQuantificationServerInfo.GetServerName, FFlyQuantificationServerInfo);

  { Update }

  FServerInfoDic.AddOrSetValue(FUpdateServerInfo.GetServerName, FUpdateServerInfo);

  { HS }

  FServerInfoDic.AddOrSetValue(FActionAnalysisServerInfo.GetServerName, FActionAnalysisServerInfo);
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

procedure TConfigImpl.DoInitialize;
begin
  FSysCfgCache.Initialize(FAppContext);
  FUserCfgCache.Initialize(FAppContext);

  FWebInfo.Initialize(FAppContext);
  FUserInfo.Initialize(FAppContext);
  FProxyInfo.Initialize(FAppContext);
  FLoginInfo.Initialize(FAppContext);
  FSyscfgInfo.Initialize(FAppContext);
  FUpdateInfo.Initialize(FAppContext);
  FCompanyInfo.Initialize(FAppContext);

  { Indicators }

  FBaseIndicatorServerInfo.Initialize(FAppContext);
  FAssetIndicatorServerInfo.Initialize(FAppContext);

  { HQ }

  FDDEServerInfo.Initialize(FAppContext);
  FUSAServerInfo.Initialize(FAppContext);
  FFutuesServerInfo.Initialize(FAppContext);
  FHKRealServerInfo.Initialize(FAppContext);
  FLevelIServerInfo.Initialize(FAppContext);
  FLevelIIServerInfo.Initialize(FAppContext);
  FHKDelayServerInfo.Initialize(FAppContext);

  {web}

  FFOFServerInfo.Initialize(FAppContext);
  FF10ServerInfo.Initialize(FAppContext);
  FNewsServerInfo.Initialize(FAppContext);
  FNewsFileServerInfo.Initialize(FAppContext);
  FAssetWebServerInfo.Initialize(FAppContext);
  FSimulationServerInfo.Initialize(FAppContext);
  FInterBankPriceServerInfo.Initialize(FAppContext);
  FFlyQuantificationServerInfo.Initialize(FAppContext);

  { Update }

  FUpdateServerInfo.Initialize(FAppContext);

  { HS }

  FActionAnalysisServerInfo.Initialize(FAppContext);
end;

procedure TConfigImpl.DoUnInitialize;
begin
  FWebInfo.UnInitialize;
  FUserInfo.UnInitialize;
  FProxyInfo.UnInitialize;
  FLoginInfo.UnInitialize;
  FSyscfgInfo.UnInitialize;
  FUpdateInfo.UnInitialize;
  FCompanyInfo.UnInitialize;

  { Indicators }

  FBaseIndicatorServerInfo.UnInitialize;
  FAssetIndicatorServerInfo.UnInitialize;

  { HQ }

  FDDEServerInfo.UnInitialize;
  FUSAServerInfo.UnInitialize;
  FFutuesServerInfo.UnInitialize;
  FHKRealServerInfo.UnInitialize;
  FLevelIServerInfo.UnInitialize;
  FLevelIIServerInfo.UnInitialize;
  FHKDelayServerInfo.UnInitialize;

  {web}

  FFOFServerInfo.UnInitialize;
  FF10ServerInfo.UnInitialize;
  FNewsServerInfo.UnInitialize;
  FNewsFileServerInfo.UnInitialize;
  FAssetWebServerInfo.UnInitialize;
  FSimulationServerInfo.UnInitialize;
  FInterBankPriceServerInfo.UnInitialize;
  FFlyQuantificationServerInfo.UnInitialize;

  { Update }

  FUpdateServerInfo.UnInitialize;

  { HS }

  FActionAnalysisServerInfo.UnInitialize;

  FServerInfoDic.Clear;

  FUserCfgCache.UnInitialize;
  FSysCfgCache.UnInitialize;
end;

procedure TConfigImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  ForceInitSysDirectories;
  DoInitBaseInfos;
  DoInitServerInfos;
  DoInitServerInfoDic;
end;

procedure TConfigImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TConfigImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TConfigImpl.SyncExecute;
begin
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

function TConfigImpl.GetServerIP(AServerName: WideString): WideString;
var
  LServerInfo: IServerInfo;
begin
  if FServerInfoDic.TryGetValue(AServerName, LServerInfo)
    and (LServerInfo <> nil) then begin
    Result := LServerInfo.GetServerUrl;
  end else begin
    Result := '';
  end;
end;

function TConfigImpl.GetWebInfo: IWebInfo;
begin
  Result := FWebInfo;
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

function TConfigImpl.GetBaseIndicatorServerInfo: IServerInfo;
begin
  Result := FBaseIndicatorServerInfo;
end;

function TConfigImpl.GetAssetIndicatorServerInfo: IServerInfo;
begin
  Result := FAssetIndicatorServerInfo;
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

function TConfigImpl.GetInterBankPriceServerInfo: IServerInfo;
begin
  Result := FInterBankPriceServerInfo;
end;

function TConfigImpl.GetFlyQuantificationServerInfo: IServerInfo;
begin
  Result := FFlyQuantificationServerInfo;
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
