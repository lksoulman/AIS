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
    // Get MD5
    function DoGetMD5(AFile: string): string;
    // Get CRC
    function DoGetCRC(AFile: string): string;
    // Scan Dir Recursion
    procedure DoScanDirRecursion(AMainPath, ARelativePath: string);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize;
    // Set Need Filter File
    procedure SetNeedFilterFile(AFilterFileName: string);
    // Generate
    procedure Generate(AMainPath: string; AChildPaths: TStringList; AUpdateInfos: TList<TUpdateInfo>);
  end;

implementation

uses
  Utils,
  Forms,
  LogLevel;

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

procedure TUpdateGenerate.UnInitialize;
begin
  FUpdateAppContext := nil;
end;

procedure TUpdateGenerate.SetNeedFilterFile(AFilterFileName: string);
begin
  FFilterFileDic.AddOrSetValue(AFilterFileName, AFilterFileName);
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

function TUpdateGenerate.DoGetMD5(AFile: string): string;
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

function TUpdateGenerate.DoGetCRC(AFile: string): string;
begin
  try
    Result := Self.FCipherCRC.GetFileCRC(AFile);
  except
    on Ex: Exception do begin
      Result := '';
      FUpdateAppContext.Log(llERROR, Format('[TUpdateGenerate][DoGetCRC] Exception is ', [Ex.Message]));
    end;
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

      if (LSearchRec.Name <> '.')
        and (LSearchRec.Name <> '..') then begin

        //如果某个目录存在，则进入这个目录递归找到文件
        if DirectoryExists(LPath + LSearchRec.Name) then begin
          DoScanDirRecursion(AMainPath, ARelativePath + LSearchRec.Name + '\');
        end else begin
          LName := ARelativePath + LSearchRec.Name;
          if FFilterFileDic.ContainsKey(LName) then Continue;

          if not FUpdateInfoDic.ContainsKey(LName) then begin
            LUpdateInfo := TUpdateInfo(FUpdateAppContext.GetUpdateInfoPool.Allocate);
            if LUpdateInfo <> nil then begin
              LUpdateInfo.Name := LSearchRec.Name;
              LUpdateInfo.Size := LSearchRec.Size;
              LUpdateInfo.RelativePath := ARelativePath;
              LUpdateInfo.MD5Value := DoGetMD5(LPath + LUpdateInfo.Name);
              LUpdateInfo.CrcValue := DoGetCRC(LPath + LUpdateInfo.Name);
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

end.
