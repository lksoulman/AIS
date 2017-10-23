unit UserInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： User Info Interface Implementation
// Author：      lksoulman
// Date：        2017-7-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  UserInfo,
  AppContext,
  CommonRefCounter;

type

  // User Info Interface Implementation
  TUserInfoImpl = class(TAutoInterfacedObject, IUserInfo)
  private
    // Product No
    FProNo: string;
    // Org No
    FOrgNo: string;
    // Asset No
    FAssetNo: string;
    // Bind Info
    FBindInfo: TBindInfo;
    // Save Password
    FSavePassword: Integer;         // 0 表示不保存密码  1 表示保存密码
    // Account Type
    FAccountType: TAccountType;
    // Gil Account Info
    FGilAccountInfo: TAccountInfo;
    // UFX Account Info
    FUFXAccountInfo: TAccountInfo;
    // PBox Acount Info
    FPBoxAccountInfo: TAccountInfo;
    // Password Expire
    FPasswordExpire: Integer;       // 0 Not Need System Hint   1 Need System Hint
    // Password Expire Days
    FPasswordExpireDays: Integer;
    // Password Expire Hint Date
    FPasswordExpireHintDate: string;
    // Verify Code
    FVerifyCode: Integer;           // 0 表示没有验证码服务  1 表示有验证码服务
    // Application Context
    FAppContext: IAppContext;
  protected
    // Int To TAccountType
    function IntToAccountType(AValue: Integer): TAccountType;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IUserInfo }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Save Cache
    procedure SaveCache;
    // Load Cache
    procedure LoadCache;
    // Reset
    procedure ResetBindInfo;
    // Read
    procedure Read(AFile: TIniFile);
    // Get Product No
    function GetProNo: WideString;
    // Get Org No
    function GetOrgNo: WideString;
    // Get Asset No
    function GetAssetNo: WideString;
    // Get Bind Info
    function GetBindInfo: PBindInfo;
    // Get Save Password
    function GetSavePassword: Boolean;
    // Get Account Type
    function GetAccountType: TAccountType;
    // Get Gil AccountInfo
    function GetGilAccountInfo: PAccountInfo;
    // Get UFX AccountInfo
    function GetUFXAccountInfo: PAccountInfo;
    // Get PBox AccountInfo
    function GetPBoxAccountInfo: PAccountInfo;
    // Get Gil Ciper Password
    function GetGilCipherPassword: WideString;
    // Get UFX Ciper Password
    function GetUFXCipherPassword: WideString;
    // Get PBox Ciper Password
    function GetPBoxCipherPassword: WideString;
    // Get Password Expire
    function GetPasswordExpire: boolean;
    // Get Password Expire Days
    function GetPasswordExpireDays: Integer;
    // Set Password Expire Days
    procedure SetPasswordExpireDays(ADay: Integer);
    // Set Save Password
    procedure SetSavePassword(ASavePassword: boolean);
    // Set Password Info
    procedure SetPasswordInfo(APasswordInfo: WideString);
    // Set Password Expire
    procedure SetPasswordExpire(APasswordExpire: boolean);
  end;

implementation

uses
  Cfg,
  EDCrypt;

{ TUserInfoImpl }

constructor TUserInfoImpl.Create;
begin
  inherited;
  FVerifyCode := 0;
  FSavePassword := 0;
  FPasswordExpire := 0;
  FPasswordExpireDays := 0;
end;

destructor TUserInfoImpl.Destroy;
begin

  inherited;
end;

function TUserInfoImpl.IntToAccountType(AValue: Integer): TAccountType;
begin
  case AValue of
    1:
      begin
        Result := atGIL;
      end;
    2:
      begin
        Result := atPBOX;
      end;
  else
    Result := atUFX;
  end;
end;

procedure TUserInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
end;

procedure TUserInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TUserInfoImpl.SaveCache;
var
  LValue, LGilPassword, LUFXPassword, LPBoxPassword: string;
begin
  if GetSavePassword then begin
    LGilPassword := FGilAccountInfo.FPassword;
    LUFXPassword := FUFXAccountInfo.FPassword;
    LPBoxPassword := FPBoxAccountInfo.FPassword;
  end else begin
    LGilPassword := '';
    LUFXPassword := '';
    LPBoxPassword := '';
  end;
  LValue := Format('SavePassword=%d;'
                 + 'GilUserName=%s;'
                 + 'GilPassword=%s;'
                 + 'UFXUserName=%s;'
                 + 'UFXPassword=%s;'
                 + 'PBoxUserName=%s;'
                 + 'PBoxPassword=%s;'
                 + 'License=%s;'
                 + 'OrgSign=%s;'
                 + 'PasswordExpireHintDate=%s',
                 [ FSavePassword,
                   FGilAccountInfo.FUserName,
                   LGilPassword,
                   FUFXAccountInfo.FUserName,
                   LUFXPassword,
                   FPBoxAccountInfo.FUserName,
                   LPBoxPassword,
                   FBindInfo.FLicense,
                   FBindInfo.FOrgSign,
                   FPasswordExpireHintDate]);
  FAppContext.GetCfg.GetSysCacheCfg.SetValue('UserInfo', LValue);
end;

procedure TUserInfoImpl.LoadCache;
var
  LStringList: TStringList;
begin
  if FAppContext <> nil then begin
    LStringList := TStringList.Create;
    try
      LStringList.Delimiter := ';';
      LStringList.DelimitedText := FAppContext.GetCfg.GetSysCacheCfg.GetValue('UserInfo');
      if LStringList.DelimitedText <> '' then begin
        FSavePassword := StrToIntDef(LStringList.Values['SavePassword'], 0);
        FGilAccountInfo.FUserName := LStringList.Values['GilUserName'];
        FGilAccountInfo.FPassword := LStringList.Values['GilPassword'];
        FUFXAccountInfo.FUserName := LStringList.Values['UFXUserName'];
        FUFXAccountInfo.FPassword := LStringList.Values['UFXPassword'];
        FPBoxAccountInfo.FUserName := LStringList.Values['PBoxUserName'];
        FPBoxAccountInfo.FPassword := LStringList.Values['PBoxPassword'];
        FBindInfo.FLicense := LStringList.Values['License'];
        FBindInfo.FOrgSign := LStringList.Values['OrgSign'];
      end;
    finally
      LStringList.Free;
    end;
  end;
end;

procedure TUserInfoImpl.ResetBindInfo;
begin
  case FAccountType of
    atUFX:
      begin
        FGilAccountInfo.FUserName := '';
        FBindInfo.FLicense := '';
        FBindInfo.FOrgSign := '';
      end;
    atGIL:
      begin

        FBindInfo.FLicense := '';
        FBindInfo.FOrgSign := '';
      end;
    atPBOX:
      begin
        FGilAccountInfo.FUserName := '';
        FBindInfo.FLicense := '';
        FBindInfo.FOrgSign := '';
      end;
  end;
end;

procedure TUserInfoImpl.Read(AFile: TIniFile);
begin
  if AFile = nil then Exit;
  FProNo := AFile.ReadString('UserInfo', 'ProNo', '');
  FOrgNo := AFile.ReadString('UserInfo', 'OrgNo', '');
  FAssetNo := AFile.ReadString('UserInfo', 'AssetNo', '');
  FAccountType := IntToAccountType(AFile.ReadInteger('UserInfo', 'AccountType', 0));
end;

function TUserInfoImpl.GetProNo: WideString;
begin
  Result := FProNo;
end;

function TUserInfoImpl.GetOrgNo: WideString;
begin
  Result := FOrgNo;
end;

function TUserInfoImpl.GetAssetNo: WideString;
begin
  Result := FAssetNo;
end;

function TUserInfoImpl.GetBindInfo: PBindInfo;
begin
  Result := @FBindInfo;
end;

function TUserInfoImpl.GetSavePassword: Boolean;
begin
  Result := (FSavePassword = 1);
end;

function TUserInfoImpl.GetAccountType: TAccountType;
begin
  Result := FAccountType;
end;

function TUserInfoImpl.GetGilAccountInfo: PAccountInfo;
begin
  Result := @FGilAccountInfo;
end;

function TUserInfoImpl.GetUFXAccountInfo: PAccountInfo;
begin
  Result := @FUFXAccountInfo;
end;

function TUserInfoImpl.GetPBoxAccountInfo: PAccountInfo;
begin
  Result := @FPBoxAccountInfo;
end;

function TUserInfoImpl.GetGilCipherPassword: WideString;
var
  LCiperPassword: AnsiString;
begin
  if (FAppContext <> nil) then begin
    LCiperPassword := AnsiString(FGilAccountInfo.FPassword);
    LCiperPassword := FAppContext.GetEDCrypt.EncryptRSAEncodeBase64(LCiperPassword);
  end else begin
    LCiperPassword := '';
  end;
  Result := WideString(LCiperPassword);
end;

function TUserInfoImpl.GetUFXCipherPassword: WideString;
var
  LCiperPassword: AnsiString;
begin
  if (FAppContext <> nil) then begin
    LCiperPassword := AnsiString(FUFXAccountInfo.FPassword);
    LCiperPassword := FAppContext.GetEDCrypt.EncryptRSAEncodeBase64(LCiperPassword);
  end else begin
    LCiperPassword := '';
  end;
  Result := WideString(LCiperPassword);
end;

function TUserInfoImpl.GetPBoxCipherPassword: WideString;
var
  LCiperPassword: AnsiString;
begin
  if (FAppContext <> nil) then begin
    LCiperPassword := AnsiString(FPBoxAccountInfo.FPassword);
    LCiperPassword := FAppContext.GetEDCrypt.EncryptRSAEncodeBase64(LCiperPassword);
  end else begin
    LCiperPassword := '';
  end;
  Result := WideString(LCiperPassword);
end;

function TUserInfoImpl.GetPasswordExpire: boolean;
begin
  Result := (FPasswordExpire = 1);
end;

procedure TUserInfoImpl.SetPasswordExpire(APasswordExpire: boolean);
begin
  if APasswordExpire
    and (FPasswordExpireHintDate <> FormatDateTime('YYYYMMDD', Now)) then begin
    FPasswordExpire := 1;
  end else begin
    FPasswordExpire := 0;
  end;
end;

function TUserInfoImpl.GetPasswordExpireDays: Integer;
begin
  Result := FPasswordExpireDays;
end;

procedure TUserInfoImpl.SetPasswordExpireDays(ADay: Integer);
begin
  FPasswordExpireDays := ADay;
end;

procedure TUserInfoImpl.SetSavePassword(ASavePassword: boolean);
begin
  if ASavePassword then begin
    FSavePassword := 1;
  end else begin
    FSavePassword := 0;
  end;
end;

procedure TUserInfoImpl.SetPasswordInfo(APasswordInfo: WideString);
begin

end;

end.
