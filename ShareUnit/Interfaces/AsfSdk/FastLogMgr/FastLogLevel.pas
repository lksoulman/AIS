unit FastLogLevel;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
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

  // 日志类型
  TLogLevel = (llDEBUG,               // Debug 输出信息
               llINFO,                // 信息提示
               llWARN,                // 警告
               llERROR,               // 错误
               llFATAL,               // 致命
               llSLOW                 // 慢
               );

  // 日志类型数组
  TLogLevelArray = array [TLogLevel] of string;

implementation

end.
