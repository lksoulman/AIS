unit ServerInfoImpl;

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
  Json,
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  ServerInfo,
  AppContext;

type

  TServerInfoImpl = class(TInterfacedObject, IServerInfo)
  private
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
  end;

implementation

uses
  Utils;

{ TServerInfoImpl }

constructor TServerInfoImpl.Create(AServerName: string);
begin
  inherited Create;
  FServerIndex := 0;
  FAttemptCount := 0;
  FServerName := AServerName;
  FServerList := TStringList.Create;
  FServerList.Delimiter := ';';
end;

destructor TServerInfoImpl.Destroy;
begin
  FServerList.Free;
  inherited;
end;

procedure TServerInfoImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TServerInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TServerInfoImpl.SaveCache;
begin

end;

procedure TServerInfoImpl.LoadByIniFile(AFile: TIniFile);
begin
  FServerList.DelimitedText := AFile.ReadString('ServerInfo', FServerName, '');
end;

procedure TServerInfoImpl.LoadByJsonObject(AObject: TJSONObject);
begin
  if AObject = nil then Exit;

  FServerList.DelimitedText := Utils.GetStringByJsonObject(AObject, FServerName);
end;

procedure TServerInfoImpl.NextServer;
begin
  if FServerList.Count <= 0 then Exit;

  Inc(FAttemptCount);
  FServerIndex := (FServerIndex + 1) mod FServerList.Count;
end;

procedure TServerInfoImpl.FirstServer;
begin
  FAttemptCount := 0;
end;

function TServerInfoImpl.IsEOF: boolean;
begin
  Result := True;
  if FServerList.Count <= 0 then Exit;

  if FAttemptCount < FServerList.Count then begin
    Result := False;
  end else begin
    Result := True;
  end;
end;

function TServerInfoImpl.GetServerUrl: WideString;
begin
  if (FServerIndex >= 0) and (FServerIndex < FServerList.Count) then begin
    Result := FServerList.Strings[FServerIndex];
  end else begin
    Result := '';
  end;
end;

function TServerInfoImpl.GetServerName: WideString;
begin
  Result := FServerName;
end;

function TServerInfoImpl.GetServerIndex: Integer;
begin
  Result := FServerIndex;
end;

end.
