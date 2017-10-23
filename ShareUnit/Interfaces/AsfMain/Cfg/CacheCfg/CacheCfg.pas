unit CacheCfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Cache Cfg Interface
// Author£º      lksoulman
// Date£º        2017-7-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Cache Cfg Interface
  ICacheCfg = Interface(IInterface)
    ['{865B342F-C51B-40FA-82D0-3DEF0D058E73}']
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Save Cache
    procedure SaveCache; safecall;
    // Load Cache Cfg
    procedure LoadCacheCfg; safecall;
    // Set Cfg Cache Path
    procedure SetCachePath(APath: WideString); safecall;
    // Get Value
    function GetValue(AKey: WideString): WideString; safecall;
    // Set Value
    function SetValue(AKey, AValue: WideString): boolean; safecall;
  end;

implementation

end.
