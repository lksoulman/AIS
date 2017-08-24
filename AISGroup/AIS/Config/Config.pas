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

end.
