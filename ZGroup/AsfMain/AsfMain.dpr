program AsfMain;

uses
  Vcl.Forms,
  Main in 'AIUI\Main.pas' {frmMain},
  FactoryAsfMainImpl in 'WFactory\Impl\FactoryAsfMainImpl.pas',
  LibaryInfo in 'WFactory\Mgr\LibaryInfo.pas',
  FactoryMgr in 'WFactory\Mgr\FactoryMgr.pas',
  FactoryMgrImpl in 'WFactory\Mgr\Impl\FactoryMgrImpl.pas',
  AppContextImpl in 'AppContext\Impl\AppContextImpl.pas',
  LogImpl in 'Log\Impl\LogImpl.pas',
  EDCryptImpl in 'EDCrypt\Impl\EDCryptImpl.pas',
  CfgImpl in 'Cfg\Impl\CfgImpl.pas',
  WebCfgImpl in 'Cfg\WebCfg\Impl\WebCfgImpl.pas',
  CacheCfgImpl in 'Cfg\CacheCfg\Impl\CacheCfgImpl.pas',
  ServerCfgImpl in 'Cfg\ServerCfg\Impl\ServerCfgImpl.pas',
  SysCfgImpl in 'Cfg\SysCfg\Impl\SysCfgImpl.pas',
  WebInfoImpl in 'Cfg\Info\Impl\WebInfoImpl.pas',
  UserInfoImpl in 'Cfg\Info\Impl\UserInfoImpl.pas',
  ProxyInfoImpl in 'Cfg\Info\Impl\ProxyInfoImpl.pas',
  SystemInfoImpl in 'Cfg\Info\Impl\SystemInfoImpl.pas',
  ServerInfoImpl in 'Cfg\Info\Impl\ServerInfoImpl.pas',
  CompanyInfoImpl in 'Cfg\Info\Impl\CompanyInfoImpl.pas',
  CrtExport in 'Cfg\CrtExport.pas',
  HardWareUtil in 'Cfg\HardWareUtil.pas',
  AbstractLogin in 'Login\AbstractLogin.pas',
  UFXAccountLogin in 'Login\UFXAccountLogin.pas',
  GilAccountLogin in 'Login\GilAccountLogin.pas',
  PBoxAccountLogin in 'Login\PBoxAccountLogin.pas',
  LoginMainUI in 'Login\UI\LoginMainUI.pas' {LoginMainUI},
  LoginBindUI in 'Login\UI\LoginBindUI.pas' {LoginBindUI},
  LoginSettingUI in 'Login\UI\LoginSettingUI.pas' {LoginSettingUI},
  LoginImpl in 'Login\Impl\LoginImpl.pas',
  LoginPlugInImpl in 'WDPlugIn\Impl\LoginPlugInImpl.pas',
  ResourceCfgImpl in 'Resource\Impl\ResourceCfgImpl.pas',
  ResourceSkinImpl in 'Resource\Impl\ResourceSkinImpl.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  //  Application.ShowMainForm := False;
  Application.Run;
end.
