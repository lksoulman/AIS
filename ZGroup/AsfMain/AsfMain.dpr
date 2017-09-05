program AsfMain;

uses
  Vcl.Forms,
  FactoryAsfMainImpl in 'WFactory\Impl\FactoryAsfMainImpl.pas',
  DynamicLib in 'WFactory\Mgr\DynamicLib.pas',
  FactoryMgr in 'WFactory\Mgr\FactoryMgr.pas',
  FactoryMgrImpl in 'WFactory\Mgr\Impl\FactoryMgrImpl.pas',
  Main in 'AIUI\Main.pas' {frmMain},
  LoginMainUI in 'Login\UI\LoginMainUI.pas' {LoginMainUI},
  LoginBindUI in 'Login\UI\LoginBindUI.pas' {LoginBindUI},
  LoginSettingUI in 'Login\UI\LoginSettingUI.pas' {LoginSettingUI},
  Login in 'Login\Login.pas',
  LoginUFXUser in 'Login\LoginUFXUser.pas',
  LoginGILUser in 'Login\LoginGILUser.pas',
  LoginPBOXUser in 'Login\LoginPBOXUser.pas',
  LoginMgrImpl in 'LoginMgr\Impl\LoginMgrImpl.pas',
  AppContextImpl in 'AppContext\Impl\AppContextImpl.pas',
  Service in 'Service\Service.pas',
  ServiceBase in 'Service\ServiceBase.pas',
  ServiceAsset in 'Service\ServiceAsset.pas',
  ServiceConst in 'Service\ServiceConst.pas',
  ServiceImpl in 'Service\Impl\ServiceImpl.pas',
  ServiceBaseImpl in 'Service\Impl\ServiceBaseImpl.pas',
  ServiceAssetImpl in 'Service\Impl\ServiceAssetImpl.pas',
  ConfigImpl in 'Config\Impl\ConfigImpl.pas',
  CfgCacheImpl in 'Config\CfgCache\Impl\CfgCacheImpl.pas',
  WebInfoImpl in 'Config\Info\Impl\WebInfoImpl.pas',
  UrlInfoImpl in 'Config\Info\Impl\UrlInfoImpl.pas',
  UserInfoImpl in 'Config\Info\Impl\UserInfoImpl.pas',
  ProxyInfoImpl in 'Config\Info\Impl\ProxyInfoImpl.pas',
  LoginInfoImpl in 'Config\Info\Impl\LoginInfoImpl.pas',
  SyscfgInfoImpl in 'Config\Info\Impl\SyscfgInfoImpl.pas',
  UpdateInfoImpl in 'Config\Info\Impl\UpdateInfoImpl.pas',
  FutureInfoImpl in 'Config\Info\Impl\FutureInfoImpl.pas',
  ServerInfoImpl in 'Config\Info\Impl\ServerInfoImpl.pas',
  CompanyInfoImpl in 'Config\Info\Impl\CompanyInfoImpl.pas',
  HqServerTypeInfoImpl in 'Config\Info\Impl\HqServerTypeInfoImpl.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.ShowMainForm := False;
  Application.Run;
end.
