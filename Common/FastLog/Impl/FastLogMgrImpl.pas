unit FastLogMgrImpl;

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
  FastLog,
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  FastLogMgr,
  FastLogLevel,
  ExecutorThread,
  CommonRefCounter;

type

  TFastLogMgrImpl = class(TAutoInterfacedObject, IFastLogMgr)
  private
    // 是不是初始化
    FIsInit: Boolean;
    // 路径
    FAppPath: string;
    // 输出日志级别
    FLevel: TLogLevel;
    // 行情错误日志
    FHQLog: TFastLog;
    // 网页错误日志
    FWebLog: TFastLog;
    // 系统应用错误日志
    FAppLog: TFastLog;
    // 指标错误日志
    FIndicatorLog: TFastLog;
    // 监控日志输出
    FLogOutputThread: TExecutorThread;
  protected
    // 日志输出监控执行方法
    procedure DoOutputFileThreadExecute(AObject: TObject);
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IFastLOG }

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
    procedure AppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // 指标日志输出
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

var
  G_FastLogMgr: IFastLogMgr;

implementation

{ TFastLogMgrImpl }

constructor TFastLogMgrImpl.Create;
begin
  inherited Create;
  FIsInit := False;
{$IFDEF DEBUG}
  FLevel := llDEBUG;
{$ELSE}
  FLevel := llWARN;
{$ENDIF}
  FAppPath := ExtractFilePath(ParamStr(0));
  FAppPath := ExpandFileName(FAppPath + '..\');
  FHQLog := TFastLog.Create;
  FWebLog := TFastLog.Create;
  FAppLog := TFastLog.Create;
  FIndicatorLog := TFastLog.Create;
  FLogOutputThread := TExecutorThread.Create;
  FLogOutputThread.ThreadMethod := DoOutputFileThreadExecute;
end;

destructor TFastLogMgrImpl.Destroy;
begin
  FIndicatorLog.Free;
  FAppLog.Free;
  FWebLog.Free;
  FHQLog.Free;
  inherited;
end;

procedure TFastLogMgrImpl.Initialize;
begin
  if not FIsInit then begin
    FHQLog.SetOutputPath(FAppPath + 'Log\HQ\');
    FWebLog.SetOutputPath(FAppPath + 'Log\Web\');
    FAppLog.SetOutputPath(FAppPath + 'Log\App\');
    FIndicatorLog.SetOutputPath(FAppPath + 'Log\Indicator\');
    FHQLog.Initialize;
    FWebLog.Initialize;
    FAppLog.Initialize;
    FIndicatorLog.Initialize;
    FLogOutputThread.Start;
    FIsInit := True;

    HQLog(FLevel, 'FastLog Start');
    AppLog(FLevel, 'FastLog Start');
    WebLog(FLevel, 'FastLog Start');
    IndicatorLog(FLevel, 'FastLog Start');
    HQLog(llSLOW, 'FastLog Start');
    AppLog(llSLOW, 'FastLog Start');
    WebLog(llSLOW, 'FastLog Start');
    IndicatorLog(llSLOW, 'FastLog Start');
  end;
end;

procedure TFastLogMgrImpl.UnInitialize;
begin
  if FIsInit then begin
    FLogOutputThread.ShutDown;
    HQLog(FLevel, 'FastLog End');
    AppLog(FLevel, 'FastLog End');
    WebLog(FLevel, 'FastLog End');
    IndicatorLog(FLevel, 'FastLog End');
    HQLog(llSLOW, 'FastLog End');
    AppLog(llSLOW, 'FastLog End');
    WebLog(llSLOW, 'FastLog End');
    IndicatorLog(llSLOW, 'FastLog End');
    FIsInit := False;
  end;
end;

procedure TFastLogMgrImpl.ForceWriteDisk;
begin
  FHQLog.SafeOutputFile;
  FWebLog.SafeOutputFile;
  FAppLog.SafeOutputFile;
  FIndicatorLog.SafeOutputFile;
end;

procedure TFastLogMgrImpl.SetLogLevel(ALevel: TLogLevel);
begin
  FLevel := ALevel;
  FHQLog.SetLogLevel(ALevel);
  FWebLog.SetLogLevel(ALevel);
  FAppLog.SetLogLevel(ALevel);
  FIndicatorLog.SetLogLevel(ALevel);
end;

procedure TFastLogMgrImpl.HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FHQLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FHQLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TFastLogMgrImpl.WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FWebLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FWebLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TFastLogMgrImpl.AppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FAppLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FAppLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TFastLogMgrImpl.IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FIndicatorLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FIndicatorLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TFastLogMgrImpl.DoOutputFileThreadExecute(AObject: TObject);
begin
  while not FLogOutputThread.IsTerminated do begin
    FHQLog.SafeOutputFile;
    FWebLog.SafeOutputFile;
    FAppLog.SafeOutputFile;
    FIndicatorLog.SafeOutputFile;
    Sleep(500);
  end;
end;

initialization

  if G_FastLogMgr = nil then begin
    G_FastLogMgr := TFastLogMgrImpl.Create as IFastLogMgr;
    G_FastLogMgr.Initialize;
  end;

finalization

  if G_FastLogMgr <> nil then begin
    G_FastLogMgr.UnInitialize;
    G_FastLogMgr.ForceWriteDisk;
    G_FastLogMgr := nil;
  end;

end.
