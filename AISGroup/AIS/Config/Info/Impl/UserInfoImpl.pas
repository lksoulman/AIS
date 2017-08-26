unit UserInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
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
  AppContext;

type

  TUserInfoImpl = class(TInterfacedObject, IUserInfo)
  private
    // 产品编号
    FProNo: string;
    // 机构编号
    FOrgNo: string;
    // 资产编号
    FAssetNo: string;
    // 是不是保存密码
    FSavePassword: Integer;    // 0 表示不保存密码  1 表示保存密码
    // 聚源用户名称
    FUserName: string;
    // 聚源用户密码
    FUserPassword: string;
    // 资产用户名称
    FAssetUserName: string;
    // 用户密码
    FAssetUserPassword: string;
    // 绑定后的 License
    FBindLicense: string;
    // 用户所属机构所属标记
    FBindOrgSign: string;
    // 密码过期提示
    FPasswordExpire: Integer; // 0 表示不需要 N 天密码过期系统提示  1 表示需要 N 天密码过期系统提示
    // 密码过期天数
    FPasswordExpireDays: Integer;
    // 上次系统提示N天密码过期日期
    FPasswordExpireHintDate: string;
    // 验证码
    FVerifyCode: Integer;    // 0 表示没有验证码服务  1 表示有验证码服务
    // 登录类型
    FLoginType: TLoginType;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
    // Int 转 TLoginType
    function IntToLoginType(AValue: Integer): TLoginType;
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IUserInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 保存缓存
    procedure SaveCache; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 重置绑定信息
    procedure ResetBindInfo; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // 机构编号
    function GetProNo: WideString; safecall;
    // 机构编号
    procedure SetProNo(AProNo: WideString); safecall;
    // 产品编号
    function GetOrgNo: WideString; safecall;
    // 产品编号
    procedure SetOrgNo(AOrgNo: WideString); safecall;
    // 资产编号
    function GetAssetNo: WideString; safecall;
    // 资产编号
    procedure SetAssetNo(AAssetNo: WideString); safecall;
    // 获取是不是保存密码
    function GetSavePassword: Boolean; safecall;
    // 设置是不是保存密码
    procedure SetSavePassword(ASavePassword: boolean); safecall;
    // 聚源用户名称
    function GetUserName: WideString; safecall;
    // 聚源用户名称
    procedure SetUserName(AUserName: WideString); safecall;
    // 聚源用户密码
    function GetUserPassword: WideString; safecall;
    // 获取密文的用户密码
    function GetCiperUserPassword: WideString; safecall;
    // 聚源用户密码
    procedure SetUserPassword(APassword: WideString); safecall;
    // 资产用户名称
    function GetAssetUserName: WideString; safecall;
    // 资产用户名称
    procedure SetAssetUserName(AUserName: WideString); safecall;
    // 资产用户密码
    function GetAssetUserPassword: WideString; safecall;
    // 获取密文的资产用户密码
    function GetCiperAssetUserPassword: WideString; safecall;
    // 用户密码
    procedure SetAssetUserPassword(APassword: WideString); safecall;
    // 绑定后的 License
    function GetBindLicense: WideString; safecall;
    // 绑定后的 License
    procedure SetBindLicense(ABindLicense: WideString); safecall;
    // 用户所属机构所属标记
    function GetBindOrgSign: WideString; safecall;
    // 用户所属机构所属标记
    procedure SetBindOrgSign(ABindOrgSign: WideString); safecall;
    // 获取是不是需要 N 天后修改密码
    function GetPasswordExpire: boolean; safecall;
    // 获取设置是不是需要 N 天后修改密码
    procedure SetPasswordExpire(APasswordExpire: boolean); safecall;
    // 获取密码过期天数
    function GetPasswordExpireDays: Integer; safecall;
    // 设置密码过期天数
    procedure SetPasswordExpireDays(ADay: Integer); safecall;
    // 设置服务端返回的密码信息 Json 字符串
    procedure SetPasswordInfo(APasswordInfo: string); safecall;
    // 登录类型
    function GetLoginType: TLoginType; safecall;
    // 登录类型
    procedure SetLoginType(ALoginType: TLoginType); safecall;
  end;

implementation

uses
  Config;

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

function TUserInfoImpl.IntToLoginType(AValue: Integer): TLoginType;
begin
  case AValue of
    0:
      begin
        Result := ltUFX;
      end;
    1:
      begin
        Result := ltGIL;
      end;
    2:
      begin
        Result := ltPBOX;
      end;
  else
    Result := ltUFX;
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
  LValue, LUserPassword, LAssetUserPassword, LBindOrgSign: string;
begin
  LUserPassword := '';
  LAssetUserPassword := '';
  if FAppContext <> nil then begin
    if FAppContext.GetConfig <> nil then begin
      if FAppContext.GetCipherMgr <> nil then begin
        if GetSavePassword then begin
          LUserPassword := FAppContext.GetCipherMgr.AES_Encrypt128(AnsiString(FUserPassword));
          LAssetUserPassword := FAppContext.GetCipherMgr.AES_Encrypt128(FAssetUserPassword);
        end;
        LBindOrgSign := FAppContext.GetCipherMgr.AES_Encrypt128(FBindOrgSign);
      end;
      LValue := Format('SavePassword=%d;UserName=%s;UserPassword=%s;AssetUserName=%s;AssetUserPassword=%s;BindLicense=%s;BindOrgSign=%s;PasswordExpireHintDate=%s',
        [FSavePassword, FUserName, LUserPassword, FAssetUserName, LAssetUserPassword, FBindLicense, LBindOrgSign, FPasswordExpireHintDate]);
      (FAppContext.GetConfig as IConfig).GetSysCfgCache.SetValue('UserInfo', LValue);
    end;
  end;
end;

procedure TUserInfoImpl.LoadCache;
var
  LStringList: TStringList;
  LAssetUserPassword: string;
begin
  if FAppContext <> nil then begin
    if FAppContext.GetConfig <> nil then begin
      LStringList := TStringList.Create;
      try
        LStringList.Delimiter := ';';
        LStringList.DelimitedText := (FAppContext.GetConfig as IConfig).GetSysCfgCache.GetValue('UserInfo');
        if LStringList.DelimitedText <> '' then begin
          FSavePassword := StrToIntDef(LStringList.Values['SavePassword'], 0);
          FUserName := LStringList.Values['UserName'];
          FUserPassword := LStringList.Values['UserPassword'];
          FAssetUserName := LStringList.Values['AssetUserName'];
          FAssetUserPassword := LStringList.Values['AssetUserPassword'];
          FBindLicense := LStringList.Values['BindLicense'];
          FBindOrgSign := LStringList.Values['BindOrgSign'];
          FPasswordExpireHintDate := LStringList.Values['PasswordExpireHintDate'];
          if FAppContext.GetCipherMgr <> nil then begin
            if GetSavePassword then begin
              LAssetUserPassword := LStringList.Values['AssetUserPassword'];
              FAssetUserPassword := FAppContext.GetCipherMgr.AES_Decrypt128(AnsiString(LAssetUserPassword));
            end else begin
              FAssetUserPassword := '';
            end;
            FBindOrgSign := FAppContext.GetCipherMgr.AES_Decrypt128(AnsiString(FBindOrgSign));
          end else begin
            FAssetUserPassword := '';
            FBindOrgSign := '';
          end;
        end;
      finally
        LStringList.Free;
      end;
    end;
  end;
end;

procedure TUserInfoImpl.ResetBindInfo;
begin
  case self.FLoginType of
    ltUFX:
      begin
        FUserName := '';
        FBindLicense := '';
        FBindOrgSign := '';
      end;
    ltGIL:
      begin

      end;
    ltPBOX:
      begin
        FUserName := '';
        FBindLicense := '';
        FBindOrgSign := '';
      end;
  end;
end;

procedure TUserInfoImpl.LoadByIniFile(AFile: TIniFile);
begin
  if AFile = nil then Exit;
  FProNo := AFile.ReadString('UserInfo', 'ProNo', '');
  FOrgNo := AFile.ReadString('UserInfo', 'OrgNo', '');
  FAssetNo := AFile.ReadString('UserInfo', 'AssetNo', '');
  FLoginType := IntToLoginType(AFile.ReadInteger('UserInfo', 'AssetNo', 1));
end;

function TUserInfoImpl.GetProNo: WideString;
begin
  Result := FProNo;
end;

procedure TUserInfoImpl.SetProNo(AProNo: WideString);
begin
  FProNo := AProNo;
end;

function TUserInfoImpl.GetOrgNo: WideString;
begin
  Result := FOrgNo;
end;

procedure TUserInfoImpl.SetOrgNo(AOrgNo: WideString);
begin
  FOrgNo := AOrgNo;
end;

function TUserInfoImpl.GetAssetNo: WideString;
begin
  Result := FAssetNo;
end;

procedure TUserInfoImpl.SetAssetNo(AAssetNo: WideString);
begin
  FAssetNo := AAssetNo;
end;

function TUserInfoImpl.GetSavePassword: Boolean;
begin
  Result := (FSavePassword = 1);
end;

procedure TUserInfoImpl.SetSavePassword(ASavePassword: boolean);
begin
  if ASavePassword then begin
    FSavePassword := 1;
  end else begin
    FSavePassword := 0;
  end;
end;

function TUserInfoImpl.GetUserName: WideString;
begin
  Result := FUserName;
end;

procedure TUserInfoImpl.SetUserName(AUserName: WideString);
begin
  FUserName := AUserName;
end;

function TUserInfoImpl.GetUserPassword: WideString;
begin
  Result := FUserPassword;
end;

function TUserInfoImpl.GetCiperUserPassword: WideString;
var
  LCiperPassword: AnsiString;
begin
  if (FAppContext <> nil) and (FAppContext.GetCipherMgr <> nil) then begin
    LCiperPassword := AnsiString(FUserPassword);
    LCiperPassword := FAppContext.GetCipherMgr.RSA_EncryptAndBase64(LCiperPassword);
  end else begin
    LCiperPassword := '';
  end;
  Result := WideString(LCiperPassword);
end;

procedure TUserInfoImpl.SetUserPassword(APassword: WideString);
begin
  FUserPassword := APassword;
end;

function TUserInfoImpl.GetAssetUserName: WideString;
begin
  Result := FAssetUserName;
end;

procedure TUserInfoImpl.SetAssetUserName(AUserName: WideString);
begin
  FAssetUserName := AUserName;
end;

function TUserInfoImpl.GetAssetUserPassword: WideString;
begin
  Result := FAssetUserPassword;
end;

function TUserInfoImpl.GetCiperAssetUserPassword: WideString;
var
  LCiperPassword: AnsiString;
begin
  if (FAppContext <> nil) and (FAppContext.GetCipherMgr <> nil) then begin
    LCiperPassword := AnsiString(FAssetUserPassword);
    LCiperPassword := FAppContext.GetCipherMgr.RSA_EncryptAndBase64(LCiperPassword);
  end else begin
    LCiperPassword := '';
  end;
  Result := WideString(LCiperPassword);
end;

procedure TUserInfoImpl.SetAssetUserPassword(APassword: WideString);
begin
  FAssetUserPassword := APassword;
end;

function TUserInfoImpl.GetBindLicense: WideString;
begin
  Result := FBindLicense;
end;

procedure TUserInfoImpl.SetBindLicense(ABindLicense: WideString);
begin
  FBindLicense := ABindLicense;
end;

function TUserInfoImpl.GetBindOrgSign: WideString;
begin
  Result := FBindOrgSign;
end;

procedure TUserInfoImpl.SetBindOrgSign(ABindOrgSign: WideString);
begin
  FBindOrgSign := ABindOrgSign;
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

procedure TUserInfoImpl.SetPasswordInfo(APasswordInfo: string);
begin

end;

function TUserInfoImpl.GetLoginType: TLoginType;
begin
  Result := FLoginType;
end;

procedure TUserInfoImpl.SetLoginType(ALoginType: TLoginType);
begin
  FLoginType := ALoginType;
end;

end.
