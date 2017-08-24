unit SyscfgInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-21
// Comments��
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
    // ���������С
    FFontRatio: string;
    // Ƥ����ʽ
    FSkinStyle: string;
    // ��־����
    FLogLevel: TLogLevel;
    // �ն˳�ʱ��δ������ʱ���µ�¼ʱ�� (����)
    FReLoginTimeout: Integer;
    // ��������
    FLanguageType: TLanguageType;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
    // �ַ���ת�� LogLevel
    function StrToLogLevel(AValue: string): TLogLevel;
    // LogLevel ת���ַ���
    function LogLevelToStr(ALogLevel: TLogLevel): string;
    // �ַ���ת�� LanguageType
    function StrToLanguageType(AValue: string): TLanguageType;
    // LanguageType ת���ַ���
    function LanguageTypeToStr(ALanguageType: TLanguageType): string;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISyscfgInfo }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // ��������
    procedure SaveCache; safecall;
    // ���ػ���
    procedure LoadCache; safecall;
    // �����������
    procedure SetFontRatio(AFontRatio: string); safecall;
    // ��ȡ�������
    function GetFontRatio: string; safecall;
    // ����Ƥ����ʽ
    procedure SetSkinStyle(ASkinStyle: string); safecall;
    // ��ȡƤ����ʽ
    function GetSkinStyle: string; safecall;
    // ������־����
    procedure SetLogLevel(ALogLevel: TLogLevel); safecall;
    // ��ȡ��־����
    function GetLogLevel: TLogLevel; safecall;
    // ������������
    procedure SetLanguageType(ALanguageType: TLanguageType); safecall;
    // ��ȡ��������
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
