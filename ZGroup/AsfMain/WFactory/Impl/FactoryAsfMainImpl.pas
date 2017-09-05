unit FactoryAsfMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º    A dynamic library has only one implementation factory,
//               A factory is a singleton.
//               AsfMain project factory implementation.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInConst,
  WFactoryImpl;

type

  // AsfMain project factory implementation
  TFactoryAsfMainImpl = class(TWFactoryImpl)
  private
  protected
    // Register PlugIns
    procedure DoRegisterPlugIns; override;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

var
  // Global factory
  G_WFactory: IInterface;

implementation

//uses
//  Config,
//  ConfigPlugInImpl,
//  LoginMgr,
//  LoginMgrPlugInImpl,
//  BehaviorMgr,
//  BehaviorMgrPlugInImpl,
//  SecurityMgr,
//  SecurityMgrPlugInImpl,
//  ServiceBase,
//  ServiceBasePlugInImpl,
//  ServiceAsset,
//  ServiceAssetPlugInImpl,
//  CacheBaseData,
//  CacheBaseDataPlugInImpl,
//  CacheUserData,
//  CacheUserDataPlugInImpl,
//  PermissionMgr,
//  PermissionMgrPlugInImpl;

{ TFactoryAsfMainImpl }

constructor TFactoryAsfMainImpl.Create;
begin
  inherited;

end;

destructor TFactoryAsfMainImpl.Destroy;
begin

  inherited;
end;

procedure TFactoryAsfMainImpl.DoRegisterPlugIns;
begin
//  DoRegisterPlugIn(GUIDToString(IConfig), PLUGIN_ID_CONFIG, TConfigPlugInImpl);
//
//  DoRegisterPlugIn(GUIDToString(ILoginMgr), PLUGIN_ID_LOGINMGR, TLoginMgrPlugInImpl);
//
//  DoRegisterPlugIn(GUIDToString(IBehaviorMgr), PLUGIN_ID_BEHAVIORMGR, TBehaviorMgrPlugInImpl);
//
//  DoRegisterPlugIn(GUIDToString(ISecurityMgr), PLUGIN_ID_SECURITYMGR, TSecurityMgrPlugInImpl);
//
//  DoRegisterPlugIn(GUIDToString(IServiceBase), PLUGIN_ID_SERVICEBASE, TServiceBasePlugInImpl);
//
//  DoRegisterPlugIn(GUIDToString(IServiceAsset), PLUGIN_ID_SERVICEASSET, TServiceAssetPlugInImpl);
//
//  DoRegisterPlugIn(GUIDToString(ICacheBaseData), PLUGIN_ID_CACHEBASEDATA, TCacheBaseDataPlugInImpl);
//
//  DoRegisterPlugIn(GUIDToString(ICacheUserData), PLUGIN_ID_CACHEUSERDATA, TCacheUserDataPlugInImpl);
//
//  DoRegisterPlugIn(GUIDToString(IPermissionMgr), PLUGIN_ID_PERMISSIONMGR, TPermissionMgrPlugInImpl);
end;

end.
