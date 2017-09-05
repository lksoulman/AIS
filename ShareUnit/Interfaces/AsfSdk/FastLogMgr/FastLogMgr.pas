unit FastLogMgr;

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
  SysUtils,
  FastLogLevel;

type

  IFastLogMgr = Interface(IInterface)
    ['{7A0EBA9F-BD2C-4CB5-9090-1CC9D1229818}']
    // 初始化服务
    procedure Initialize; safecall;
    // 卸载服务
    procedure UnInitialize; safecall;
    // 写一次
    procedure ForceWriteDisk; safecall;
    // 设置日志级别
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // 行情日志输出
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // 网页日志输出
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // 应用系统日志输出
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // 指标日志输出
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

end.

