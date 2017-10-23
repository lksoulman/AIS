unit UpdateGenerate;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Update Generate
// Author：      lksoulman
// Date：        2017-10-12
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CipherMD5,
  CipherCRC,
  UpdateInfo,
  UpdateAppContext,
  CommonRefCounter,
  Generics.Collections;

type

  PSearchRec = ^TSearchRec;

  // Update Generate
  TUpdateGenerate = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
    // MD5
    FCipherMD5: TCipherMD5;
    // CRC
    FCipherCRC: TCipherCRC;
    // Update File Info
    FUpdateInfos: TList<TUpdateInfo>;
    // Filter File Dictionary
    FFilterFileDic: TDictionary<string, string>;
    // Update Dictionary
    FUpdateInfoDic: TDictionary<string, TUpdateInfo>;
  protected
    // Compress File
    procedure DoCompressFile(ASrcFile, ADesFile: string);
    // Scan Dir Recursion
    procedure DoScanDirRecursion(AMainPath, ARelativePath: string);
    // Update DownLoad
    procedure DoUpdateDownload(APath, ADownLoadPath: string; AUpdateInfos: TList<TUpdateInfo>);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize(AContext: IUpdateAppContext);
    // Generate
    procedure Generate(AMainPath: string; AChildPaths: TStringList; AUpdateInfos: TList<TUpdateInfo>);
  end;

implementation

uses
  Utils,
  Forms,
  System.Zip;

constructor TUpdateGenerate.Create;
begin
  inherited;
  FCipherMD5 := TCipherMD5.Create;
  FCipherCRC := TCipherCRC.Create;
  FFilterFileDic := TDictionary<string, string>.Create;
  FUpdateInfoDic := TDictionary<string, TUpdateInfo>.Create;
end;

destructor TUpdateGenerate.Destroy;
begin
  FFilterFileDic.Free;
  FUpdateInfoDic.Free;
  FCipherCRC.Free;
  FCipherMD5.Free;
  inherited;
end;

procedure TUpdateGenerate.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateGenerate.UnInitialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := nil;
end;

procedure TUpdateGenerate.Generate(AMainPath: string; AChildPaths: TStringList; AUpdateInfos: TList<TUpdateInfo>);
var
  LIndex: Integer;
begin
  if (AChildPaths = nil) or (AUpdateInfos = nil) then Exit;

  FUpdateInfoDic.Clear;
  FUpdateInfos := AUpdateInfos;
  for LIndex := 0 to AChildPaths.Count - 1 do begin
    DoScanDirRecursion(AMainPath, AChildPaths.Strings[LIndex]);
  end;
end;

procedure TUpdateGenerate.DoCompressFile(ASrcFile, ADesFile: string);
var
  LZipFile: TZipFile;
begin
  LZipFile := TZipFile.Create;
  try
    LZipFile.Open(ADesFile, TZipMode.zmWrite);
    LZipFile.Add(ASrcFile, ExtractFileName(ASrcFile));
  finally
    LZipFile.Free;
  end;
end;

procedure TUpdateGenerate.DoScanDirRecursion(AMainPath, ARelativePath: string);
var
  LName, LPath: string;
  LSearchRec: TSearchRec;
  LUpdateInfo: TUpdateInfo;
begin
  LPath := AMainPath + ARelativePath;
  if FindFirst(LPath + '*.*', faAnyFile, LSearchRec) = 0 then begin
    repeat
      Application.ProcessMessages;

      //
      if (LSearchRec.Name <> '.')
        and (LSearchRec.Name <> '..') then begin

        //如果某个目录存在，则进入这个目录递归找到文件
        if DirectoryExists(LPath + LSearchRec.Name) then begin
          ARelativePath := ARelativePath + LSearchRec.Name + '\';
          DoScanDirRecursion(AMainPath, ARelativePath);
        end else begin

          LName := ARelativePath + LSearchRec.Name;
          if FFilterFileDic.ContainsKey(LName) then Continue;

          if not FUpdateInfoDic.ContainsKey(LName) then begin
            LUpdateInfo := TUpdateInfo.Create;
            if LUpdateInfo <> nil then begin
              LUpdateInfo.Name := LSearchRec.Name;
              LUpdateInfo.Size := LSearchRec.Size;
              LUpdateInfo.RelativePath := ARelativePath;
//              LUpdateInfo.MD5Value := FCipherMD5.GetFileMD5(LPath + LUpdateInfo.Name);
//              LUpdateInfo.CrcValue := FCipherCRC.GetFileCRC(LPath + LUpdateInfo.Name);
              FUpdateInfoDic.AddOrSetValue(LName, LUpdateInfo);
              FUpdateInfos.Add(LUpdateInfo);
            end;
          end;
        end;
      end;
    until FindNext(LSearchRec) <> 0;
    FindClose(LSearchRec);
  end;
end;

procedure TUpdateGenerate.DoUpdateDownload(APath, ADownLoadPath: string; AUpdateInfos: TList<TUpdateInfo>);
var
  LIndex: Integer;
  LUpdateInfo: TUpdateInfo;
  LSrcFile, LDesFile: string;
begin
  for LIndex := 0 to AUpdateInfos.Count - 1 do begin
    LUpdateInfo := AUpdateInfos.Items[LIndex];
    if LUpdateInfo <> nil then begin
      LSrcFile := APath + LUpdateInfo.RelativePath + LUpdateInfo.Name;
      LDesFile := ADownLoadPath + LUpdateInfo.RelativePath + LUpdateInfo.Name;
      if FileExists(LSrcFile) then begin
        DoCompressFile(LSrcFile, LDesFile);
      end;
    end;
  end;
end;

end.
