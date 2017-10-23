unit CfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Config Interface Implementation
// Author£º      lksoulman
// Date£º        2017-7-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Cfg,
  WebCfg,
  SysCfg,
  Windows,
  Classes,
  SysUtils,
  CacheCfg,
  ServerCfg,
  CommonRefCounter;

type

  // Config Interface Implementation
  TCfgImpl = class(TAutoInterfacedObject, ICfg)
  private
    // App Path
    FAppPath: string;
    // System Cfg
    FSysCfg: ISysCfg;
    // Web Cfg
    FWebCfg: IWebCfg;
    // Server Cfg
    FServerCfg: IServerCfg;
    // System Cache Cfg
    FSysCacheCfg: ICacheCfg;
    // User Cache Cfg
    FUserCacheCfg: ICacheCfg;
//    // Application Context
//    FAppContext: IInterface;
  protected
    // Init System Dirs
    procedure DoInitSysDirs;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ICfg }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Force User Dirs
    function InitUserDirs: Boolean;
    // Get System Cfg
    function GetSysCfg: ISysCfg;
    // Get Web Cfg
    function GetWebCfg: IWebCfg;
    // Get Server Cfg
    function GetServerCfg: IServerCfg;
    // Get Sys Cache Cfg
    function GetSysCacheCfg: ICacheCfg;
    // Get User Cache Cfg
    function GetUserCacheCfg: ICacheCfg;
    // Get Application Path
    function GetAppPath: WideString;
    // Get Bin Path
    function GetBinPath: WideString;
    // Get Cfg Path
    function GetCfgPath: WideString;
    // Get Log Path
    function GetLogPath: WideString;
    // Get Skin Path
    function GetSkinPath: WideString;
    // Get User Path
    function GetUserPath: WideString;
    // Get Users Path
    function GetUsersPath: WideString;
    // Get User Cfg Path
    function GetUserCfgPath: WideString;
    // Get Cache Path
    function GetCachePath: WideString;
    // Get HQ Cache Path
    function GetHQCachePath: WideString;
    // Get Base Cache Path
    function GetBaseCachePath: WideString;
    // Get User Cache Path
    function GetUserCachePath: WideString;
    // Get System Update Path
    function GetSysUpdatePath: WideString;
  end;

implementation

uses
  Json,
  Utils,
  IniFiles,
  SysCfgImpl,
  WebCfgImpl,
  CacheCfgImpl,
  ServerCfgImpl;

{ TCfgImpl }

constructor TCfgImpl.Create;
begin
  inherited;
  FAppPath := ExtractFilePath(ParamStr(0));
  FAppPath := ExpandFileName(FAppPath + '..\');
  FSysCfg := TSysCfgImpl.Create as ISysCfg;
  FWebCfg := TWebCfgImpl.Create as IWebCfg;
  FServerCfg := TServerCfgImpl.Create as IServerCfg;
  FSysCacheCfg := TCacheCfgImpl.Create as ICacheCfg;
  FUserCacheCfg := TCacheCfgImpl.Create as ICacheCfg;
end;

destructor TCfgImpl.Destroy;
begin
  FSysCfg := nil;
  FWebCfg := nil;
  FServerCfg := nil;
  FSysCacheCfg := nil;
  FUserCacheCfg := nil;
  inherited;
end;

procedure TCfgImpl.Initialize(AContext: IInterface);
begin
//  FAppContext := AContext;
  DoInitSysDirs;
  FSysCacheCfg.SetCachePath(GetCachePath);
  FSysCacheCfg.Initialize(AContext);
  FSysCfg.Initialize(AContext);
  FWebCfg.Initialize(AContext);
  FServerCfg.Initialize(AContext);
//  FUserCacheCfg.SetCachePath();
  FUserCacheCfg.Initialize(AContext);
end;

procedure TCfgImpl.UnInitialize;
begin
  FUserCacheCfg.UnInitialize;
  FServerCfg.UnInitialize;
  FWebCfg.UnInitialize;
  FSysCfg.UnInitialize;
  FSysCacheCfg.UnInitialize;
//  FAppContext := nil;
end;

procedure TCfgImpl.DoInitSysDirs;
begin
  if not DirectoryExists(GetLogPath) then begin
    ForceDirectories(GetLogPath);
  end;

  if not DirectoryExists(GetCachePath) then begin
    ForceDirectories(GetCachePath);
  end;

  if not DirectoryExists(GetHQCachePath) then begin
    ForceDirectories(GetHQCachePath);
  end;

  if not DirectoryExists(GetBaseCachePath) then begin
    ForceDirectories(GetBaseCachePath);
  end;

  if not DirectoryExists(GetUsersPath) then begin
    ForceDirectories(GetUsersPath);
  end;
end;

function TCfgImpl.InitUserDirs: Boolean;
begin
  Result := True;
  if not DirectoryExists(GetUserPath) then begin
    ForceDirectories(GetUserPath);
  end;

  if not DirectoryExists(GetUserCfgPath) then begin
    ForceDirectories(GetUserCfgPath);
  end;

  if not DirectoryExists(GetUserCachePath) then begin
    ForceDirectories(GetUserCachePath);
  end;

  FUserCacheCfg.SetCachePath(GetUserCachePath);
  FUserCacheCfg.LoadCacheCfg;
end;

function TCfgImpl.GetSysCfg: ISysCfg;
begin
  Result := FSysCfg;
end;

function TCfgImpl.GetWebCfg: IWebCfg;
begin
  Result := FWebCfg;
end;

function TCfgImpl.GetServerCfg: IServerCfg;
begin
  Result := FServerCfg;
end;

function TCfgImpl.GetSysCacheCfg: ICacheCfg;
begin
  Result := FSysCacheCfg;
end;

function TCfgImpl.GetUserCacheCfg: ICacheCfg;
begin
  Result := FUserCacheCfg;
end;

function TCfgImpl.GetAppPath: WideString;
begin
  Result := FAppPath;
end;

function TCfgImpl.GetBinPath: WideString;
begin
  Result := FAppPath + 'Bin\';
end;

function TCfgImpl.GetCfgPath: WideString;
begin
  Result := FAppPath + 'Cfg\';
end;

function TCfgImpl.GetLogPath: WideString;
begin
  Result := FAppPath + 'Log\';
end;

function TCfgImpl.GetSkinPath: WideString;
begin
  Result := FAppPath + 'Skin\';
end;

function TCfgImpl.GetUserPath: WideString;
begin
  if FSysCfg.GetUserInfo.GetUFXAccountInfo^.FUserName <> '' then begin
    Result := GetUsersPath + FSysCfg.GetUserInfo.GetUFXAccountInfo^.FUserName + '\';
  end else begin
    Result := '';
  end;
end;

function TCfgImpl.GetUsersPath: WideString;
begin
  Result := FAppPath + 'Users\';
end;

function TCfgImpl.GetCachePath: WideString;
begin
  Result := FAppPath + 'Cache\';
end;

function TCfgImpl.GetHQCachePath: WideString;
begin
  Result := FAppPath + 'Cache\HQ\';
end;

function TCfgImpl.GetBaseCachePath: WideString;
begin
  Result := FAppPath + 'Cache\Base\';
end;

function TCfgImpl.GetSysUpdatePath : WideString;
begin
  Result := FAppPath + 'Update\';
end;

function TCfgImpl.GetUserCfgPath: WideString;
begin
  Result := GetUserPath;
  if Result <> '' then begin
    Result := Result + 'Cfg\';
  end;
end;

function TCfgImpl.GetUserCachePath: WideString;
begin
  Result := GetUserPath;
  if Result <> '' then begin
    Result := Result + 'Cache\';
  end;
end;

end.
