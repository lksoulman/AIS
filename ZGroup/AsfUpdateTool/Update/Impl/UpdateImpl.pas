unit UpdateImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Interface Implementation
// Author£º      lksoulman
// Date£º        2017-10-12
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Update,
  Windows,
  Classes,
  SysUtils,
  NativeXml,
  UpdateInfo,
  UpdateCheck,
  UpdateBackup,
  UpdateCompress,
  UpdateGenerate,
  UpdateReadWrite,
  UpdateUncompress,
  CommonRefCounter,
  UpdateAppContext,
  UpdateUpgradeFile,
  Generics.Collections;

type

  // Update Interface Implementation
  TUpdateImpl = class(TAutoInterfacedObject, IUpdate)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
    // UpdatePaths
    FChildPaths: TStringList;
    // Check
    FUpdateCheck: TUpdateCheck;
    // Backup
    FUpdateBackup: TUpdateBackup;
    // Compress
    FUpdateCompress: TUpdateCompress;
    // Generate
    FUpdateGenerate: TUpdateGenerate;
    // Read Write
    FUpdateReadWrite: TUpdateReadWrite;
    // Uncompress
    FUpdateUncompress: TUpdateUncompress;
    // Upgrade File
    FUpdateUpgradeFile: TUpdateUpgradeFile;
    // Need Update Infos
    FNeedUpdateInfos: TList<TUpdateInfo>;
    // Server Update Infos
    FServerUpdateInfos: TList<TUpdateInfo>;
  protected
    // Init Update Paths
    procedure DoInitUpdatePaths;
    // Init Update Application Context
    procedure DoInitUpdateAppContext;
    // Un Init Update Application Context
    procedure DoUnInitUpdateAppContext;
    // Clear
    procedure DoClear(AUpdateInfos: TList<TUpdateInfo>);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IUpdate }

    // Backup
    procedure Backup; safecall;
    // UpgradeFile
    procedure UpgradeFile; safecall;
    // Generate Need Update List
    procedure GenerateNeedUpdateList; safecall;
    // Compress Server Update List
    procedure CompressServerUpdateList; safecall;
    // Generate Server Update List
    procedure GenerateServerUpdateList; safecall;
    // Uncompress Server Update List
    procedure UncompresServerUpdateList; safecall;
    // Set Handle
    procedure SetHandle(AHandle: THandle); safecall;
  end;

implementation

uses
  Utils,
  UpdateAppContextImpl;

{ TUpdateImpl }

constructor TUpdateImpl.Create;
begin
  inherited;
  FUpdateAppContext := TUpdateAppContextImpl.Create as IUpdateAppContext;
  FChildPaths := TStringList.Create;
  FUpdateCheck := TUpdateCheck.Create;
  FUpdateBackup := TUpdateBackup.Create;
  FUpdateCompress := TUpdateCompress.Create;
  FUpdateGenerate := TUpdateGenerate.Create;
  FUpdateReadWrite := TUpdateReadWrite.Create;
  FUpdateUpgradeFile := TUpdateUpgradeFile.Create;
  FNeedUpdateInfos := TList<TUpdateInfo>.Create;
  FServerUpdateInfos := TList<TUpdateInfo>.Create;
  DoInitUpdatePaths;
  DoInitUpdateAppContext;
end;

destructor TUpdateImpl.Destroy;
begin
  DoUnInitUpdateAppContext;
  DoClear(FServerUpdateInfos);
  FServerUpdateInfos.Free;
  FNeedUpdateInfos.Free;
  FUpdateUpgradeFile.Free;
  FUpdateReadWrite.Free;
  FUpdateGenerate.Free;
  FUpdateCompress.Free;
  FUpdateBackup.Free;
  FUpdateCheck.Free;
  FChildPaths.Free;
  FUpdateAppContext := nil;
  inherited;
end;

procedure TUpdateImpl.Backup;
begin
  FUpdateBackup.Backup(FUpdateAppContext.GetAppPath, FChildPaths);
end;

procedure TUpdateImpl.UpgradeFile;
begin
  FUpdateUpgradeFile.Upgrade(FUpdateAppContext.GetAppPath, );
end;

procedure TUpdateImpl.GenerateNeedUpdateList;
begin
  DoClear(FNeedUpdateInfos);
  FUpdateCheck.Check(FUpdateAppContext.GetAppPath, FServerUpdateInfos, FNeedUpdateInfos);
  FUpdateReadWrite.Write(FUpdateAppContext.GetUpdatePath + 'NeedUpdateList.dat', FNeedUpdateInfos);
end;

procedure TUpdateImpl.CompressServerUpdateList;
begin
  FUpdateCompress.CompressServerUpdateList(FUpdateAppContext.GetAppPath, FUpdateAppContext.GetDownCompressPath, FServerUpdateInfos);
end;

procedure TUpdateImpl.GenerateServerUpdateList;
begin
  DoClear(FServerUpdateInfos);
  FUpdateGenerate.Generate(FUpdateAppContext.GetAppPath, FChildPaths, FServerUpdateInfos);
  FUpdateReadWrite.Write(FUpdateAppContext.GetUpdatePath + 'UpdateServerList.dat', FServerUpdateInfos);
end;

procedure TUpdateImpl.UncompresServerUpdateList;
begin
  FUpdateUncompress.UncompressServerUpdateList(FUpdateAppContext.GetDownCompressPath, FUpdateAppContext.GetDownUncompressPath, FServerUpdateInfos);
end;

procedure TUpdateImpl.SetHandle(AHandle: THandle);
begin
  FUpdateAppContext.SetHandle(AHandle);
end;

procedure TUpdateImpl.DoInitUpdatePaths;
begin
  FChildPaths.Add('Bin\');
  FChildPaths.Add('Cfg\');
  FChildPaths.Add('Skin\');
end;

procedure TUpdateImpl.DoInitUpdateAppContext;
begin
  FUpdateCheck.Initialize(FUpdateAppContext);
  FUpdateBackup.Initialize(FUpdateAppContext);
  FUpdateCompress.Initialize(FUpdateAppContext);
  FUpdateGenerate.Initialize(FUpdateAppContext);
  FUpdateReadWrite.Initialize(FUpdateAppContext);
end;

procedure TUpdateImpl.DoUnInitUpdateAppContext;
begin
  FUpdateCheck.UnInitialize;
  FUpdateBackup.UnInitialize;
  FUpdateCompress.UnInitialize;
  FUpdateGenerate.UnInitialize;
  FUpdateReadWrite.UnInitialize;
end;

procedure TUpdateImpl.DoClear(AUpdateInfos: TList<TUpdateInfo>);
var
  LIndex: Integer;
  LUpdateFileInfo: TUpdateInfo;
begin
  if AUpdateInfos = nil then Exit;

  for LIndex := 0 to AUpdateInfos.Count - 1 do begin
    LUpdateFileInfo := AUpdateInfos.Items[LIndex];
    if LUpdateFileInfo <> nil then begin
      LUpdateFileInfo.Free;
    end;
  end;
  AUpdateInfos.Clear;
end;

end.
