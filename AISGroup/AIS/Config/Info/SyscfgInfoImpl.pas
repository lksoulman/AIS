unit SyscfgInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-21
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  SyscfgInfo,
  AppContext,
  FastLogLevel,
  LanguageType;

type

  TSyscfgInfoImpl = class(TInterfacedObject, ISyscfgInfo)
  private
    // 字体比例大小
    FFontRatio: string;
    // 皮肤样式
    FSkinStyle: string;
    // 日志级别
    FLogLevel: TLogLevel;
    // 终端长时间未操作超时重新登录时间 (分钟)
    FReLoginTimeout: Integer;
    // 语言类型
    FLanguageType: TLanguageType;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
    // 字符串转成 LogLevel
    function StrToLogLevel(AValue: string): TLogLevel;
    // LogLevel 转成字符串
    function LogLevelToStr(ALogLevel: TLogLevel): string;
    // 字符串转成 LanguageType
    function StrToLanguageType(AValue: string): TLanguageType;
    // LanguageType 转成字符串
    function LanguageTypeToStr(ALanguageType: TLanguageType): string;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ISyscfgInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // 保存数据
    procedure SaveCache; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 设置字体比例
    procedure SetFontRatio(AFontRatio: string); safecall;
    // 获取字体比例
    function GetFontRatio: string; safecall;
    // 设置皮肤样式
    procedure SetSkinStyle(ASkinStyle: string); safecall;
    // 获取皮肤样式
    function GetSkinStyle: string; safecall;
    // 设置日志级别
    procedure SetLogLevel(ALogLevel: TLogLevel); safecall;
    // 获取日志级别
    function GetLogLevel: TLogLevel; safecall;
    // 设置语言类型
    procedure SetLanguageType(ALanguageType: TLanguageType); safecall;
    // 获取语言类型
    function GetLanguageType: TLanguageType; safecall;
  end;

implementation

uses
  Config;

{ TSyscfgInfoImpl }

constructor TSyscfgInfoImpl.Create;
begin
  inherited Create;
  FFontRatio := '';
  FSkinStyle := '';
  FLogLevel := llDEBUG;
  FReLoginTimeout := 15;
  FLanguageType := ltChinese;
end;

destructor TSyscfgInfoImpl.Destroy;
begin

  inherited;
end;

function TSyscfgInfoImpl.StrToLogLevel(AValue: string): TLogLevel;
var
  LValue: string;
begin
  LValue := UpperCase(AValue);
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

function TSyscfgInfoImpl.LogLevelToStr(ALogLevel: TLogLevel): string;
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

function TSyscfgInfoImpl.StrToLanguageType(AValue: string): TLanguageType;
var
  LValue: string;
begin
  LValue := UpperCase(AValue);
  if LValue = 'TRANDITIONALCHINESE' then begin
    Result := ltTraditionalChinese;
  end else if LValue = 'ENGLISH' then begin
    Result := ltEnglish;
  end else begin
    Result := ltChinese;
  end;
end;

function TSyscfgInfoImpl.LanguageTypeToStr(ALanguageType: TLanguageType): string;
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

procedure TSyscfgInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
end;

procedure TSyscfgInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TSyscfgInfoImpl.LoadByIniFile(AFile: TIniFile);
begin
  if AFile = nil then Exit;
  FFontRatio := AFile.ReadString('SyscfgInfo', 'FontRatio', FFontRatio);
  FSkinStyle := AFile.ReadString('SyscfgInfo', 'SkinStyle', FSkinStyle);
  FLogLevel := StrToLogLevel(AFile.ReadString('SyscfgInfo', 'LogLevel', ''));
  FReLoginTimeout := AFile.ReadInteger('SyscfgInfo', 'ReLoginTimeout', FReLoginTimeout);
  FLanguageType := StrToLanguageType(AFile.ReadString('SyscfgInfo', 'LanguageType', ''));
end;

procedure TSyscfgInfoImpl.SaveCache;
var
  LValue: string;
begin
  if FAppContext <> nil then begin
    if FAppContext.GetConfig <> nil then begin
      LValue := Format('FontRatio=%s;SkinStyle=%s;LanguageType=%s',
        [FFontRatio, FSkinStyle, LanguageTypeToStr(FLanguageType)]);
      (FAppContext.GetConfig as IConfig).GetSysCfgCache.SetValue('SyscfgInfo', LValue);
    end;
  end;
end;

procedure TSyscfgInfoImpl.LoadCache;
var
  LStringList: TStringList;
begin
  if FAppContext <> nil then begin
    if FAppContext.GetConfig <> nil then begin
      LStringList := TStringList.Create;
      try
        LStringList.Delimiter := ';';
        LStringList.DelimitedText := (FAppContext.GetConfig as IConfig).GetSysCfgCache.GetValue('SyscfgInfo');
        if LStringList.DelimitedText <> '' then begin
          FFontRatio := LStringList.Values['FontRatio'];
          FSkinStyle := LStringList.Values['SkinStyle'];
          FLogLevel := StrToLogLevel(LStringList.Values['LogLevel']);
          FLanguageType := StrToLanguageType(LStringList.Values['LanguageType']);
        end;
      finally
        LStringList.Free;
      end;
    end;
  end;
end;

procedure TSyscfgInfoImpl.SetFontRatio(AFontRatio: string);
begin
  FFontRatio := AFontRatio;
end;

function TSyscfgInfoImpl.GetFontRatio: string;
begin
  Result := FFontRatio;
end;

procedure TSyscfgInfoImpl.SetSkinStyle(ASkinStyle: string);
begin
  FSkinStyle := ASkinStyle;
end;

function TSyscfgInfoImpl.GetSkinStyle: string;
begin
  Result := FSkinStyle;
end;

procedure TSyscfgInfoImpl.SetLogLevel(ALogLevel: TLogLevel);
begin
  FLogLevel := ALogLevel;
end;

function TSyscfgInfoImpl.GetLogLevel: TLogLevel;
begin
  Result := FLogLevel;
end;

procedure TSyscfgInfoImpl.SetLanguageType(ALanguageType: TLanguageType);
begin
  FLanguageType := ALanguageType;
end;

function TSyscfgInfoImpl.GetLanguageType: TLanguageType;
begin
  Result := FLanguageType;
end;

end.
