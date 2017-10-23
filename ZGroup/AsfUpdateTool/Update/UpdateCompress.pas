unit UpdateCompress;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Compress
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

  // Update Compress
  TUpdateCompress = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
    // Compress File
    procedure DoCompressFile(ASrcFile, ADesFile: string);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize;
    // Compress Server Update List
    procedure CompressServerUpdateList(ASrcPath, ADesPath: string; AUpdateInfos: TList<TUpdateInfo>);
  end;

implementation

uses
  System.Zip;

{ TUpdateCompress }

constructor TUpdateCompress.Create;
begin
  inherited;

end;

destructor TUpdateCompress.Destroy;
begin

  inherited;
end;

procedure TUpdateCompress.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateCompress.UnInitialize;
begin
  FUpdateAppContext := nil;
end;

procedure TUpdateCompress.CompressServerUpdateList(ASrcPath, ADesPath: string; AUpdateInfos: TList<TUpdateInfo>);
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
      LSrcFile := LSrcFile + LUpdateInfo.Name;
      LDesFile := LDesFile + LUpdateInfo.Name;
      if FileExists(LSrcFile) then begin
        DoCompressFile(LSrcFile, LDesFile);
      end;
    end;
  end;
end;

procedure TUpdateCompress.DoCompressFile(ASrcFile, ADesFile: string);
var
  LZipFile: TZipFile;
begin
  LZipFile := TZipFile.Create;
  try
    LZipFile.Open(ADesFile + '.Zip', TZipMode.zmWrite);
    LZipFile.Add(ASrcFile, ExtractFileName(ASrcFile));
  finally
    LZipFile.Free;
  end;
end;

end.
