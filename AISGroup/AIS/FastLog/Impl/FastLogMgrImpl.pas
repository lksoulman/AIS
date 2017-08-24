unit FastLogMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-1
// Comments��
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
    // �ǲ��ǳ�ʼ��
    FIsInit: Boolean;
    // ·��
    FAppPath: string;
    // �����־����
    FLevel: TLogLevel;
    // ���������־
    FHQLog: TFastLog;
    // ��ҳ������־
    FWebLog: TFastLog;
    // ϵͳӦ�ô�����־
    FAppLog: TFastLog;
    // ָ�������־
    FIndicatorLog: TFastLog;
    // �����־���
    FLogOutputThread: TExecutorThread;
  protected
    // ��־������ִ�з���
    procedure DoOutputFileThreadExecute(AObject: TObject);
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IFastLOG }

    // ��ʼ������
    procedure Initialize; safecall;
    // ж�ط���
    procedure UnInitialize; safecall;
    // дһ��
    procedure ForceWriteDisk; safecall;
    // ������־����
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // ������־���
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // ��ҳ��־���
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Ӧ��ϵͳ��־���
    procedure AppLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // ָ����־���
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
