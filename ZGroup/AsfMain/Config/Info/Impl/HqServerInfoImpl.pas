unit HqServerInfoImpl;

interface

uses
  Json,
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  AppContext,
  HqServerInfo;

type

  THqServerInfoImpl = class(TInterfacedObject, IHqServerInfo)
  private
    // �û�����
    FUserName: string;
    // ����
    FPassword: string;
    // ����������
    FServerName: string;
    // �������±�
    FServerIndex: Integer;
    // ���Է���������
    FAttemptCount: Integer;
    // �������б�
    FServerList: TStringList;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
  public
    // ���췽��
    constructor Create(AServerName: string);
    // ��������
    destructor Destroy; override;

    { IServerInfo }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��������
    procedure SaveCache; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // ͨ��Json�������
    procedure LoadByJsonObject(AObject: TJSONObject); safecall;
    // ��һ������
    procedure NextServer; safecall;
    // ��һ������
    procedure FirstServer; safecall;
    // �ǲ��ǽ���
    function IsEOF: boolean; safecall;
    // ��ȡȥ������±�
    function GetServerIndex: Integer; safecall;
    // ��ȡ����Url
    function GetServerUrl: WideString; safecall;
    // ��ȡȥ���������
    function GetServerName: WideString; safecall;

    { IHqServerInfo }

  end;

implementation

uses
  Utils;

{ THqServerInfoImpl }

constructor THqServerInfoImpl.Create(AServerName: string);
begin
  inherited Create;
  FServerIndex := 0;
  FAttemptCount := 0;
  FServerName := AServerName;
  FServerList := TStringList.Create;
  FServerList.Delimiter := ';';
  FUserName := '';
  FPassword := '';
end;

destructor THqServerInfoImpl.Destroy;
begin
  FServerList.Free;
  inherited;
end;

procedure THqServerInfoImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqServerInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure THqServerInfoImpl.SaveCache;
begin

end;

procedure THqServerInfoImpl.LoadByIniFile(AFile: TIniFile);
begin
  FServerList.DelimitedText := AFile.ReadString('ServerInfo', FServerName, '');
end;

procedure THqServerInfoImpl.LoadByJsonObject(AObject: TJSONObject);
begin
  if AObject = nil then Exit;

  FServerList.DelimitedText := Utils.GetStringByJsonObject(AObject, FServerName);
end;

procedure THqServerInfoImpl.NextServer;
begin
  if FServerList.Count <= 0 then Exit;

  Inc(FAttemptCount);
  FServerIndex := (FServerIndex + 1) mod FServerList.Count;
end;

procedure THqServerInfoImpl.FirstServer;
begin
  FAttemptCount := 0;
end;

function THqServerInfoImpl.IsEOF: boolean;
begin
  Result := True;
  if FServerList.Count <= 0 then Exit;

  if FAttemptCount < FServerList.Count then begin
    Result := False;
  end else begin
    Result := True;
  end;
end;

function THqServerInfoImpl.GetServerUrl: WideString;
begin
  if (FServerIndex >= 0) and (FServerIndex < FServerList.Count) then begin
    Result := FServerList.Strings[FServerIndex];
  end else begin
    Result := '';
  end;
end;

function THqServerInfoImpl.GetServerName: WideString;
begin
  Result := FServerName;
end;

function THqServerInfoImpl.GetServerIndex: Integer;
begin
  Result := FServerIndex;
end;

function THqServerInfoImpl.GetUserName: WideString;
begin
  Result := FUserName;
end;

procedure THqServerInfoImpl.SetUserName(AUserName: WideString);
begin
  FUserName := AUserName;
end;

function THqServerInfoImpl.GetPassword: WideString;
begin
  Result := FPassword;
end;

procedure THqServerInfoImpl.SetPassword(APassword: WideString);
begin
  FPassword := APassword;
end;

end.
