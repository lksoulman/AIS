unit FastLog;

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
  CommonLock,
  FastLogLevel,
  CommonRefCounter;

type

  TFastLog = class(TAutoObject)
  private
    // 路径
    FPath: string;
    // 慢日志路径
    FSlowPath: string;
    // 线程安全锁
    FLock: TCSLock;
    // 线程安全锁
    FSlowLock: TCSLock;
    // 日志级别
    FLevel: TLogLevel;
    // 时间格式
    FDateFormat: string;
    // 日志暂存内容
    FLogInfos: TStringList;
    // 日志暂存内容
    FSlowLogInfos: TStringList;
  protected
    // 输出日志到文件
    procedure DoSafeLogOutputFile;
    // 输出日志到文件
    procedure DoSafeSlowLogOutputFile;
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;
    // 初始化数据
    procedure Initialize;
    // 输出日志到文件
    procedure SafeOutputFile;
    // 设置输出路径
    procedure SetOutputPath(APath: string);
    // 设置日志级别
    procedure SetLogLevel(ALevel: TLogLevel);
    // 输出日志
    procedure AppendLog(ALevel: TLogLevel; ALog: string);
    // 输出慢日志
    procedure AppendSlowLog(ALevel: TLogLevel; AUseTime: Integer; ALog: string);
  end;

implementation

const

 LOGLEVEL_OUTSTRING: TLogLevelArray = ('[DEBUG]',
                                       '[INFO ]',
                                       '[WARN ]',
                                       '[ERROR]',
                                       '[FATAL]',
                                       '[SLOW ]'
                                       );

{ TFastLog }

constructor TFastLog.Create;
begin
  inherited;
  FDateFormat := '[hh:nn:ss.zzz]';
{$IFDEF DEBUG}
  FLevel := llDEBUG;
{$ELSE}
  FLevel := llWARN;
{$ENDIF}

  SetOutputPath(ExtractFilePath(ParamStr(0)) + '\Log\');
  FLock := TCSLock.Create;
  FSlowLock := TCSLock.Create;
  FLogInfos := TStringList.Create;
  FSlowLogInfos := TStringList.Create;
end;

destructor TFastLog.Destroy;
begin
  FSlowLogInfos.Free;
  FLogInfos.Free;
  FSlowLock.Free;
  FLock.Free;
  inherited;
end;

procedure TFastLog.Initialize;
begin
  if not DirectoryExists(FPath) then begin
    ForceDirectories(FPath);
  end;
  if not DirectoryExists(FSlowPath) then begin
    ForceDirectories(FSlowPath);
  end;
end;

procedure TFastLog.SafeOutputFile;
begin
  DoSafeLogOutputFile;
  DoSafeSlowLogOutputFile;
end;

procedure TFastLog.DoSafeLogOutputFile;
var
  LFile: string;
  LTextFile: TextFile;
begin
  try
    FLock.Lock;
    try
      if FLogInfos.Text = '' then Exit;

      LFile := FPath + FormatDateTime('YYYY-MM-DD', Now) + '.log';
      AssignFile(LTextFile, LFile);
      try
        if FileExists(LFile) then
          Append(LTextFile)
        else
          ReWrite(LTextFile);
        Write(LTextFile, FLogInfos.Text);
        FLogInfos.Clear;
      finally
        CloseFile(LTextFile);
      end;
    finally
      FLock.UnLock;
    end;
  except
    on Ex: Exception do begin
      AppendLog(llError, Format('[TFastLog][DoSafeLogOutputFile] Exception is %s.', [Ex.Message]));
    end;
  end;
end;

procedure TFastLog.DoSafeSlowLogOutputFile;
var
  LFile: string;
  LTextFile: TextFile;
begin
  try
    FSlowLock.Lock;
    try
      if FSlowLogInfos.Text = '' then Exit;

      LFile := FSlowPath + FormatDateTime('YYYY-MM-DD', Now) + '.log';
      AssignFile(LTextFile, LFile);
      try
        if FileExists(LFile) then
          Append(LTextFile)
        else
          ReWrite(LTextFile);
        Write(LTextFile, FSlowLogInfos.Text);
        FSlowLogInfos.Clear;
      finally
        CloseFile(LTextFile);
      end;
    finally
      FSlowLock.UnLock;
    end;
  except
    on Ex: Exception do begin
      AppendLog(llError, Format('[TFastLog][DoSafeSlowLogOutputFile] Exception is %s.', [Ex.Message]));
    end;
  end;
end;

procedure TFastLog.SetOutputPath(APath: string);
begin
  FPath := APath;
  FSlowPath := APath + 'Slow\';
end;

procedure TFastLog.SetLogLevel(ALevel: TLogLevel);
begin
  FLevel := ALevel;
end;

procedure TFastLog.AppendLog(ALevel: TLogLevel; ALog: string);
var
  LLog: string;
begin
  if Ord(ALevel) < Ord(FLevel) then Exit;

  FLock.Lock;
  try
    LLog := Format('%s %s %s', [FormatDateTime(FDateFormat, Now), LOGLEVEL_OUTSTRING[ALevel], ALog]);
    FLogInfos.Add(LLog);
  finally
    FLock.UnLock;
  end;
end;

procedure TFastLog.AppendSlowLog(ALevel: TLogLevel; AUseTime: Integer; ALog: string);
var
  LLog: string;
begin
  if Ord(ALevel) < Ord(FLevel) then Exit;

  FSlowLock.Lock;
  try
    LLog := Format('%s %s [%10.0dms] %s', [FormatDateTime(FDateFormat, Now), LOGLEVEL_OUTSTRING[ALevel], AUseTime, ALog]);
    FSlowLogInfos.Add(LLog);
  finally
    FSlowLock.UnLock;
  end;
end;

end.
