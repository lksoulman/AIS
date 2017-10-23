unit UpdateAppContextImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Application Context Interface Implementation
// Author£º      lksoulman
// Date£º        2017-10-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  UpdateLog,
  UpdateInfoPool,
  UpdateAppContext,
  CommonRefCounter;

type

  // Update Application Context Interface Implementation
  TUpdateAppContextImpl = class(TAutoInterfacedObject, IUpdateAppContext)
  private
    //
    FHandle: THandle;
    // Application Path
    FAppPath: string;
    // Application Name
    FAppName: string;
    // Update Path
    FUpdatePath: string;
    // Backup Path
    FBackupPath: string;
    // Download Path
    FDownloadPath: string;
    // Log
    FUpdateLog: TUpdateLog;
    // UpdateInfo Pool
    FUpdateInfoPool: TUpdateInfoPool;
  protected
    // Init Dirs
    procedure DoInitDirs;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IUpdateAppContext }

    // Get Handle
    function GetHandle: THandle; safecall;
    // Get Application Name
    function GetAppName: string; safecall;
    // Get Application Path
    function GetAppPath: string; safecall;
    // Get Update Path
    function GetUpdatePath: string; safecall;
    // Get BackUp Path
    function GetBackupPath: string; safecall;
    // Get Download Path
    function GetDownloadPath: string; safecall;
    // Get Download Compress Path
    function GetDownCompressPath: string; safecall;
    // Get Download Uncompress Path
    function GetDownUncompressPath: string; safecall;
    // Get UpdateInfoPool
    function GetUpdateInfoPool: TUpdateInfoPool; safecall;
    // Set Handle
    procedure SetHandle(AHandle: THandle); safecall;
    // Log
    procedure Log(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

{ TUpdateAppContextImpl }

constructor TUpdateAppContextImpl.Create;
begin
  inherited;
  FUpdateLog := TUpdateLog.Create;
  FUpdateInfoPool := TUpdateInfoPool.Create(30);
  DoInitDirs;
  FUpdateLog.Initialize;
end;

destructor TUpdateAppContextImpl.Destroy;
begin
  FUpdateLog.UnInitialize;
  FUpdateInfoPool.Free;
  FUpdateLog.Free;
  inherited;
end;

procedure TUpdateAppContextImpl.DoInitDirs;
begin
  FAppName := ExtractFileName(ParamStr(0));
  FAppPath := ExtractFilePath(ParamStr(0));
  FAppPath := ExpandFileName(FAppPath + '..\');
  FUpdatePath := FAppPath + 'Update\';
  FBackupPath := FUpdatePath + 'Backup\';
  FDownloadPath := FUpdatePath + 'Download\';

  if not DirectoryExists(FUpdatePath) then begin
    ForceDirectories(FUpdatePath);
  end;

  if not DirectoryExists(FBackupPath) then begin
    ForceDirectories(FBackupPath);
  end;

  if not DirectoryExists(FDownloadPath) then begin
    ForceDirectories(FDownloadPath);
  end;
end;

function TUpdateAppContextImpl.GetHandle: THandle;
begin
  Result := FHandle;
end;

function TUpdateAppContextImpl.GetAppName: string;
begin
  Result := FAppName;
end;

function TUpdateAppContextImpl.GetAppPath: string;
begin
  Result := FAppPath;
end;

function TUpdateAppContextImpl.GetUpdatePath: string;
begin
  Result := FUpdatePath;
end;

function TUpdateAppContextImpl.GetBackupPath: string;
begin
  Result := FBackupPath;
end;

function TUpdateAppContextImpl.GetDownloadPath: string;
begin
  Result := FDownloadPath;
end;

function TUpdateAppContextImpl.GetDownCompressPath: string;
begin
  Result := FDownloadPath + 'Compress\';
end;

function TUpdateAppContextImpl.GetDownUncompressPath: string;
begin
  Result := FDownloadPath + 'Uncompress\';
end;

function TUpdateAppContextImpl.GetUpdateInfoPool: TUpdateInfoPool;
begin
  Result := FUpdateInfoPool;
end;

procedure TUpdateAppContextImpl.SetHandle(AHandle: THandle);
begin
  FHandle := AHandle;
end;

procedure TUpdateAppContextImpl.Log(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer);
begin
  FUpdateLog.Log(ALevel, ALog, AUseTime);
end;

end.
