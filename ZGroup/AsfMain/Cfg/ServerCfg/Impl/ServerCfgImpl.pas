unit ServerCfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Server Config Interface Implementation
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
  ServerCfg,
  ServerInfo,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Server Config Interface
  TServerCfgImpl = class(TAutoInterfacedObject, IServerCfg)
  private
    // Application Context
    FAppContext: IAppContext;
    // Server Info Dictionary
    FServerInfoDic: TDictionary<string, IServerInfo>;
    { Indicators }

    // Basic
    FBasicServerInfo: IServerInfo;
    // Asset
    FAssetServerInfo: IServerInfo;

    { HQ }

    // DDE
    FDDEServerInfo: IServerInfo;
    // USA
    FUSAServerInfo: IServerInfo;
    // Future
    FFutureServerInfo: IServerInfo;
    // HongKong Real
    FHKRealServerInfo: IServerInfo;
    // LevelI
    FLevelIServerInfo: IServerInfo;
    // Level2
    FLevel2ServerInfo: IServerInfo;
    // Hongkong Delay
    FHKDelayServerInfo: IServerInfo;

    { web }

    // FOF
    FFOFServerInfo: IServerInfo;
    // F10
    FF10ServerInfo: IServerInfo;
    // News
    FNewsServerInfo: IServerInfo;
    // News File
    FNewsFileServerInfo: IServerInfo;
    // Asset Web
    FAssetWebServerInfo: IServerInfo;
    // Simulation
    FSimulationServerInfo: IServerInfo;
    // ZhongKe
    FZhongKeServerInfo: IServerInfo;
    // Inter-Bank Price
    FInterBankPriceServerInfo: IServerInfo;
    // Fly Quantification
    FFlyQuantificationServerInfo: IServerInfo;

    { Update }

    // Update
    FUpgradeServerInfo: IServerInfo;

    { HS }

    // Action Analysis
    FActionAnalysisServerInfo: IServerInfo;
  protected
    // Init Server Info
    procedure DoInitServerInfos;
    // Init Server Info Dictionary
    procedure DoInitServerInfoDic;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IServerCfg }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;

    { Indicators }

    // Basic Server Info
    function GetBasicServerInfo: IServerInfo;
    // Asset Server Info
    function GetAssetServerInfo: IServerInfo;

    { HQ }

    // DDE
    function GetDDEServerInfo: IServerInfo;
    // USA
    function GetUSAServerInfo: IServerInfo;
    // Future
    function GetFutureServerInfo: IServerInfo;
    // HongKong Real
    function GetHKRealServerInfo: IServerInfo;
    // LevelI
    function GetLevelIServerInfo: IServerInfo;
    // LevelI
    function GetLevel2ServerInfo: IServerInfo;
    // HongKong Delay
    function GetHKDelayServerInfo: IServerInfo;

    { web}

    // FOF
    function GetFOFServerInfo: IServerInfo;
    // F10
    function GetF10ServerInfo: IServerInfo;
    // News
    function GetNewsServerInfo: IServerInfo;
    // ZhongKe
    function GetZhongKeServerInfo: IServerInfo;
    // News File
    function GetNewsFileServerInfo: IServerInfo;
    // Asset Web
    function GetAssetWebServerInfo: IServerInfo;
    // Simulation
    function GetSimulationServerInfo: IServerInfo;
    // Inter-Bank Price
    function GetInterBankPriceServerInfo: IServerInfo;
    // Fly Quantification
    function GetFlyQuantificationServerInfo: IServerInfo;

    { Update}

    // Update
    function GetUpgradeServerInfo: IServerInfo;

    { hundsun}

    // Action Analysis
    function GetActionAnalysisServerInfo: IServerInfo;

    // Get Server IP
    function GetServerUrl(AServerName: WideString): WideString;
    // Get Server Multi IP
    function GetServerUrls(AServerName: WideString): WideString;
  end;

implementation

uses
  Cfg,
  IniFiles,
  LogLevel,
  ServerInfoImpl;

{ TServerCfgImpl }

constructor TServerCfgImpl.Create;
begin
  inherited;
  FServerInfoDic := TDictionary<string, IServerInfo>.Create(25);

  { Indicators }

  FBasicServerInfo := TServerInfoImpl.Create('Basic') as IServerInfo;
  FAssetServerInfo := TServerInfoImpl.Create('Asset') as IServerInfo;

  { HQ }

  FDDEServerInfo := TServerInfoImpl.Create('DDE') as IServerInfo;
  FUSAServerInfo := TServerInfoImpl.Create('USStock') as IServerInfo;
  FFutureServerInfo := TServerInfoImpl.Create('Future') as IServerInfo;
  FHKRealServerInfo := TServerInfoImpl.Create('HKReal') as IServerInfo;
  FLevelIServerInfo := TServerInfoImpl.Create('LevelI') as IServerInfo;
  FLevel2ServerInfo := TServerInfoImpl.Create('Level2') as IServerInfo;
  FHKDelayServerInfo := TServerInfoImpl.Create('HKDelay') as IServerInfo;

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




  { Update }

  FUpgradeServerInfo := TServerInfoImpl.Create('Upgrade') as IServerInfo;

  { HS }

  FActionAnalysisServerInfo := TServerInfoImpl.Create('ActionAnalysis') as IServerInfo;
end;

destructor TServerCfgImpl.Destroy;
begin
  { Indicators }

  FBasicServerInfo := nil;
  FAssetServerInfo := nil;

  { HQ }

  FDDEServerInfo := nil;
  FUSAServerInfo := nil;
  FFutureServerInfo := nil;
  FHKRealServerInfo := nil;
  FLevelIServerInfo := nil;
  FLevel2ServerInfo := nil;
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

  FUpgradeServerInfo := nil;

  { HS }

  FActionAnalysisServerInfo := nil;

  FServerInfoDic.Free;
  inherited;
end;

procedure TServerCfgImpl.DoInitServerInfos;
var
  LFile: string;
  LIniFile: TIniFile;
begin
  LFile := FAppContext.GetCfg.GetCfgPath + 'CfgServers.dat';
  if FileExists(LFile) then begin
    LIniFile := TIniFile.Create(LFile);
    try
      { Indicators }

      FBasicServerInfo.LoadFile(LIniFile);
      FAssetServerInfo.LoadFile(LIniFile);

      { HQ }

      FDDEServerInfo.LoadFile(LIniFile);
      FUSAServerInfo.LoadFile(LIniFile);
      FFutureServerInfo.LoadFile(LIniFile);
      FHKRealServerInfo.LoadFile(LIniFile);
      FLevelIServerInfo.LoadFile(LIniFile);
      FLevel2ServerInfo.LoadFile(LIniFile);
      FHKDelayServerInfo.LoadFile(LIniFile);

      {web}

      FFOFServerInfo.LoadFile(LIniFile);
      FF10ServerInfo.LoadFile(LIniFile);
      FNewsServerInfo.LoadFile(LIniFile);
      FNewsFileServerInfo.LoadFile(LIniFile);
      FAssetWebServerInfo.LoadFile(LIniFile);
      FSimulationServerInfo.LoadFile(LIniFile);
      FInterBankPriceServerInfo.LoadFile(LIniFile);
      FFlyQuantificationServerInfo.LoadFile(LIniFile);

      { Update }

      FUpgradeServerInfo.LoadFile(LIniFile);

      { HS }

      FActionAnalysisServerInfo.LoadFile(LIniFile);
    finally
      LIniFile.Free;
    end;
  end else begin
    FAppContext.SysLog(llERROR, Format('[TServerCfgImpl][DoInitServerInfos] Load file %s is not exist.', [LFile]));
  end;
end;

procedure TServerCfgImpl.DoInitServerInfoDic;
begin
  { Indicators }

  FServerInfoDic.AddOrSetValue(FBasicServerInfo.GetServerName, FBasicServerInfo);
  FServerInfoDic.AddOrSetValue(FAssetServerInfo.GetServerName, FAssetServerInfo);

  { HQ }

  FServerInfoDic.AddOrSetValue(FDDEServerInfo.GetServerName, FDDEServerInfo);
  FServerInfoDic.AddOrSetValue(FUSAServerInfo.GetServerName, FUSAServerInfo);
  FServerInfoDic.AddOrSetValue(FFutureServerInfo.GetServerName, FFutureServerInfo);
  FServerInfoDic.AddOrSetValue(FHKRealServerInfo.GetServerName, FHKRealServerInfo);
  FServerInfoDic.AddOrSetValue(FLevelIServerInfo.GetServerName, FLevelIServerInfo);
  FServerInfoDic.AddOrSetValue(FLevel2ServerInfo.GetServerName, FLevel2ServerInfo);
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

  FServerInfoDic.AddOrSetValue(FUpgradeServerInfo.GetServerName, FUpgradeServerInfo);

  { HS }

  FServerInfoDic.AddOrSetValue(FActionAnalysisServerInfo.GetServerName, FActionAnalysisServerInfo);
end;

procedure TServerCfgImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  DoInitServerInfos;
  DoInitServerInfoDic;
end;

procedure TServerCfgImpl.UnInitialize;
begin

  FAppContext := nil;
end;

function TServerCfgImpl.GetBasicServerInfo: IServerInfo;
begin
  Result := FBasicServerInfo;
end;

function TServerCfgImpl.GetAssetServerInfo: IServerInfo;
begin
  Result := FAssetServerInfo;
end;

function TServerCfgImpl.GetDDEServerInfo: IServerInfo;
begin
  Result := FDDEServerInfo;
end;

function TServerCfgImpl.GetUSAServerInfo: IServerInfo;
begin
  Result := FUSAServerInfo;
end;

function TServerCfgImpl.GetFutureServerInfo: IServerInfo;
begin
  Result := FFutureServerInfo;
end;

function TServerCfgImpl.GetHKRealServerInfo: IServerInfo;
begin
  Result := FHKRealServerInfo;
end;

function TServerCfgImpl.GetLevelIServerInfo: IServerInfo;
begin
  Result := FLevelIServerInfo;
end;

function TServerCfgImpl.GetLevel2ServerInfo: IServerInfo;
begin
  Result := FLevel2ServerInfo;
end;

function TServerCfgImpl.GetHKDelayServerInfo: IServerInfo;
begin
  Result := FHKDelayServerInfo;
end;

function TServerCfgImpl.GetFOFServerInfo: IServerInfo;
begin
  Result := FFOFServerInfo;
end;

function TServerCfgImpl.GetF10ServerInfo: IServerInfo;
begin
  Result := FF10ServerInfo;
end;

function TServerCfgImpl.GetNewsServerInfo: IServerInfo;
begin
  Result := FNewsServerInfo;
end;

function TServerCfgImpl.GetZhongKeServerInfo: IServerInfo;
begin
  Result := FZhongKeServerInfo;
end;

function TServerCfgImpl.GetNewsFileServerInfo: IServerInfo;
begin
  Result := FNewsFileServerInfo;
end;

function TServerCfgImpl.GetAssetWebServerInfo: IServerInfo;
begin
  Result := FNewsFileServerInfo;
end;

function TServerCfgImpl.GetSimulationServerInfo: IServerInfo;
begin
  Result := FNewsFileServerInfo;
end;

function TServerCfgImpl.GetInterBankPriceServerInfo: IServerInfo;
begin
  Result := FInterBankPriceServerInfo;
end;

function TServerCfgImpl.GetFlyQuantificationServerInfo: IServerInfo;
begin
  Result := FFlyQuantificationServerInfo;
end;

function TServerCfgImpl.GetUpgradeServerInfo: IServerInfo;
begin
  Result := FUpgradeServerInfo;
end;

function TServerCfgImpl.GetActionAnalysisServerInfo: IServerInfo;
begin
  Result := FActionAnalysisServerInfo;
end;

function TServerCfgImpl.GetServerUrl(AServerName: WideString): WideString;
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

function TServerCfgImpl.GetServerUrls(AServerName: WideString): WideString;
var
  LServerInfo: IServerInfo;
begin
  if FServerInfoDic.TryGetValue(AServerName, LServerInfo)
    and (LServerInfo <> nil) then begin
    Result := LServerInfo.GetServerUrls;
  end else begin
    Result := '';
  end;
end;

end.
