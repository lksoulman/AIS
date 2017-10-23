unit CacheCfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Cache Cfg Interface Implementation
// Author£º      lksoulman
// Date£º        2017-7-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CacheCfg,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Cache Cfg Interface Implementation
  TCacheCfgImpl = class(TAutoInterfacedObject, ICacheCfg)
  private
    // Path
    FPath: string;
    // Application Context Interface
    FAppContext: IAppContext;
    // Cache Data Dic
    FCacheDataDic: TDictionary<string, string>;
  protected
    // Set Value
    function DoSetValue(AKey, AValue: string): boolean;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ICacheCfg }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Save Cache
    procedure SaveCache; safecall;
    // Load Cache Cfg
    procedure LoadCacheCfg; safecall;
    // Set Cfg Cache Path
    procedure SetCachePath(APath: WideString); safecall;
    // Get Value
    function GetValue(AKey: WideString): WideString; safecall;
    // Set Value
    function SetValue(AKey, AValue: WideString): boolean; safecall;
  end;

implementation

uses
  Cfg,
  IniFiles;

{ TCacheCfgImpl }

constructor TCacheCfgImpl.Create;
begin
  inherited;
  FCacheDataDic := TDictionary<string, string>.Create;
end;

destructor TCacheCfgImpl.Destroy;
begin
  FCacheDataDic.Free;
  inherited;
end;

procedure TCacheCfgImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  LoadCacheCfg;
end;

procedure TCacheCfgImpl.UnInitialize;
begin

  FAppContext := nil;
end;

procedure TCacheCfgImpl.SaveCache;
begin

end;

procedure TCacheCfgImpl.LoadCacheCfg;
var
  LIndex: Integer;
  LIniFile: TIniFile;
  LStringList: TStringList;
  LFile, LKey, LValue: string;
begin
  FCacheDataDic.Clear;
  LFile := FPath + 'CfgCache.dat';
  if FileExists(LFile) then begin
    LIniFile := TIniFile.Create(FPath + 'CfgCache.dat');
    LStringList := TStringList.Create;
    try
      LIniFile.ReadSection('CfgInfo', LStringList);
      for LIndex := 0 to LStringList.Count - 1 do begin
        LKey := LStringList.Strings[LIndex];
        if LKey <> '' then begin
          LValue := LIniFile.ReadString('CfgInfo', LKey, '');
          FCacheDataDic.AddOrSetValue(LKey, LValue);
        end;
      end;
    finally
      LStringList.Free;
      LIniFile.Free;
    end;
  end;
end;

procedure TCacheCfgImpl.SetCachePath(APath: WideString);
begin
  FPath := APath;
end;

function TCacheCfgImpl.GetValue(AKey: WideString): WideString;
var
  LValue: string;
begin
  if FCacheDataDic.TryGetValue(AKey, LValue) then begin
    Result := LValue;
  end else begin
    Result := '';
  end;
end;

function TCacheCfgImpl.SetValue(AKey, AValue: WideString): boolean;
begin
  Result := False;
  if AKey <> '' then begin
    Result := DoSetValue(AKey, AValue);
    FCacheDataDic.AddOrSetValue(AKey, AValue);
  end;
end;

function TCacheCfgImpl.DoSetValue(AKey, AValue: string): boolean;
var
  LIniFile: TIniFile;
begin
  Result := False;
  if (FPath = '') or not DirectoryExists(FPath) then Exit;

  LIniFile := TIniFile.Create(FPath + 'CfgCache.dat');
  try
    LIniFile.WriteString('CfgInfo', AKey, AValue);
    Result := True;
  finally
    LIniFile.Free;
  end;
end;

end.
