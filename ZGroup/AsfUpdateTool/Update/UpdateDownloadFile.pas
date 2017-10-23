unit UpdateDownloadFile;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Download File
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
  UpdateInfo,
  UpdateAppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Update Download File
  TUpdateDownloadFile = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
    // Block Download File
    function DoBlockDownloadFile(AUrlFile, ADesFile: string): Boolean;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize(AContext: IUpdateAppContext);
    // Download
    function DownloadFile(AUrlFile, ADesFile: string): Boolean;
    // Download
    function DownloadUpdate(APath: string; AUpdateInfos: TList<TUpdateInfo>): Boolean;
  end;

implementation

uses
  Winapi.UrlMon;

{ TUpdateDownloadFile }

constructor TUpdateDownloadFile.Create;
begin
  inherited;

end;

destructor TUpdateDownloadFile.Destroy;
begin

  inherited;
end;

procedure TUpdateDownloadFile.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateDownloadFile.UnInitialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := nil;
end;

function TUpdateDownloadFile.DownloadFile(AUrlFile, ADesFile: string): Boolean;
begin
  Result := DoBlockDownloadFile(AUrlFile, ADesFile);
end;

procedure TUpdateDownloadFile.DownloadUpdate(APath: string; AUpdateInfos: TList<TUpdateInfo>);
var
  LIndex: Integer;
  LDownloadFile: string;
  LUpdateInfo: TUpdateInfo;
begin
  if AUpdateInfos = nil then Exit;

  for LIndex := 0 to AUpdateInfos.Count - 1 do begin
    LUpdateInfo := AUpdateInfos.Items[LIndex];
    if LUpdateInfo <> nil then begin
      LDownloadFile := APath + LUpdateInfo.RelativePath;
      if not DirectoryExists(LDownloadFile) then begin
        ForceDirectories(LDownloadFile);
      end;
      LDownloadFile := LDownloadFile + LUpdateInfo.Name;
    end;
  end;
end;

function TUpdateDownloadFile.DoBlockDownloadFile(AUrlFile, ADesFile: string): Boolean;
begin
  Result := URLDownloadToFile(nil, PChar(AUrlFile), PChar(ADesFile), 0, nil) = ERROR_SUCCESS;
end;

end.
