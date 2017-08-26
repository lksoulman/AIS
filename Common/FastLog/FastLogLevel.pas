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
  TArrayLogLevel = array [TLogLevel] of string;

  // 设置日志级别
  procedure AppSetLogLevel(ALevel: TLogLevel);
  // 行情日志输出
  procedure FastHQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  // 网页日志输出
  procedure FastWebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  // 应用系统日志输出
  procedure FastAppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
  // 指标日志输出
  procedure FastIndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);

implementation

uses
  FastLogMgr,
  FastLogMgrImpl;

procedure AppSetLogLevel(ALevel: TLogLevel);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.SetLogLevel(ALevel);
end;

procedure FastHQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.HQLog(ALevel, ALog, AUseTime);
end;

procedure FastWebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.WebLog(ALevel, ALog, AUseTime);
end;

procedure FastAppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.AppLog(ALevel, ALog, AUseTime);
end;

procedure FastIndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  if G_FastLogMgr = nil then Exit;

  G_FastLogMgr.IndicatorLog(ALevel, ALog, AUseTime);
end;

end.
