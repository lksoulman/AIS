unit LogImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Log Interface Implementation
// Author£º      lksoulman
// Date£º        2017-7-1
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Log,
  FastLog,
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  CommonLock,
  ExecutorThread,
  CommonRefCounter;

type

  // Log Interface Implementation
  TLogImpl = class(TAutoInterfacedObject, ILog)
  private
    // Is Init
    FIsInit: Boolean;
    // Appliaction Path
    FAppPath: string;
    // Log Level
    FLevel: TLogLevel;
    // HQ Log
    FHQLog: TFastLog;
    // Web Log
    FWebLog: TFastLog;
    // System Log
    FSysLog: TFastLog;
    // Indicator Log
    FIndicatorLog: TFastLog;
    // Log Output Thread
    FLogOutputThread: TExecutorThread;
  protected
    // Output File Thread Execute
    procedure DoOutputFileThreadExecute(AObject: TObject);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ILog }

    // Init
    procedure Initialize; safecall;
    // UnInit
    procedure UnInitialize; safecall;
    // Force Write Disk
    procedure ForceWriteDisk; safecall;
    // Set Log Level
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // HQ Log
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Web Log
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // System Log
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Indicator Log
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

uses
  Vcl.Forms;

{ TLogImpl }

constructor TLogImpl.Create;
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
  FSysLog := TFastLog.Create;
  FIndicatorLog := TFastLog.Create;
  FLogOutputThread := TExecutorThread.Create;
  FLogOutputThread.ThreadMethod := DoOutputFileThreadExecute;
end;

destructor TLogImpl.Destroy;
begin
  FIndicatorLog.Free;
  FSysLog.Free;
  FWebLog.Free;
  FHQLog.Free;
  inherited;
end;

procedure TLogImpl.Initialize;
begin
  if not FIsInit then begin
    FHQLog.SetOutputPath(FAppPath + 'Log\HQ\');
    FWebLog.SetOutputPath(FAppPath + 'Log\Web\');
    FSysLog.SetOutputPath(FAppPath + 'Log\Sys\');
    FIndicatorLog.SetOutputPath(FAppPath + 'Log\Indicator\');
    FHQLog.Initialize;
    FWebLog.Initialize;
    FSysLog.Initialize;
    FIndicatorLog.Initialize;
    FLogOutputThread.Start;
    FIsInit := True;

    HQLog(FLevel, 'FastLog Start');
    SysLog(FLevel, 'FastLog Start');
    WebLog(FLevel, 'FastLog Start');
    IndicatorLog(FLevel, 'FastLog Start');
    HQLog(llSLOW, 'FastLog Start');
    SysLog(llSLOW, 'FastLog Start');
    WebLog(llSLOW, 'FastLog Start');
    IndicatorLog(llSLOW, 'FastLog Start');
  end;
end;

procedure TLogImpl.UnInitialize;
begin
  if FIsInit then begin
    FLogOutputThread.ShutDown;
    HQLog(FLevel, 'FastLog End');
    SysLog(FLevel, 'FastLog End');
    WebLog(FLevel, 'FastLog End');
    IndicatorLog(FLevel, 'FastLog End');
    HQLog(llSLOW, 'FastLog End');
    SysLog(llSLOW, 'FastLog End');
    WebLog(llSLOW, 'FastLog End');
    IndicatorLog(llSLOW, 'FastLog End');
    FIsInit := False;
    ForceWriteDisk;
  end;
end;

procedure TLogImpl.ForceWriteDisk;
begin
  FHQLog.SafeOutputFile;
  FWebLog.SafeOutputFile;
  FSysLog.SafeOutputFile;
  FIndicatorLog.SafeOutputFile;
end;

procedure TLogImpl.SetLogLevel(ALevel: TLogLevel);
begin
  FLevel := ALevel;
  FHQLog.SetLogLevel(ALevel);
  FWebLog.SetLogLevel(ALevel);
  FSysLog.SetLogLevel(ALevel);
  FIndicatorLog.SetLogLevel(ALevel);
end;

procedure TLogImpl.HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FHQLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FHQLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TLogImpl.WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FWebLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FWebLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TLogImpl.SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FSysLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FSysLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TLogImpl.IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FIndicatorLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FIndicatorLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TLogImpl.DoOutputFileThreadExecute(AObject: TObject);
begin
  while not FLogOutputThread.IsTerminated do begin
    Application.ProcessMessages;

    FHQLog.SafeOutputFile;
    FWebLog.SafeOutputFile;
    FSysLog.SafeOutputFile;
    FIndicatorLog.SafeOutputFile;
    Sleep(1000);
  end;
end;

end.
