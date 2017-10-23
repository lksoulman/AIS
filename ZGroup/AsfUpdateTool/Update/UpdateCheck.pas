unit UpdateCheck;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Check
// Author£º      lksoulman
// Date£º        2017-10-12
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CipherMD5,
  UpdateInfo,
  UpdateAppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Update Check
  TUpdateCheck = class(TAutoObject)
  private
    // MD5
    FCipherMD5: TCipherMD5;
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
    // Get MD5
    function DoGetMD5(AFile: string): string;
    // Is Need Upgrade File
    function DoIsNeedUpgradeFile(APath: string; AUpdateInfo: TUpdateInfo): Boolean;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize;
    // Check
    procedure Check(APath: string; AServerUpdateInfos, AAddUpdateInfos: TList<TUpdateInfo>);
  end;

implementation

uses
  LogLevel;

{ TUpdateCheck }

constructor TUpdateCheck.Create;
begin
  inherited;
  FCipherMD5 := TCipherMD5.Create;
end;

destructor TUpdateCheck.Destroy;
begin
  FCipherMD5.Free;
  inherited;
end;

procedure TUpdateCheck.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateCheck.UnInitialize;
begin
  FUpdateAppContext := nil;
end;

procedure TUpdateCheck.Check(APath: string; AServerUpdateInfos, AAddUpdateInfos: TList<TUpdateInfo>);
var
  LIndex: Integer;
  LUpdateInfo: TUpdateInfo;
begin
  if AServerUpdateInfos = nil then Exit;

  for LIndex := 0 to AServerUpdateInfos.Count - 1 do begin
    LUpdateInfo := AServerUpdateInfos.Items[LIndex];
    if LUpdateInfo <> nil then begin
      DoIsNeedUpgradeFile(APath, LUpdateInfo);
    end;
  end;
end;

function TUpdateCheck.DoGetMD5(AFile: string): string;
begin
  try
    Result := FCipherMD5.GetFileMD5(AFile);
  except
    on Ex: Exception do begin
      Result := '';
      FUpdateAppContext.Log(llERROR, Format('[TUpdateGenerate][DoGetMD5] Exception is ', [Ex.Message]));
    end;
  end;
end;

function TUpdateCheck.DoIsNeedUpgradeFile(APath: string; AUpdateInfo: TUpdateInfo): Boolean;
var
  LFile, LFileMD5Value: string;
begin
  Result := True;
  LFile := APath + AUpdateInfo.RelativePath + AUpdateInfo.Name;
  if not FileExists(LFile) then Exit;

  LFileMD5Value := DoGetMD5(LFile);
  Result := (AUpdateInfo.MD5Value <> LFileMD5Value);
end;

end.
