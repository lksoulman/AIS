unit Log;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Log Interface
// Author£º      lksoulman
// Date£º        2017-7-1
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LogLevel;

type

  // Log Interface
  ILog = Interface(IInterface)
    ['{7A0EBA9F-BD2C-4CB5-9090-1CC9D1229818}']
    // Init
    procedure Initialize; safecall;
    // Un Init
    procedure UnInitialize; safecall;
    // Force Write Disk
    procedure ForceWriteDisk; safecall;
    // Set Log Level
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // HQ Log
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Web Log
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Sys Log
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Indicator Log
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

end.

