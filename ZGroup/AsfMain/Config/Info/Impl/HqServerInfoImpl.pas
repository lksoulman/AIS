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
    // 用户名称
    FUserName: string;
    // 密码
    FPassword: string;
    // 服务器名称
    FServerName: string;
    // 服务器下表
    FServerIndex: Integer;
    // 尝试服务器个数
    FAttemptCount: Integer;
    // 服务器列表
    FServerList: TStringList;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
  public
    // 构造方法
    constructor Create(AServerName: string);
    // 析构函数
    destructor Destroy; override;

    { IServerInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 保存数据
    procedure SaveCache; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // 通过Json对象加载
    procedure LoadByJsonObject(AObject: TJSONObject); safecall;
    // 下一个服务
    procedure NextServer; safecall;
    // 第一个服务
    procedure FirstServer; safecall;
    // 是不是结束
    function IsEOF: boolean; safecall;
    // 获取去服务的下表
    function GetServerIndex: Integer; safecall;
    // 获取服务Url
    function GetServerUrl: WideString; safecall;
    // 获取去服务的名称
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
