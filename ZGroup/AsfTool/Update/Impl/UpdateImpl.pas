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
  UpdateGenerate,
  UpdateReadWrite,
  CommonRefCounter,
  UpdateAppContext,
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
    // Generate
    FUpdateGenerate: TUpdateGenerate;
    // Read Write
    FUpdateReadWrite: TUpdateReadWrite;
    // Server Update Infos
    FServerUpdateInfos: TList<TUpdateInfo>;
  protected
    // Init Update Paths
    procedure DoInitUpdatePaths;
    // Clear
    procedure DoClear(AUpdateFileInfos: TList<TUpdateInfo>);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IUpdate }

    // Generate Server Update List
    procedure GenerateServerUpdateList; safecall;
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
  FUpdateGenerate := TUpdateGenerate.Create;
  FUpdateReadWrite := TUpdateReadWrite.Create;
  FServerUpdateInfos := TList<TUpdateInfo>.Create;
  DoInitUpdatePaths;
end;

destructor TUpdateImpl.Destroy;
begin
  DoClear(FServerUpdateInfos);
  FServerUpdateInfos.Free;
  FUpdateReadWrite.Free;
  FUpdateGenerate.Free;
  FUpdateCheck.Free;
  FChildPaths.Free;
  FUpdateAppContext := nil;
  inherited;
end;

procedure TUpdateImpl.GenerateServerUpdateList;
begin
  FUpdateGenerate.Generate(FUpdateAppContext.GetAppPath, FChildPaths, FServerUpdateInfos);
  FUpdateReadWrite.Write(FUpdateAppContext.GetAppPath + 'UpdateList.dat', FServerUpdateInfos);
end;

procedure TUpdateImpl.DoInitUpdatePaths;
begin
  FChildPaths.Add('Bin\');
  FChildPaths.Add('Cfg\');
  FChildPaths.Add('Skin\');
end;

procedure TUpdateImpl.DoClear(AUpdateFileInfos: TList<TUpdateInfo>);
var
  LIndex: Integer;
  LUpdateFileInfo: TUpdateInfo;
begin
  if AUpdateFileInfos = nil then Exit;

  for LIndex := 0 to AUpdateFileInfos.Count - 1 do begin
    LUpdateFileInfo := AUpdateFileInfos.Items[LIndex];
    if LUpdateFileInfo <> nil then begin
      LUpdateFileInfo.Free;
    end;
  end;
  AUpdateFileInfos.Clear;
end;

end.
