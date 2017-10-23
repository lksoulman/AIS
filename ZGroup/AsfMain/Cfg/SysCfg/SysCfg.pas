unit SysCfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º System Cfg Interface
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  UserInfo,
  ProxyInfo,
  SystemInfo,
  CompanyInfo;

type

  // System Cfg Interface
  ISysCfg = interface(IInterface)
    ['{8C9E0C7A-9BD2-4592-A38C-E9E4F6ABAD97}']
    // Init
    procedure Initialize(AContext: IInterface);
    // Un Init
    procedure UnInitialize;
    // Get User Info
    function GetUserInfo: IUserInfo;
    // Get Proxy Info
    function GetProxyInfo: IProxyInfo;
    // Get System Info
    function GetSystemInfo: ISystemInfo;
    // Get Company Info
    function GetCompanyInfo: ICompanyInfo;
  end;

implementation

end.
