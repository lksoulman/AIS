unit UpdateUncompress;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Uncompress
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

  // Update Uncompress
  TUpdateUncompress = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
    // Compress File
    procedure DoUncompressFile(ASrcFile, ADesFile: string);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize(AContext: IUpdateAppContext);
    // Compress Server Update List
    procedure UncompressServerUpdateList(ASrcPath, ADesPath: string; AUpdateInfos: TList<TUpdateInfo>);
  end;

implementation

uses
  System.Zip;

{ TUpdateUncompress }

constructor TUpdateUncompress.Create;
begin
  inherited;

end;

destructor TUpdateUncompress.Destroy;
begin

  inherited;
end;

procedure TUpdateUncompress.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateUncompress.UnInitialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := nil;
end;

procedure TUpdateUncompress.UncompressServerUpdateList(ASrcPath, ADesPath: string; AUpdateInfos: TList<TUpdateInfo>);
var
  LIndex: Integer;
  LUpdateInfo: TUpdateInfo;
  LSrcFile, LDesFile: string;
begin
  if AUpdateInfos = nil then Exit;

  for LIndex := 0 to AUpdateInfos.Count - 1 do begin
    LUpdateInfo := AUpdateInfos.Items[LIndex];
    if LUpdateInfo <> nil then begin
      LSrcFile := ASrcPath + LUpdateInfo.RelativePath;
      LDesFile := ADesPath + LUpdateInfo.RelativePath;
      ForceDirectories(LDesFile);
      LSrcFile := LSrcFile + LUpdateInfo.Name + '.Zip';
      LDesFile := LDesFile + LUpdateInfo.Name;
      if FileExists(LSrcFile) then begin
        DoUncompressFile(LSrcFile, LDesFile);
      end;
    end;
  end;
end;

procedure TUpdateUncompress.DoUncompressFile(ASrcFile, ADesFile: string);
var
  LZip: TZipFile;
begin
  LZip := TZipFile.Create;
  try
    LZip.Open(ASrcFile, TZipMode.zmRead);
    LZip.Extract(ExtractFileName(ADesFile), ExtractFilePath(ADesFile));
  finally
    LZip.Free;
  end;
end;

end.
