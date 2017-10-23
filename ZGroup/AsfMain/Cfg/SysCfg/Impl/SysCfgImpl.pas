unit SysCfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º System Cfg Interface Implementation
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  SysCfg,
  Windows,
  Classes,
  SysUtils,
  UserInfo,
  ProxyInfo,
  SystemInfo,
  AppContext,
  CompanyInfo,
  CommonRefCounter;

type

  // System Cfg Interface Implementation
  TSysCfgImpl = class(TAutoInterfacedObject, ISysCfg)
  private
    // User Info
    FUserInfo: IUserInfo;
    // Proxy Info
    FProxyInfo: IProxyInfo;
    // System Config
    FSystemInfo: ISystemInfo;
    // Company Info
    FCompanyInfo: ICompanyInfo;
    // Application Context Interface
    FAppContext: IAppContext;
  protected
    // Init Info
    procedure DoInitInfos;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

     { ISysCfg }

    // Init
    procedure Initialize(AContext: IInterface);
    // Un Init
    procedure UnInitialize;
    // Get User Info
    function GetUserInfo: IUserInfo;
    // Get Proxy Info
    function GetProxyInfo: IProxyInfo;
    // Get Syscfg Info
    function GetSystemInfo: ISystemInfo;
    // Get Company Info
    function GetCompanyInfo: ICompanyInfo;
  end;


implementation

uses
  Cfg,
  LogLevel,
  IniFiles,
  UserInfoImpl,
  ProxyInfoImpl,
  SystemInfoImpl,
  CompanyInfoImpl;

{ TSysCfgImpl }

constructor TSysCfgImpl.Create;
begin
  inherited;
  FUserInfo := TUserInfoImpl.Create as IUserInfo;
  FProxyInfo := TProxyInfoImpl.Create as IProxyInfo;
  FSystemInfo := TSystemInfoImpl.Create as ISystemInfo;
  FCompanyInfo := TCompanyInfoImpl.Create as ICompanyInfo;
end;

destructor TSysCfgImpl.Destroy;
begin
  FUserInfo := nil;
  FProxyInfo := nil;
  FSystemInfo := nil;
  FCompanyInfo := nil;
  inherited;
end;

procedure TSysCfgImpl.DoInitInfos;
var
  LFile: string;
  LIniFile: TIniFile;
begin
  LFile := FAppContext.GetCfg.GetCfgPath + 'CfgSys.ini';
  if FileExists(LFile) then begin
    LIniFile := TIniFile.Create(LFile);
    try
      FUserInfo.Read(LIniFile);
      FProxyInfo.Read(LIniFile);
      FSystemInfo.Read(LIniFile);
      FCompanyInfo.Read(LIniFile);
    finally
      LIniFile.Free;
    end;
  end else begin
    FAppContext.SysLog(llERROR, Format('[TSysCfgImpl][DoInitInfos] Load file %s is not exist.', [LFile]));
  end;
end;

procedure TSysCfgImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  DoInitInfos;
  FUserInfo.Initialize(AContext);
  FProxyInfo.Initialize(AContext);
  FSystemInfo.Initialize(AContext);
  FCompanyInfo.Initialize(AContext);
  FUserInfo.LoadCache;
  FProxyInfo.LoadCache;
  FSystemInfo.LoadCache;
  FCompanyInfo.LoadCache;
end;

procedure TSysCfgImpl.UnInitialize;
begin
  FCompanyInfo.UnInitialize;
  FSystemInfo.UnInitialize;
  FProxyInfo.UnInitialize;
  FUserInfo.UnInitialize;
  FAppContext := nil;
end;

function TSysCfgImpl.GetUserInfo: IUserInfo;
begin
  Result := FUserInfo;
end;

function TSysCfgImpl.GetProxyInfo: IProxyInfo;
begin
  Result := FProxyInfo;
end;

function TSysCfgImpl.GetSystemInfo: ISystemInfo;
begin
  Result := FSystemInfo;
end;

function TSysCfgImpl.GetCompanyInfo: ICompanyInfo;
begin
  Result := FCompanyInfo;
end;

end.
