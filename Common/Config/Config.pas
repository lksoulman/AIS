unit Config;

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
  WebInfo,
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

end.
