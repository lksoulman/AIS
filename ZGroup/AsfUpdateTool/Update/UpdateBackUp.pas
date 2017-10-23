unit UpdateBackup;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Backup
// Author£º      lksoulman
// Date£º        2017-10-14
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

  // Update Backup
  TUpdateBackup = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
    // Delete Dir
    procedure DoDeleteDir(APath: string);
    // Shell Copy Dir
    procedure DoShellCopyDir(ASrcPath, ADesPath: string);
    // Get Max Backup Dir
    procedure DoGetMaxMinBackupDir(var AMax, AMin, ABackupCount: Integer);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize;
    // Backup
    procedure Backup(ASrcPath: string; AChildPaths: TStringList);
  end;

implementation

uses
  ShellApi;

{ TUpdateBackup }

constructor TUpdateBackup.Create;
begin
  inherited;

end;

destructor TUpdateBackup.Destroy;
begin

  inherited;
end;

procedure TUpdateBackup.DoDeleteDir(APath: string);
var
  LSearchRec: TSearchRec;
begin
  if FindFirst(APath + '*.*', faAnyFile, LSearchRec) = 0 then begin
    repeat
      if ((LSearchRec.Attr and fadirectory) = fadirectory) then begin
        if (LSearchRec.Name <> '.')
          and (LSearchRec.name <> '..') then begin
          DoDeleteDir(APath + LSearchRec.name + '\');
        end;
      end else begin
        if ((LSearchRec.Attr and fadirectory) <> fadirectory) then begin
          DeleteFile(APath + LSearchRec.name);
        end;
      end;
    until FindNext(LSearchRec) <> 0;
    FindClose(LSearchRec);
    Removedir(APath);
  end;
end;

procedure TUpdateBackup.DoShellCopyDir(ASrcPath, ADesPath: string);
var
  LOpStruc: TSHFileOpStruct;
  LFrombuf, LTobuf: Array [0..128] of Char;
begin
  FillChar(LFrombuf, Sizeof(LFrombuf), 0);
  FillChar(LTobuf, SizeOf(LTobuf), 0);
  StrPCopy(LFrombuf, ASrcPath);
  StrPCopy(LTobuf, ADesPath);
  With LOpStruc Do begin
    Wnd := FUpdateAppContext.GetHandle;
    wFunc := FO_COPY;
    pFrom := @LFrombuf;
    pTo := @LTobuf;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION or FOF_RENAMEONCOLLISION;
    fAnyOperationsAborted := False;
    hNameMappings := nil;
    lpszProgressTitle := nil;
  end;
  ShFileOperation(LOpStruc);
end;

procedure TUpdateBackup.DoGetMaxMinBackupDir(var AMax, AMin, ABackupCount: Integer);
var
  LPath: string;
  LValue: Integer;
  LSearchRec: TSearchRec;
begin
  LPath := FUpdateAppContext.GetBackupPath;

  AMax := -1;
  AMin := -1;
  ABackupCount := 0;
  if FindFirst(LPath + '*.*', faAnyFile, LSearchRec) = 0 then begin
    repeat
      if (LSearchRec.Name <> '.')
        and (LSearchRec.Name <> '..') then begin

        if ((LSearchRec.Attr and fadirectory) = fadirectory) then begin
          LValue := StrToIntDef(LSearchRec.Name, -1);
          if LValue <> -1 then begin
            Inc(ABackupCount);
            if AMax = -1 then begin
              AMax := LValue;
            end else begin
              if LValue > AMax then begin
                AMax := LValue;
              end;
            end;
            if AMin = -1 then begin
              AMin := LValue;
            end else begin
              if LValue < AMin then begin
                AMin := LValue;
              end;
            end;
          end;
        end;
      end;
    until FindNext(LSearchRec) <> 0;
    FindClose(LSearchRec);
  end;
end;

procedure TUpdateBackup.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateBackup.UnInitialize;
begin
  FUpdateAppContext := nil;
end;

procedure TUpdateBackup.Backup(ASrcPath: string; AChildPaths: TStringList);
var
  LMaxPath, LSrcPath, LDesPath: string;
  LIndex, LMax, LMin, LBackupCount: Integer;
begin
  if (not DirectoryExists(ASrcPath))
    or (AChildPaths = nil) then Exit;

  DoGetMaxMinBackupDir(LMax, LMin, LBackupCount);
  if LBackupCount >= 3 then begin
    DoDeleteDir(FUpdateAppContext.GetBackupPath + IntToStr(LMin) + '\');
  end;
  if LBackupCount > 0 then begin
    LMax := LMax + 1;
  end;
  LMaxPath := FUpdateAppContext.GetBackupPath + IntToStr(LMax) + '\';
  if not DirectoryExists(LMaxPath) then begin
    ForceDirectories(LMaxPath);
  end;
  for LIndex := 0 to AChildPaths.Count - 1 do begin
    LSrcPath := ASrcPath + AChildPaths.Strings[LIndex];
    LDesPath := LMaxPath + AChildPaths.Strings[LIndex];
    DoShellCopyDir(LSrcPath, LDesPath);
  end;
end;

end.
