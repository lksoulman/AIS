unit ProxyInfoImpl;

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
  ProxyInfo,
  AppContext,
  GFDataMngr_TLB;

type

  TProxyInfoImpl = class(TInterfacedObject, IProxyInfo)
  private
    // �ǲ�������
    FUse: Integer; // 0 ��ʾ������ 1 ��ʾ��
    // ���� IP
    FIP: string;
    // �˿ں�
    FPort: Integer;
    // �û���
    FUserName: string;
    // ����
    FPassword: string;
    // �ǲ�����������
    FNTLM: Integer;   // 0 ��ʾû��  1 ��ʾ������
    // ����
    FDomain: string;
    // ��������
    FProxyType: TProxyType;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
    // ��������ת���� Int
    function ProxyTypeToInt(AProxyType: TProxyType; ADefault: Integer): Integer;
    // Int ת���ɴ�������
    function IntToProxyType(AValue: Integer; ADefault: TProxyType): TProxyType;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { IProxyInfo }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ���滺��
    procedure SaveCache; safecall;
    // ���ػ���
    procedure LoadCache; safecall;
    // �ָ�Ĭ��
    procedure RestoreDefault; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // �ǲ�������
    function GetUse: boolean; safecall;
    // �����ǲ�������
    procedure SetUse(AUse: Boolean); safecall;
    // ���� IP
    function GetIP: WideString; safecall;
    // ���� IP
    procedure SetIP(AIP: WideString); safecall;
    // �˿ں�
    function GetPort: Integer; safecall;
    // �˿ں�
    procedure SetPort(APort: Integer); safecall;
    // �û���
    function GetUserName: WideString; safecall;
    // �û���
    procedure SetUserName(AUserName: WideString); safecall;
    // ����
    function GetPassword: WideString; safecall;
    // ����
    procedure SetPassword(APassword: WideString); safecall;
    // �ǲ�����������
    function GetNTLM: Boolean; safecall;
    // �ǲ�����������
    procedure SetNTLM(ANTLM: Boolean); safecall;
    // ����
    function GetDomain: WideString; safecall;
    // ����
    procedure SetDomain(ADomain: WideString); safecall;
    // ��������
    function GetProxyType: TProxyType; safecall;
    // ��������
    procedure SetProxyType(AProxyType: TProxyType); safecall;
    // ��ȡ ProxyKind
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
