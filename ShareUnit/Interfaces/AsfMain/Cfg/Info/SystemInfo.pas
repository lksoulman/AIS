unit SystemInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º System Info Interface
// Author£º      lksoulman
// Date£º        2017-7-21
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  LogLevel,
  LanguageType;

type

  // System Info
  TSystemInfo = packed record
    FLogLevel: TLogLevel;                 // LogLevel
    FReLoginTime: Integer;                // ReLogin Time
    FFontRatio: WideString;               // FontRatio
    FSkinStyle: WideString;               // SkinStyle
    FMacAddress: WideString;              // Mac Address
    FHardDiskId: WideString;              // HardDiskId
    FHardDiskIdMD5: WideString;           // HardDiskId MD5
    FLanguageType: TLanguageType;         // Language Type
  end;

  // System Info Pointer
  PSystemInfo = ^TSystemInfo;

  // SysCfg Info Interface
  ISystemInfo = Interface(IInterface)
    ['{694C57FE-D4B2-416B-B33C-16CD955B4113}']
    // Init
    procedure Initialize(AContext: IInterface);
    // UnInit
    procedure UnInitialize;
    // Read
    procedure Read(AFile: TIniFile);
    // Save Cache
    procedure SaveCache;
    // Load Cache
    procedure LoadCache;
    // Get System Info
    function GetSystemInfo: PSystemInfo;
  end;

implementation

end.
