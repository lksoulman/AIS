unit SystemInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º System Info Interface Implementation
// Author£º      lksoulman
// Date£º        2017-7-21
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  LogLevel,
  SystemInfo,
  AppContext,
  LanguageType,
  CommonRefCounter;

type

  // System Info Interface Implementation
  TSystemInfoImpl = class(TAutoInterfacedObject, ISystemInfo)
  private
    // System Info
    FSystemInfo: TSystemInfo;
    // Application Context
    FAppContext: IAppContext;
  protected
    // Init HardDisk Id
    procedure InitHardDiskId;
    // String To LogLevel
    function StrToLogLevel(ALogLevel: string): TLogLevel;
    // LogLevel To String
    function LogLevelToStr(ALogLevel: TLogLevel): string;
    // String To LanguageType
    function StrToLanguageType(ALanguageType: string): TLanguageType;
    // LanguageType To String
    function LanguageTypeToStr(ALanguageType: TLanguageType): string;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISystemInfo }

    // Init
    procedure Initialize(AContext: IInterface);
    // UnInit
    procedure UnInitialize;
    // Read
    procedure Read(AFile: TIniFile);
    // Save Cache
    procedure SaveCache;
    // Load Cache
    procedure LoadCache;
    // Get System Info
    function GetSystemInfo: PSystemInfo;
  end;

implementation

uses
  Cfg,
  HardWareUtil;

{ TSystemInfoImpl }

constructor TSystemInfoImpl.Create;
begin
  inherited;
  FSystemInfo.FLogLevel := llINFO;
  FSystemInfo.FReLoginTime := 15;
  FSystemInfo.FFontRatio := '';
  FSystemInfo.FSkinStyle := '';
  FSystemInfo.FMacAddress := '';
  FSystemInfo.FHardDiskId := '';
  FSystemInfo.FLanguageType := ltChinese;
end;

destructor TSystemInfoImpl.Destroy;
begin

  inherited;
end;

procedure TSystemInfoImpl.InitHardDiskId;
var
  LVolumeSerialNumber, LHardDiskSerialNumber: string;
begin
  FSystemInfo.FMacAddress := GetMacAddress;
  LVolumeSerialNumber := string(GetVolumeSerialNumber);
  LHardDiskSerialNumber := string(GetHardDiskSerialNumber);
  if FAppContext <> nil then begin
    FSystemInfo.FHardDiskId := LHardDiskSerialNumber + LVolumeSerialNumber;
    FSystemInfo.FHardDiskIdMD5 := FAppContext.GetEDCrypt.StringMD5(FSystemInfo.FHardDiskId);
  end;
end;

function TSystemInfoImpl.StrToLogLevel(ALogLevel: string): TLogLevel;
var
  LValue: string;
begin
  LValue := UpperCase(ALogLevel);
  if LValue = 'INFO' then begin
    Result := llINFO;
  end else if LValue = 'WARN' then begin
    Result := llWARN;
  end else if LValue = 'ERROR' then begin
    Result := llERROR;
  end else if LValue = 'FATAL' then begin
    Result := llFATAL;
  end else begin
    Result := llDEBUG;
  end;
end;

function TSystemInfoImpl.LogLevelToStr(ALogLevel: TLogLevel): string;
begin
  case ALogLevel of
    llINFO:
      begin
        Result := 'INFO';
      end;
    llWARN:
      begin
        Result := 'WARN';
      end;
    llERROR:
      begin
        Result := 'ERROR';
      end;
    llFATAL:
      begin
        Result := 'FATAL';
      end;
  else
    Result := 'DEBUG';
  end;
end;

function TSystemInfoImpl.StrToLanguageType(ALanguageType: string): TLanguageType;
var
  LValue: string;
begin
  LValue := UpperCase(ALanguageType);
  if LValue = 'TRANDITIONALCHINESE' then begin
    Result := ltTraditionalChinese;
  end else if LValue = 'ENGLISH' then begin
    Result := ltEnglish;
  end else begin
    Result := ltChinese;
  end;
end;

function TSystemInfoImpl.LanguageTypeToStr(ALanguageType: TLanguageType): string;
begin
  case ALanguageType of
    ltChinese:
      begin
        Result := 'CHINESE';
      end;
    ltTraditionalChinese:
      begin
        Result := 'TRANDITIONALCHINESE'
      end;
    ltEnglish:
      begin
        Result := 'ENGLISH';
      end;
  end;
end;

procedure TSystemInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
  InitHardDiskId;
end;

procedure TSystemInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TSystemInfoImpl.Read(AFile: TIniFile);
begin
  if AFile = nil then Exit;
  FSystemInfo.FLogLevel := StrToLogLevel(AFile.ReadString('SystemInfo', 'LogLevel', ''));
  FSystemInfo.FReLoginTime := AFile.ReadInteger('SystemInfo', 'ReLoginTimeout', FSystemInfo.FReLoginTime);
  FSystemInfo.FFontRatio := AFile.ReadString('SystemInfo', 'FontRatio', FSystemInfo.FFontRatio);
  FSystemInfo.FSkinStyle := AFile.ReadString('SystemInfo', 'SkinStyle', FSystemInfo.FSkinStyle);
  FSystemInfo.FLanguageType := StrToLanguageType(AFile.ReadString('SystemInfo', 'LanguageType', ''));
end;

procedure TSystemInfoImpl.SaveCache;
var
  LValue: string;
begin
  if FAppContext <> nil then begin
    LValue := Format('FontRatio=%s;'
                   + 'SkinStyle=%s;'
                   + 'LanguageType=%s',
                    [FSystemInfo.FFontRatio,
                     FSystemInfo.FSkinStyle,
                     LanguageTypeToStr(FSystemInfo.FLanguageType)]);
    FAppContext.GetCfg.GetSysCacheCfg.SetValue('SystemInfo', LValue);
  end;
end;

procedure TSystemInfoImpl.LoadCache;
var
  LStringList: TStringList;
begin
  if FAppContext <> nil then begin
    LStringList := TStringList.Create;
    try
      LStringList.Delimiter := ';';
        LStringList.DelimitedText := FAppContext.GetCfg.GetSysCacheCfg.GetValue('SystemInfo');
      if LStringList.DelimitedText <> '' then begin
        FSystemInfo.FLogLevel := StrToLogLevel(LStringList.Values['LogLevel']);
        FSystemInfo.FFontRatio := LStringList.Values['FontRatio'];
        FSystemInfo.FSkinStyle := LStringList.Values['SkinStyle'];
        FSystemInfo.FLanguageType := StrToLanguageType(LStringList.Values['LanguageType']);
      end;
    finally
      LStringList.Free;
    end;
  end;
end;

function TSystemInfoImpl.GetSystemInfo: PSystemInfo;
begin
  Result := @FSystemInfo;
end;

end.
