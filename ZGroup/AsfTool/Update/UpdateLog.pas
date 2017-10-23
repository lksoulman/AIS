unit UpdateLog;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Log
// Author£º      lksoulman
// Date£º        2017-10-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  FastLog,
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  CommonLock,
  ExecutorThread,
  CommonRefCounter;

type

  // Update Log
  TUpdateLog = class(TAutoObject)
  private
    // Is Init
    FIsInit: Boolean;
    // Appliaction Path
    FAppPath: string;
    // Log Level
    FLevel: TLogLevel;
    // Update Log
    FUpdateLog: TFastLog;
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
    // Init
    procedure Initialize; safecall;
    // UnInit
    procedure UnInitialize; safecall;
    // Force Write Disk
    procedure ForceWriteDisk; safecall;
    // Set Log Level
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // Log
    procedure Log(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

uses
  Vcl.Forms;

{ TUpdateLog }

constructor TUpdateLog.Create;
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
  FUpdateLog := TFastLog.Create;
  FLogOutputThread := TExecutorThread.Create;
  FLogOutputThread.ThreadMethod := DoOutputFileThreadExecute;
end;

destructor TUpdateLog.Destroy;
begin
  FUpdateLog.Free;
  inherited;
end;

procedure TUpdateLog.Initialize;
begin
  if not FIsInit then begin
    FUpdateLog.SetOutputPath(FAppPath + 'Log\UpdateLog\');
    FUpdateLog.Initialize;
    FIsInit := True;

    Log(FLevel, 'FastLog Start');
    Log(llSLOW, 'FastLog Start');
  end;
end;

procedure TUpdateLog.UnInitialize;
begin
  if FIsInit then begin
    FLogOutputThread.ShutDown;
    Log(FLevel, 'FastLog End');
    Log(llSLOW, 'FastLog End');
    FIsInit := False;
    ForceWriteDisk;
  end;
end;

procedure TUpdateLog.ForceWriteDisk;
begin
  FUpdateLog.SafeOutputFile;
end;

procedure TUpdateLog.SetLogLevel(ALevel: TLogLevel);
begin
  FLevel := ALevel;
  FUpdateLog.SetLogLevel(ALevel);
end;

procedure TUpdateLog.Log(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FUpdateLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FUpdateLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TUpdateLog.DoOutputFileThreadExecute(AObject: TObject);
begin
  while not FLogOutputThread.IsTerminated do begin
    Application.ProcessMessages;

    FUpdateLog.SafeOutputFile;
    Sleep(1000);
  end;
end;

end.
