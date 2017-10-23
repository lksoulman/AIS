unit ProxyInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Proxy Info Interface Implementation
// Author：      lksoulman
// Date：        2017-7-21
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  ProxyInfo,
  AppContext,
  CommonRefCounter;

type

  // Proxy Info Interface Implementation
  TProxyInfoImpl = class(TAutoInterfacedObject, IProxyInfo)
  private
    // Proxy
    FProxy: TProxy;
    // Is Use Proxy
    FIsUseProxy: Integer;     // 0 表示不启用 1 表示用
    // Application Context
    FAppContext: IAppContext;
  protected
    // Proxy Type To Int
    function ProxyTypeToInt(AProxyType: TProxyType; ADefault: Integer): Integer;
    // Int To Proxy Type
    function IntToProxyType(AValue: Integer; ADefault: TProxyType): TProxyType;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IProxyInfo }

    // Init
    procedure Initialize(AContext: IInterface);
    // UnInit
    procedure UnInitialize;
    // Save Cache
    procedure SaveCache;
    // Load Cache
    procedure LoadCache;
    // Restore Default
    procedure RestoreDefault;
    // Read File
    procedure Read(AFile: TIniFile);
    // Get Proxy
    function GetProxy: PProxy;
    // Get Is Use Proxy
    function GetIsUseProxy: boolean;
    // Set Is Use Proxy
    procedure SetIsUseProxy(AIsUseProxy: Boolean);
  end;

implementation

uses
  Cfg;

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
  LValue := Format('IsUseProxy=%d;'
                 + 'IP=%s;'
                 + 'Port=%d;'
                 + 'UserName=%s;'
                 + 'Password=%s;'
                 + 'IsUseNTLM=%d;'
                 + 'NTLMDomain=%s;'
                 + 'Type=%s',
                [FIsUseProxy,
                 FProxy.FIP,
                 FProxy.FPort,
                 FProxy.FUserName,
                 FProxy.FPassword,
                 FProxy.FIsUseNTLM,
                 FProxy.FNTLMDomain,
                 ProxyTypeToInt(FProxy.FType, 0)]);
  if FAppContext <> nil then begin
//      (FAppContext.GetConfig as IConfig).GetSysCfgCache.SetValue('ProxyInfo', LValue);
  end;
end;

procedure TProxyInfoImpl.LoadCache;
var
  LStringList: TStringList;
begin
  if FAppContext <> nil then begin

    LStringList := TStringList.Create;
    try
      LStringList.Delimiter := ';';
      LStringList.DelimitedText := FAppContext.GetCfg.GetSysCacheCfg.GetValue('ProxyInfo');
      if LStringList.DelimitedText <> '' then begin
        FIsUseProxy := StrToIntDef(LStringList.Values['Use'], 0);
        FProxy.FIP := LStringList.Values['IP'];
        FProxy.FPort := StrToIntDef(LStringList.Values['Port'], 0);
        FProxy.FUserName := LStringList.Values['UserName'];
        FProxy.FPassword := LStringList.Values['Password'];
        FProxy.FIsUseNTLM := StrToIntDef(LStringList.Values['IsUseNTLM'], 0);
        FProxy.FNTLMDomain := LStringList.Values['NTLMDomain'];
        FProxy.FType := IntToProxyType(StrToIntDef(LStringList.Values['ProxyType'], 0), ptNo);
      end;
    finally
      LStringList.Free;
    end;
  end;
end;

procedure TProxyInfoImpl.RestoreDefault;
begin

end;

procedure TProxyInfoImpl.Read(AFile: TIniFile);
begin
  if AFile = nil then Exit;

end;

function TProxyInfoImpl.GetProxy: PProxy;
begin
  Result := @FProxy;
end;

function TProxyInfoImpl.GetIsUseProxy: boolean;
begin
  Result := (FIsUseProxy = 1);
end;

procedure TProxyInfoImpl.SetIsUseProxy(AIsUseProxy: Boolean);
begin
  if AIsUseProxy then begin
    FIsUseProxy := 1;
  end else begin
    FIsUseProxy := 0;
  end;
end;

function TProxyInfoImpl.ProxyTypeToInt(AProxyType: TProxyType; ADefault: Integer): Integer;
begin
  case AProxyType of
    ptNo:
      Result := 0;
    ptHttp:
      Result := 1;
    ptSocket4:
      Result := 2;
    ptSocket5:
      Result := 3;
  else
    Result := ADefault;
  end;
end;

function TProxyInfoImpl.IntToProxyType(AValue: Integer; ADefault: TProxyType): TProxyType;
begin
  case AValue of
    0:
      begin
        Result := ptNo;
      end;
    1:
      begin
        Result := ptHttp;
      end;
    2:
      begin
        Result := ptSocket4;
      end;
    3:
      begin
        Result := ptSocket5;
      end;
  else
    Result := ADefault;
  end;
end;

end.
