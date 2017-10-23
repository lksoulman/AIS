unit ServerCfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Server Config Interface
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
  ServerInfo;

type

  // Server Config Interface
  IServerCfg = interface(IInterface)
    ['{D54E91B2-AC02-431F-845F-E6AAD25615D5}']
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

    // Upgrade
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

end.
