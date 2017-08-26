program AIS;

uses
  Vcl.Forms,
  Main in 'AIUI\Main.pas' {frmMain},
  Utils in 'Utils\Utils.pas',
  DllComLib in 'Utils\DllComLib.pas',
  CommonLock in 'Common\CommonLock.pas',
  CommonQueue in 'Common\CommonQueue.pas',
  CommonObject in 'Common\CommonObject.pas',
  CommonRefCounter in 'Common\CommonRefCounter.pas',
  ExecutorTask in 'Thread\ExecutorTask.pas',
  ExecutorPool in 'Thread\ExecutorPool.pas',
  ExecutorFixed in 'Thread\ExecutorFixed.pas',
  ExecutorThread in 'Thread\ExecutorThread.pas',
  ExecutorService in 'Thread\ExecutorService.pas',
  ExecutorScheduled in 'Thread\ExecutorScheduled.pas',
  ExecutorPoolImpl in 'Thread\ExecutorPoolImpl.pas',
  ExecutorFixedImpl in 'Thread\ExecutorFixedImpl.pas',
  ExecutorScheduledImpl in 'Thread\ExecutorScheduledImpl.pas',
  FastLog in 'FastLog\FastLog.pas',
  FastLogMgr in 'FastLog\FastLogMgr.pas',
  FastLogLevel in 'FastLog\FastLogLevel.pas',
  FastLogMgrImpl in 'FastLog\Impl\FastLogMgrImpl.pas',
  SyncAsync in 'SyncAsync\SyncAsync.pas',
  AppContext in 'AppContext\AppContext.pas',
  AppContextImpl in 'AppContext\AppContextImpl.pas',
  CacheMgr in 'Cache\CacheMgr.pas',
  CacheType in 'Cache\CacheType.pas',
  CacheTable in 'Cache\CacheTable.pas',
  CacheGFData in 'Cache\CacheGFData.pas',
  WNComDataSet in 'Cache\WNComDataSet.pas',
  SQLiteDataSet in 'Cache\SQLiteDataSet.pas',
  SQLiteAdapter in 'Cache\SQLiteAdapter.pas',
  CacheBaseData in 'Cache\CacheBaseData.pas',
  CacheUserData in 'Cache\CacheUserData.pas',
  CacheBaseDataImpl in 'Cache\CacheBaseDataImpl.pas',
  CacheUserDataImpl in 'Cache\CacheUserDataImpl.pas',
  Security in 'Security\Security.pas',
  SecuConst in 'Security\SecuConst.pas',
  SecuUpdate in 'Security\SecuUpdate.pas',
  SecuritySQL in 'Security\SecuritySQL.pas',
  SecurityType in 'Security\SecurityType.pas',
  SecurityImpl in 'Security\SecurityImpl.pas',
  SecuBaseData in 'Security\SecuBaseData.pas',
  SecuBaseDataImpl in 'Security\SecuBaseDataImpl.pas',
  MsgSys in 'Msg\MsgSys.pas',
  MsgType in 'Msg\MsgType.pas',
  MsgSysImpl in 'Msg\MsgSysImpl.pas',
  MsgFactory in 'Msg\MsgFactory.pas',
  MsgReceiver in 'Msg\MsgReceiver.pas',
  MsgServices in 'Msg\MsgServices.pas',
  MsgSubcribeMgr in 'Msg\MsgSubcribeMgr.pas',
  MsgReceiverImpl in 'Msg\MsgReceiverImpl.pas',
  MsgServicesImpl in 'Msg\MsgServicesImpl.pas',
  PlugLoadMsgSysImpl in 'Msg\Impl\PlugLoadMsgSysImpl.pas',
  NDayModifyPasswordMsgSysImpl in 'Msg\Impl\NDayModifyPasswordMsgSysImpl.pas',
  SecuBaseDataUpdateMsgSysImpl in 'Msg\Impl\SecuBaseDataUpdateMsgSysImpl.pas',
  Service in 'Service\Service.pas',
  ServiceBase in 'Service\ServiceBase.pas',
  ServiceAsset in 'Service\ServiceAsset.pas',
  ServiceConst in 'Service\ServiceConst.pas',
  ServiceImpl in 'Service\Impl\ServiceImpl.pas',
  ServiceBaseImpl in 'Service\Impl\ServiceBaseImpl.pas',
  ServiceAssetImpl in 'Service\Impl\ServiceAssetImpl.pas',
  LoginMainUI in 'Login\UI\LoginMainUI.pas' {LoginMainUI},
  LoginBindUI in 'Login\UI\LoginBindUI.pas' {LoginBindUI},
  LoginSettingUI in 'Login\UI\LoginSettingUI.pas' {LoginSettingUI},
  Login in 'Login\Login.pas',
  LoginGFType in 'Login\LoginGFType.pas',
  LoginUFXUser in 'Login\LoginUFXUser.pas',
  LoginGILUser in 'Login\LoginGILUser.pas',
  LoginPBOXUser in 'Login\LoginPBOXUser.pas',
  LoginMgr in 'Login\LoginMgr.pas',
  LoginMgrImpl in 'Login\LoginMgrImpl.pas',
  Base64 in 'Cipher\Base64\Base64.pas',
  AESEncript in 'Cipher\AES\AESEncript.pas',
  CipherRSA in 'Cipher\RSA\CipherRSA.pas',
  CipherAES in 'Cipher\AES\CipherAES.pas',
  CipherMD5 in 'Cipher\MD5\CipherMD5.pas',
  CipherCRC in 'Cipher\CRC\CipherCRC.pas',
  CipherMgr in 'Cipher\CipherMgr.pas',
  CipherMgrImpl in 'Cipher\CipherMgrImpl.pas',
  Config in 'Config\Config.pas',
  ConfigImpl in 'Config\ConfigImpl.pas',
  CfgCache in 'Config\CfgCache.pas',
  CfgCacheImpl in 'Config\CfgCacheImpl.pas',
  UserInfo in 'Config\Info\UserInfo.pas',
  ProxyInfo in 'Config\Info\ProxyInfo.pas',
  LoginInfo in 'Config\Info\LoginInfo.pas',
  SyscfgInfo in 'Config\Info\SyscfgInfo.pas',
  UpdateInfo in 'Config\Info\UpdateInfo.pas',
  ServerInfoImpl in 'Config\Info\ServerInfoImpl.pas',
  CompanyInfo in 'Config\Info\CompanyInfo.pas',
  UserInfoImpl in 'Config\Info\UserInfoImpl.pas',
  ProxyInfoImpl in 'Config\Info\ProxyInfoImpl.pas',
  LoginInfoImpl in 'Config\Info\LoginInfoImpl.pas',
  SyscfgInfoImpl in 'Config\Info\SyscfgInfoImpl.pas',
  UpdateInfoImpl in 'Config\Info\UpdateInfoImpl.pas',
  CompanyInfoImpl in 'Config\Info\CompanyInfoImpl.pas',
  ServerInfo in 'Config\Info\ServerInfo.pas',
  Behavior in 'UserBehavior\Behavior.pas',
  BehaviorPool in 'UserBehavior\BehaviorPool.pas',
  UserBehavior in 'UserBehavior\UserBehavior.pas',
  UserBehaviorImpl in 'UserBehavior\UserBehaviorImpl.pas',
  UserBehaviorPlugInImpl in 'PlugIn\Impl\UserBehaviorPlugInImpl.pas',
  Chrome in 'Chrome\Chrome.pas',
  Update in 'Update\Update.pas',
  UpdatePool in 'Update\UpdatePool.pas',
  UpdateCheck in 'Update\UpdateCheck.pas',
  UpdateGenerate in 'Update\UpdateGenerate.pas',
  DownloadMgr in 'Download\DownloadMgr.pas',
  DownloadJob in 'Download\DownloadJob.pas',
  DownloadMgrImpl in 'Download\DownloadMgrImpl.pas',
  Permission in 'Permission\Permission.pas',
  PermissionMgr in 'Permission\PermissionMgr.pas',
  PermissionMgrImpl in 'Permission\PermissionMgrImpl.pas',
  Sector in 'Sector\Sector.pas',
  SectorImpl in 'Sector\SectorImpl.pas',
  SectorMgr in 'Sector\SectorMgr.pas',
  SectorUserMgr in 'Sector\SectorUserMgr.pas',
  SectorUserMgrImpl in 'Sector\SectorUserMgrImpl.pas',
  Language in 'Language\Language.pas',
  LanguageMgr in 'Language\LanguageMgr.pas',
  LanguageType in 'Language\LanguageType.pas',
  LanguageConst in 'Language\LanguageConst.pas',
  LanguageMgrImpl in 'Language\LanguageMgrImpl.pas',
  LanguageChinese in 'Language\LanguageChinese.pas',
  LanguageTraditionalChinese in 'Language\LanguageTraditionalChinese.pas',
  PlugIn in 'PlugIn\PlugIn.pas',
  PlugInMgr in 'PlugIn\PlugInMgr.pas',
  PlugInImpl in 'PlugIn\PlugInImpl.pas',
  O32PlugInImpl in 'PlugIn\Impl\O32PlugInImpl.pas',
  ConfigPlugInImpl in 'PlugIn\Impl\ConfigPlugInImpl.pas',
  LoginMgrPlugInImpl in 'PlugIn\Impl\LoginMgrPlugInImpl.pas',
  CipherMgrPlugInImpl in 'PlugIn\Impl\CipherMgrPlugInImpl.pas',
  DownloadMgrPlugInImpl in 'PlugIn\Impl\DownloadMgrPlugInImpl.pas',
  MsgServicesPlugInImpl in 'PlugIn\Impl\MsgServicesPlugInImpl.pas',
  SecuBaseDataPlugInImpl in 'PlugIn\Impl\SecuBaseDataPlugInImpl.pas',
  CacheBaseDataPlugInImpl in 'PlugIn\Impl\CacheBaseDataPlugInImpl.pas',
  PermissionMgrPlugInImpl in 'PlugIn\Impl\PermissionMgrPlugInImpl.pas',
  CacheUserDataPlugInImpl in 'PlugIn\Impl\CacheUserDataPlugInImpl.pas',
  ServiceBasePlugInImpl in 'PlugIn\Impl\ServiceBasePlugInImpl.pas',
  SectorUserMgrPlugInImpl in 'PlugIn\Impl\SectorUserMgrPlugInImpl.pas',
  ServiceAssetPlugInImpl in 'PlugIn\Impl\ServiceAssetPlugInImpl.pas',
  IPCMsg in 'IPC\IPCMsg.pas',
  O32Com in 'O32\O32Com.pas',
  O32ComImpl in 'O32\O32ComImpl.pas',
  KeyFairy in 'KeyFairy\KeyFairy.pas',
  KeyFairyMgr in 'KeyFairy\KeyFairyMgr.pas',
  KeyFairyPool in 'KeyFairy\KeyFairyPool.pas',
  KeyFairyMgrImpl in 'KeyFairy\KeyFairyMgrImpl.pas',
  Command in 'Command\Command.pas',
  CommandMgr in 'Command\CommandMgr.pas',
  CommandPerm in 'Command\CommandPerm.pas',
  CommandConst in 'Command\CommandConst.pas',
  CommandImpl in 'Command\Impl\CommandImpl.pas',
  CommandMgrImpl in 'Command\Impl\CommandMgrImpl.pas',
  CommandRegisterClassMgr in 'Command\CommandRegisterClassMgr.pas',
  CommandMsgReceiverImpl in 'Command\Impl\CommandMsgReceiverImpl.pas',
  CommandRegisterClassMgrImpl in 'Command\Impl\CommandRegisterClassMgrImpl.pas',
  FormUI in 'AIUI\UI\FormUI.pas',
  ControlUI in 'AIUI\UI\ControlUI.pas',
  ButtonUI in 'AIUI\UI\ButtonUI.pas',
  ImageUI in 'AIUI\UI\ImageUI.pas',
  PanelUI in 'AIUI\UI\PanelUI.pas',
  PageControlUI in 'AIUI\UI\PageControlUI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.ShowMainForm := False;
  Application.Run;
end.
