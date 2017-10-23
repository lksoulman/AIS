unit LogLevel;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Log Level
// Author：      lksoulman
// Date：        2017-7-1
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Log Level 
  TLogLevel = (llDEBUG,               // Debug 
               llINFO,                // Info
               llWARN,                // Warn
               llERROR,               // Error
               llFATAL,               // Fatal
               llSLOW                 // Slow
               );

  // 日志类型数组
  TLogLevelArray = array [TLogLevel] of string;

implementation

end.
