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
    // Application Path
    FAppPath: string;
    //
    FDownloadPath: string;
    // Log
    FUpdateLog: TUpdateLog;
    // UpdateInfo Pool
    FUpdateInfoPool: TUpdateInfoPool;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IUpdateAppContext }

    // Get Application Path
    function GetAppPath: string; safecall;
    // Get Download Path
    function GetDownloadPath: string; safecall;
    // Get UpdateInfoPool
    function GetUpdateInfoPool: TUpdateInfoPool; safecall;
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
  FAppPath := ExtractFilePath(ParamStr(0));
  FAppPath := ExpandFileName(FAppPath + '..\');
  FDownloadPath := FAppPath + 'Download\';
  FUpdateLog.Initialize;
end;

destructor TUpdateAppContextImpl.Destroy;
begin
  FUpdateLog.UnInitialize;
  FUpdateInfoPool.Free;
  FUpdateLog.Free;
  inherited;
end;

function TUpdateAppContextImpl.GetAppPath: string;
begin
  Result := FAppPath;
end;

function TUpdateAppContextImpl.GetDownloadPath: string;
begin
  Result := FDownloadPath;
end;

function TUpdateAppContextImpl.GetUpdateInfoPool: TUpdateInfoPool;
begin
  Result := FUpdateInfoPool;
end;

procedure TUpdateAppContextImpl.Log(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer);
begin
  FUpdateLog.Log(ALevel, ALog, AUseTime);
end;

end.
