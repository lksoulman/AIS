unit UpdateUpgradeFile;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Upgrade File
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

  // Update Upgrade File
  TUpdateUpgradeFile = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
    // Copy File
    function DoCopyFile(ASrcFile, ADesFile: string): Boolean;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize(AContext: IUpdateAppContext);
    // Upgrade
    function Upgrade(ASrcPath, ADesPath: string; AUpdateInfos: TList<TUpdateInfo>): Boolean;
  end;

implementation

uses
  LogLevel,
  Winapi.UrlMon;

{ TUpdateUpgradeFile }

constructor TUpdateUpgradeFile.Create;
begin
  inherited;

end;

destructor TUpdateUpgradeFile.Destroy;
begin

  inherited;
end;

procedure TUpdateUpgradeFile.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateUpgradeFile.UnInitialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := nil;
end;

function TUpdateUpgradeFile.DoCopyFile(ASrcFile, ADesFile: string): Boolean;
var
  LPath: string;
begin
  Result := False;
  if not FileExists(ASrcFile) then Exit;

  LPath := ExtractFilePath(ADesFile);
  if not DirectoryExists(LPath) then begin
    ForceDirectories(LPath);
  end;
  try
    //CopyFile of Param False Is Cover Copy, CopyFile of Param True Isn't Cover Copy
    Result := CopyFile(ASrcFile, ADesFile, False);
  except
    on Ex: Exception do begin
      Result := False;
      FUpdateAppContext.Log(llERROR, Format('[TUpdateUpgradeFile][DoCopyFile] Exception is ', [Ex.Message]));
    end;
  end;
end;

function TUpdateUpgradeFile.Upgrade(ASrcPath, ADesPath: string; AUpdateInfos: TList<TUpdateInfo>): Boolean;
var
  LIndex: Integer;
  LUpdateInfo: TUpdateInfo;
  LSrcFile, LDesFile: string;
begin
  Result := True;
  if AUpdateInfos = nil then Exit;

  for LIndex := 0 to AUpdateInfos.Count - 1 do begin
    LUpdateInfo := AUpdateInfos.Items[LIndex];
    if LUpdateInfo <> nil then begin
      LSrcFile := ASrcPath + LUpdateInfo.RelativePath + LUpdateInfo.Name;
      LDesFile := ADesPath + LUpdateInfo.RelativePath + LUpdateInfo.Name;
      Result := DoCopyFile(LSrcFile, LDesFile) or Result;
    end;
  end;
end;

end.
