unit UserInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-22
// Comments��
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
    // ��Ʒ���
    FProNo: string;
    // �������
    FOrgNo: string;
    // �ʲ����
    FAssetNo: string;
    // �ǲ��Ǳ�������
    FSavePassword: Integer;    // 0 ��ʾ����������  1 ��ʾ��������
    // ��Դ�û�����
    FUserName: string;
    // ��Դ�û�����
    FUserPassword: string;
    // �ʲ��û�����
    FAssetUserName: string;
    // �û�����
    FAssetUserPassword: string;
    // �󶨺�� License
    FBindLicense: string;
    // �û����������������
    FBindOrgSign: string;
    // ���������ʾ
    FPasswordExpire: Integer; // 0 ��ʾ����Ҫ N ���������ϵͳ��ʾ  1 ��ʾ��Ҫ N ���������ϵͳ��ʾ
    // �����������
    FPasswordExpireDays: Integer;
    // �ϴ�ϵͳ��ʾN�������������
    FPasswordExpireHintDate: string;
    // ��֤��
    FVerifyCode: Integer;    // 0 ��ʾû����֤�����  1 ��ʾ����֤�����
    // ��¼����
    FLoginType: TLoginType;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
    // Int ת TLoginType
    function IntToLoginType(AValue: Integer): TLoginType;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { IUserInfo }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ���滺��
    procedure SaveCache; safecall;
    // ���ػ���
    procedure LoadCache; safecall;
    // ���ð���Ϣ
    procedure ResetBindInfo; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // �������
    function GetProNo: WideString; safecall;
    // �������
    procedure SetProNo(AProNo: WideString); safecall;
    // ��Ʒ���
    function GetOrgNo: WideString; safecall;
    // ��Ʒ���
    procedure SetOrgNo(AOrgNo: WideString); safecall;
    // �ʲ����
    function GetAssetNo: WideString; safecall;
    // �ʲ����
    procedure SetAssetNo(AAssetNo: WideString); safecall;
    // ��ȡ�ǲ��Ǳ�������
    function GetSavePassword: Boolean; safecall;
    // �����ǲ��Ǳ�������
    procedure SetSavePassword(ASavePassword: boolean); safecall;
    // ��Դ�û�����
    function GetUserName: WideString; safecall;
    // ��Դ�û�����
    procedure SetUserName(AUserName: WideString); safecall;
    // ��Դ�û�����
    function GetUserPassword: WideString; safecall;
    // ��ȡ���ĵ��û�����
    function GetCiperUserPassword: WideString; safecall;
    // ��Դ�û�����
    procedure SetUserPassword(APassword: WideString); safecall;
    // �ʲ��û�����
    function GetAssetUserName: WideString; safecall;
    // �ʲ��û�����
    procedure SetAssetUserName(AUserName: WideString); safecall;
    // �ʲ��û�����
    function GetAssetUserPassword: WideString; safecall;
    // ��ȡ���ĵ��ʲ��û�����
    function GetCiperAssetUserPassword: WideString; safecall;
    // �û�����
    procedure SetAssetUserPassword(APassword: WideString); safecall;
    // �󶨺�� License
    function GetBindLicense: WideString; safecall;
    // �󶨺�� License
    procedure SetBindLicense(ABindLicense: WideString); safecall;
    // �û����������������
    function GetBindOrgSign: WideString; safecall;
    // �û����������������
    procedure SetBindOrgSign(ABindOrgSign: WideString); safecall;
    // ��ȡ�ǲ�����Ҫ N ����޸�����
    function GetPasswordExpire: boolean; safecall;
    // ��ȡ�����ǲ�����Ҫ N ����޸�����
    procedure SetPasswordExpire(APasswordExpire: boolean); safecall;
    // ��ȡ�����������
    function GetPasswordExpireDays: Integer; safecall;
    // ���������������
    procedure SetPasswordExpireDays(ADay: Integer); safecall;
    // ���÷���˷��ص�������Ϣ Json �ַ���
    procedure SetPasswordInfo(APasswordInfo: string); safecall;
    // ��¼����
    function GetLoginType: TLoginType; safecall;
    // ��¼����
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
