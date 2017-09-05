unit ProxyInfoImpl;

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
  ProxyInfo,
  AppContext,
  GFDataMngr_TLB;

type

  TProxyInfoImpl = class(TInterfacedObject, IProxyInfo)
  private
    // 是不是启用
    FUse: Integer; // 0 表示不启用 1 表示用
    // 代理 IP
    FIP: string;
    // 端口号
    FPort: Integer;
    // 用户名
    FUserName: string;
    // 密码
    FPassword: string;
    // 是不是设置域名
    FNTLM: Integer;   // 0 表示没有  1 表示有域名
    // 域名
    FDomain: string;
    // 代理类型
    FProxyType: TProxyType;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
    // 代理类型转化成 Int
    function ProxyTypeToInt(AProxyType: TProxyType; ADefault: Integer): Integer;
    // Int 转换成代理类型
    function IntToProxyType(AValue: Integer; ADefault: TProxyType): TProxyType;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IProxyInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 保存缓存
    procedure SaveCache; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 恢复默认
    procedure RestoreDefault; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // 是不是启用
    function GetUse: boolean; safecall;
    // 设置是不是启用
    procedure SetUse(AUse: Boolean); safecall;
    // 代理 IP
    function GetIP: WideString; safecall;
    // 代理 IP
    procedure SetIP(AIP: WideString); safecall;
    // 端口号
    function GetPort: Integer; safecall;
    // 端口号
    procedure SetPort(APort: Integer); safecall;
    // 用户名
    function GetUserName: WideString; safecall;
    // 用户名
    procedure SetUserName(AUserName: WideString); safecall;
    // 密码
    function GetPassword: WideString; safecall;
    // 密码
    procedure SetPassword(APassword: WideString); safecall;
    // 是不是设置域名
    function GetNTLM: Boolean; safecall;
    // 是不是设置域名
    procedure SetNTLM(ANTLM: Boolean); safecall;
    // 域名
    function GetDomain: WideString; safecall;
    // 域名
    procedure SetDomain(ADomain: WideString); safecall;
    // 代理类型
    function GetProxyType: TProxyType; safecall;
    // 代理类型
    procedure SetProxyType(AProxyType: TProxyType); safecall;
    // 获取 ProxyKind
    function GetProxyKindEnum: ProxyKindEnum; safecall;
  end;

implementation

uses
  Config;

{ TProxyInfoImpl }

constructor TProxyInfoImpl.Create;
begin
  inherited;
  RestoreDefault;
end;

destructor TProxyInfoImpl.Destroy;
begin

  inherited;
end;

procedure TProxyInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
end;

procedure TProxyInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TProxyInfoImpl.SaveCache;
var
  LValue: string;
begin
  LValue := Format('Use=%d;IP=%s;Port=%d;UserName=%s;Password=%s;NTLM=%d;Domain=%s;ProxyType=%s',
    [FUse, FPort, FUserName, FPassword, FNTLM, FDomain, ProxyTypeToInt(FProxyType, $00000001)]);
  if FAppContext <> nil then begin
    if FAppContext.GetConfig <> nil then begin
      (FAppContext.GetConfig as IConfig).GetSysCfgCache.SetValue('ProxyInfo', LValue);
    end;
  end;
end;

procedure TProxyInfoImpl.LoadCache;
var
  LStringList: TStringList;
begin
  if FAppContext <> nil then begin
    if FAppContext.GetConfig <> nil then begin
      LStringList := TStringList.Create;
      try
        LStringList.Delimiter := ';';
        LStringList.DelimitedText := (FAppContext.GetConfig as IConfig).GetSysCfgCache.GetValue('ProxyInfo');
        if LStringList.DelimitedText <> '' then begin
          FUse := StrToIntDef(LStringList.Values['Use'], 0);
          FIP := LStringList.Values['IP'];
          FPort := StrToIntDef(LStringList.Values['Port'], 0);
          FUserName := LStringList.Values['UserName'];
          FPassword := LStringList.Values['Password'];
          FNTLM := StrToIntDef(LStringList.Values['NTLM'], 0);
          FDomain := LStringList.Values['Domain'];
          FProxyType := IntToProxyType(StrToIntDef(LStringList.Values['ProxyType'], $00000001), ptNoProxy);
        end;
      finally
        LStringList.Free;
      end;
    end;
  end;
end;

procedure TProxyInfoImpl.RestoreDefault;
begin
  FIP := '';
  FPort := 0;
  FUserName := '';
  FPassword := '';
  FNTLM := 0;
  FDomain := '';
  FProxyType := ptNoProxy;
end;

procedure TProxyInfoImpl.LoadByIniFile(AFile: TIniFile);
begin
  if AFile = nil then Exit;

end;

function TProxyInfoImpl.GetUse: boolean;
begin
  Result := (FUse = 1);
end;

procedure TProxyInfoImpl.SetUse(AUse: Boolean);
begin
  if AUse then begin
    FUse := 1;
  end else begin
    FUse := 0;
  end;
end;

function TProxyInfoImpl.GetIP: WideString;
begin
  Result := FIP;
end;

procedure TProxyInfoImpl.SetIP(AIP: WideString);
begin
  FIP := AIP;
end;

function TProxyInfoImpl.GetPort: Integer;
begin
  Result := FPort;
end;

procedure TProxyInfoImpl.SetPort(APort: Integer);
begin
  FPort := APort;
end;

function TProxyInfoImpl.GetUserName: WideString;
begin
  Result := FUserName;
end;

procedure TProxyInfoImpl.SetUserName(AUserName: WideString);
begin
  FUserName := AUserName;
end;

function TProxyInfoImpl.GetPassword: WideString;
begin
  Result := FPassword;
end;

procedure TProxyInfoImpl.SetPassword(APassword: WideString);
begin
  FPassword := APassword;
end;

function TProxyInfoImpl.GetNTLM: boolean;
begin
  Result := (FNTLM = 1);
end;

procedure TProxyInfoImpl.SetNTLM(ANTLM: boolean);
begin
  if ANTLM then begin
    FNTLM := 1;
  end else begin
    FNTLM := 0;
  end;
end;

function TProxyInfoImpl.GetDomain: WideString;
begin
  Result := FDomain;
end;

procedure TProxyInfoImpl.SetDomain(ADomain: WideString);
begin
  FDomain := ADomain;
end;

function TProxyInfoImpl.GetProxyType: TProxyType;
begin
  Result := FProxyType;
end;

procedure TProxyInfoImpl.SetProxyType(AProxyType: TProxyType);
begin
  FProxyType := AProxyType;
end;

function TProxyInfoImpl.GetProxyKindEnum: ProxyKindEnum;
begin
  case FProxyType of
    ptHTTPProxy:
      Result := pkHTTPProxy;
    ptSocks4:
      Result := pkSocks4;
    ptSocks5:
      Result := pkSocks5;
    ptNoProxy:
      Result := pkNoProxy;
  end;
end;

function TProxyInfoImpl.ProxyTypeToInt(AProxyType: TProxyType; ADefault: Integer): Integer;
begin
  case FProxyType of
    ptHTTPProxy:
      Result := $00000002;
    ptSocks4:
      Result := $00000003;
    ptSocks5:
      Result := $00000004;
    ptNoProxy:
      Result := $00000001;
  else
    Result := ADefault;
  end;
end;

function TProxyInfoImpl.IntToProxyType(AValue: Integer; ADefault: TProxyType): TProxyType;
begin
  case AValue of
    $00000001:
      begin
        Result := ptNoProxy;
      end;
    $00000002:
      begin
        Result := ptHTTPProxy;
      end;
    $00000003:
      begin
        Result := ptSocks4;
      end;
    $00000004:
      begin
        Result := ptSocks5;
      end;
  else
    Result := ADefault;
  end;
end;

end.
