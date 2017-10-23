unit ProxyInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Proxy Info Interface
// Author£º      lksoulman
// Date£º        2017-7-21
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  // Proxy Info Interface
  IProxyInfo = Interface(IInterface)
    ['{32F1B998-39F2-4411-87B3-763A1EE39A9A}']
    // Init
    procedure Initialize(AContext: IInterface);
    // UnInit
    procedure UnInitialize;
    // Save Cache
    procedure SaveCache;
    // Load Cache
    procedure LoadCache;
    // Restore Default
    procedure RestoreDefault;
    // Read File
    procedure Read(AFile: TIniFile);
    // Get Proxy
    function GetProxy: PProxy;
    // Get Is Use Proxy
    function GetIsUseProxy: boolean;
    // Set Is Use Proxy
    procedure SetIsUseProxy(AIsUseProxy: Boolean);
  end;

implementation

end.
