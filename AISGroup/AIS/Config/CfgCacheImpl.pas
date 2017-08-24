unit CfgCacheImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-23
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CfgCache,
  AppContext,
  Generics.Collections;

type

  // ���û���
  TCfgCacheImpl = class(TInterfacedObject, ICfgCache)
  private
    // �ļ�
    FPath: string;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ���������ֵ�
    FCacheDataDic: TDictionary<string, string>;
  protected
    // ��������
    function DoSetValue(AKey, AValue: string): boolean;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ICfgCache }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ���滺��
    procedure SaveCache; safecall;
    // �������û�������
    procedure LoadCfgCacheData; safecall;
    // �������û���Ŀ¼
    procedure SetCfgCachePath(APath: WideString); safecall;
    // ��ȡ����
    function GetValue(AKey: WideString): WideString; safecall;
    // ��������
    function SetValue(AKey, AValue: WideString): boolean; safecall;
  end;

implementation

uses
  Config,
  IniFiles;

{ TCfgCacheImpl }

constructor TCfgCacheImpl.Create;
begin
  inherited;
  FCacheDataDic := TDictionary<string, string>.Create;
end;

destructor TCfgCacheImpl.Destroy;
begin
  FCacheDataDic.Free;
  inherited;
end;

procedure TCfgCacheImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TCfgCacheImpl.UnInitialize;
begin

  FAppContext := nil;
end;

procedure TCfgCacheImpl.SaveCache;
begin

end;

procedure TCfgCacheImpl.LoadCfgCacheData;
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

procedure TCfgCacheImpl.SetCfgCachePath(APath: WideString);
begin
  FPath := APath;
end;

function TCfgCacheImpl.GetValue(AKey: WideString): WideString;
var
  LValue: string;
begin
  if FCacheDataDic.TryGetValue(AKey, LValue) then begin
    Result := LValue;
  end else begin
    Result := '';
  end;
end;

function TCfgCacheImpl.SetValue(AKey, AValue: WideString): boolean;
begin
  Result := False;
  if AKey <> '' then begin
    Result := DoSetValue(AKey, AValue);
    FCacheDataDic.AddOrSetValue(AKey, AValue);
  end;
end;

function TCfgCacheImpl.DoSetValue(AKey, AValue: string): boolean;
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
