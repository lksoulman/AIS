unit LoginMainUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-12
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Messages,
  SysUtils,
  Graphics,
  Variants,
  Controls,
  StdCtrls,
  ExtCtrls,
  Buttons,
  Dialogs,
  Vcl.Imaging.pngimage,
  Mask,
  Forms,
  RzEdit,
  RzPanel,
  RzButton,
  RzRadChk,
  RzPrgres,
  Config,
  LoginMgr,
  AppContext;

const
  CONST_ReLogin_Times = 1;

type

  // 登录回调方法
  TCallBackLoginFunc = function: Boolean of Object;

  // 登录界面
  TLoginMainUI = class(TForm)
    // 登录图片
    imgLogin: TImage;
    // 关闭图片
    imgClose: TImage;
    // 设置图片
    imgSetting: TImage;
    // 背景图片
    imgBackground: TImage;
    // 登录加载信息显示标签
    lblLoadInfo: TLabel;
    // 登录加载进度显示标签
    lblLoadProgress: TLabel;
    // 用户名称输入框
    edtUserName: TEdit;
    // 用户密码明文输入框
    edtPlainPassword: TEdit;
    // 用户密码密文输入框
    edtCipherPassword: TEdit;
    // 是不是保存密码复选框
    ckbIsSavePassword: TRzCheckBox;
    // 自动尝试登录
    tmrAutoAttemptLogin: TTimer;
    // 窗口关闭时候
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    // 窗口大小变化
    procedure FormResize(Sender: TObject);
    // 窗口 Show
    procedure FormShow(Sender: TObject);
    // 窗口按下键盘
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    // 窗口关闭时候
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    // 鼠标进入登录图片
    procedure imgLoginMouseEnter(Sender: TObject);
    // 鼠标离开登录图片
    procedure imgLoginMouseLeave(Sender: TObject);
    // 鼠标进入设置图片
    procedure imgSettingMouseEnter(Sender: TObject);
    // 鼠标离开设置图片
    procedure imgSettingMouseLeave(Sender: TObject);
    // 鼠标单击登录图片
    procedure imgLoginClick(Sender: TObject);
    // 鼠标单击关闭图片
    procedure imgCloseClick(Sender: TObject);
    // 鼠标单击设置图片
    procedure imgSettingClick(Sender: TObject);
    // 鼠标按下背景图片
    procedure imgBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    // 当进入用户名输入框
    procedure edtUserNameEnter(Sender: TObject);
    // 当离开用户名输入框
    procedure edtUserNameExit(Sender: TObject);
    // 当输入框的用户名发生改变
    procedure edtUserNameChange(Sender: TObject);
    // 当进入密文密码输入框
    procedure edtCipherPasswordEnter(Sender: TObject);
    // 当离开密文密码输入框
    procedure edtCipherPasswordExit(Sender: TObject);
    // 当离开密文密码输入框发生改变
    procedure edtCipherPasswordChange(Sender: TObject);
  private
    // 配置接口
    FConfig: IConfig;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 登录回调方法
    FLoginFunc: TCallBackLoginFunc;
  protected
    // 初始化窗体控件位置和大小
    procedure DoInitWindow;
    // 创建圆角窗体
    procedure DoCreateRoundWindow;
    // 初始化图片到窗口
    procedure DoInitWindowImages;
    // 设置用户信息到登录窗体
    procedure DoSetUserInfoToWindow;
    // 设置登录窗体的信息到用户信息
    procedure DoSetWindowToUserInfo;
    // 简单校验校验
    function DoSimpleCheck(var AErrorMsg: string): Boolean;
    // 加载图片
    procedure DoLoadImage(AImage: TImage; AImageName: string);
    // 展示加载进度
    procedure DoShowLoadProcess(AMsg: string; AProcessValue: Integer);
  public
    // 构造函数
    constructor Create(AOwner: TComponent); override;
    // 析构函数
    Destructor Destroy; override;
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext);
    // 释放不需要的资源
    procedure UnInitialize;
    // 展示登录
    function ShowLogin: Integer;
    // 登录窗体上展示绑定窗口
    function ShowLoginBindUI: Integer;
    // 登录窗体上展示登录信息
    procedure ShowLoginInfo(AMsg: string);
    // 设置登录回调方法
    procedure SetLoginFunc(ALoginFunc: TCallBackLoginFunc);
  end;

implementation

uses
  UserInfo,
  LoginBindUI,
  LoginSettingUI;

const
  PROGRESS_MAX = 8;
  // 登录用户名输入框默认显示文字
  LOGIN_USERNAME = '用户名';
  // 登录密码输入框默认显示文字
  LOGIN_PASSWORD = '密  码';

{$R *.dfm}

{ TLoginMainUI }

constructor TLoginMainUI.Create(AOwner: TComponent);
begin
  inherited;
  edtUserName.TabOrder := 0;
  edtCipherPassword.TabOrder := 1;
  ckbIsSavePassword.TabOrder := 2;
  // 在XP环境下，窗口显示全不正常，这里位置重新设置。
  DoInitWindow;
end;

Destructor TLoginMainUI.Destroy();
begin

  inherited;
end;

procedure TLoginMainUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FConfig := FAppContext.GetConfig as IConfig;
  DoInitWindowImages;
end;

procedure TLoginMainUI.UnInitialize;
begin
  FConfig := nil;
  FAppContext := nil;
end;

function TLoginMainUI.ShowLogin: Integer;
begin
  DoSetUserInfoToWindow;
  if ShowModal = mrOk then begin
    Result := mrOk;
  end;
end;

function TLoginMainUI.ShowLoginBindUI: Integer;
var
  LLoginBindUI: TLoginBindUI;
begin
  LLoginBindUI := TLoginBindUI.Create(nil);
  try
    LLoginBindUI.PopupParent := Self;
    if LLoginBindUI.ShowModal = mrOk then begin
      if FConfig <> nil then begin
        FConfig.GetUserInfo.SetUserName(LLoginBindUI.GetBindAccount);
      end;
      Result := mrOk;
    end else begin
      Result := mrCancel;
    end;
  finally
    LLoginBindUI.Free;
  end;
end;

procedure TLoginMainUI.ShowLoginInfo(AMsg: string);
begin
  lblLoadProgress.Visible := True;
  lblLoadProgress.Caption := AMsg;
  Application.ProcessMessages;
end;

procedure TLoginMainUI.SetLoginFunc(ALoginFunc: TCallBackLoginFunc);
begin
  FLoginFunc := ALoginFunc;
end;

procedure TLoginMainUI.DoCreateRoundWindow;
var
  RGN: HRGN;
begin
  RGN := CreateRoundRectRGN(0, 0, Width + 1, Height + 1, 15, 15);
  SetWindowRgn(Handle, RGN, True);
  DeleteObject(RGN);
end;

procedure TLoginMainUI.DoInitWindowImages;
begin
  DoLoadImage(imgBackground, 'LoginBack.png');
  DoLoadImage(imgSetting, 'Setting.png');
  DoLoadImage(imgClose, 'Close.png');
  DoLoadImage(imgLogin, 'LoginBtn.png');
  SetWindowLong(Self.Handle, GWL_EXSTYLE, GetWindowLong(Self.Handle, GWL_EXSTYLE) { or WS_EX_TOPMOST } or
    WS_EX_APPWINDOW);
end;

procedure TLoginMainUI.DoSetUserInfoToWindow;
var
  LUserName: string;
  LPassword: string;
begin
  if FConfig <> nil then begin
    case FConfig.GetUserInfo.GetAccountType of
      atUFX:
        begin
          LUserName := FConfig.GetUserInfo.GetAssetUserName;
          if FConfig.GetUserInfo.GetSavePassword then begin
            LPassword := FConfig.GetUserInfo.GetAssetUserPassword;
            ckbIsSavePassword.Checked := True;
          end else begin
            LPassword := '';
          end;
        end;
      atGIL:
        begin
          LUserName := FConfig.GetUserInfo.GetUserName;
          if FConfig.GetUserInfo.GetSavePassword then begin
            LPassword := FConfig.GetUserInfo.GetCiperUserPassword;
            ckbIsSavePassword.Checked := True;
          end else begin
            LPassword := '';
          end;
        end;
      atPBOX:
        begin
          LUserName := FConfig.GetUserInfo.GetAssetUserName;
          if FConfig.GetUserInfo.GetSavePassword then begin
            LPassword := FConfig.GetUserInfo.GetAssetUserPassword;
            ckbIsSavePassword.Checked := True;
          end else begin
            LPassword := '';
          end;
        end;
    end;
  end;

  if LUserName = '' then begin
    edtUserName.Font.Color := $00B7B7B7;
    edtUserName.Text := LOGIN_USERNAME;
  end else begin
    edtUserName.Font.Color := $00333333;
    edtUserName.Text := LUserName;
  end;

  if LPassword = '' then begin
    edtCipherPassword.Font.Color := $00B7B7B7;
    edtCipherPassword.PasswordChar := #0;
    edtCipherPassword.Text := LOGIN_PASSWORD;
  end else begin
    edtCipherPassword.Font.Color := $00333333;
    edtCipherPassword.PasswordChar := '*';
    edtCipherPassword.Text := LPassword;
  end;
end;

procedure TLoginMainUI.DoSetWindowToUserInfo;
begin
  if FConfig <> nil then begin
    case FConfig.GetUserInfo.GetAccountType of
      atUFX:
        begin
          FConfig.GetUserInfo.SetAssetUserName(edtUserName.Text);
          FConfig.GetUserInfo.SetAssetUserPassword(edtCipherPassword.Text);
          FConfig.GetUserInfo.SetSavePassword(ckbIsSavePassword.Checked);
        end;
      atGIL:
        begin
          FConfig.GetUserInfo.SetUserName(edtUserName.Text);
          FConfig.GetUserInfo.SetUserPassword(edtCipherPassword.Text);
          FConfig.GetUserInfo.SetSavePassword(ckbIsSavePassword.Checked);
        end;
      atPBOX:
        begin
          FConfig.GetUserInfo.SetAssetUserName(edtUserName.Text);
          FConfig.GetUserInfo.SetAssetUserPassword(edtCipherPassword.Text);
          FConfig.GetUserInfo.SetSavePassword(ckbIsSavePassword.Checked);
        end;
    end;
  end;
end;

function TLoginMainUI.DoSimpleCheck(var AErrorMsg: string): Boolean;
begin
  AErrorMsg := '';
  Result := False;
  if (edtUserName.Text = '')
    or (edtUserName.Text = LOGIN_USERNAME) then begin
    AErrorMsg := '请输入登录用户';
    if (edtCipherPassword.Text = '')
      or (edtCipherPassword.Text = LOGIN_PASSWORD) then begin
      AErrorMsg := AErrorMsg + '和密码';
    end;
    Exit;
  end else begin
    if (edtCipherPassword.Text = '')
      or (edtCipherPassword.Text = LOGIN_PASSWORD) then begin
      AErrorMsg := '请输入登录密码';
      Exit;
    end;
  end;
  Result := True;
end;

procedure TLoginMainUI.DoLoadImage(AImage: TImage; AImageName: string);
var
  LFile: string;
begin
  if AImage = nil then Exit;
  if FConfig = nil then Exit;

  LFile := FConfig.GetSkinPath + 'Login\' + AImageName;
  if FileExists(LFile) then begin
    AImage.Picture.LoadFromFile(LFile);
  end;
end;

procedure TLoginMainUI.DoInitWindow;
begin
  Self.Width := 460;
  Self.Height := 350;

  with imgLogin do begin
    Left := 109;
    Top := 275;
    Width := 242;
    Height := 32;
  end;

  with imgSetting do begin
    Left := 407;
    Top := 1;
    Width := 26;
    Height := 26;
  end;

  with imgClose do begin
    Left := 434;
    Top := 1;
    Width := 26;
    Height := 26;
  end;

  with edtUserName do begin
    Left := 149;
    Top := 192;
    Width := 200;
    Height := 21;
    Font.Height := -13;
  end;

  with edtPlainPassword do begin
    Left := 149;
    Top := 231;
    Width := 200;
    Height := 21;
    Font.Height := -13;
  end;

  with edtCipherPassword do begin
    Left := 149;
    Top := 231;
    Width := 200;
    Height := 21;
    Font.Height := -13;
  end;

  with ckbIsSavePassword do begin
    Left := 360;
    Top := 233;
  end;

  with lblLoadInfo do begin
    Left := 144;
    Top := 312;
    Width := 57;
    Height := 33;
    Font.Height := -12;
  end;

  with lblLoadProgress do begin
    Left := 72;
    Top := 312;
    Width := 345;
    Height := 33;
    Font.Height := -12;
  end;
end;

procedure TLoginMainUI.DoShowLoadProcess(AMsg: string; AProcessValue: Integer);
begin
  lblLoadProgress.Caption := Format('%d%%  ', [AProcessValue]) + AMsg;
  Update;
end;

procedure TLoginMainUI.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetWindowRgn(Handle, 0, False);
end;

procedure TLoginMainUI.FormResize(Sender: TObject);
begin
  DoCreateRoundWindow;
end;

procedure TLoginMainUI.FormShow(Sender: TObject);
begin
  Caption := 'FAIS登陆';
  Enabled := True;
  lblLoadProgress.Visible := False;
  edtPlainPassword.Visible := False;
  edtCipherPassword.Visible := True;
end;

procedure TLoginMainUI.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  AnimateWindow(Handle, 300, AW_BLEND or AW_HIDE);
end;

procedure TLoginMainUI.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) and IsWindowEnabled(Self.Handle) then begin
    imgLoginClick(nil);
  end;
end;

procedure TLoginMainUI.imgBackgroundMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // 鼠标按下左键移动窗体
  if Button = mbLeft then begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

procedure TLoginMainUI.imgCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  if FAppContext <> nil then begin
    FAppContext.ExitApp;
  end;
end;

procedure TLoginMainUI.imgLoginClick(Sender: TObject);
var
  LResult: Boolean;
  LErrorMsg: string;
begin
  LResult := False;
  Enabled := False;
  try
    if DoSimpleCheck(LErrorMsg) then begin
      DoSetWindowToUserInfo;
      if Assigned(FLoginFunc) then begin
        LResult := FLoginFunc;
      end else begin
        LResult := True;
      end;
    end else begin
      ShowLoginInfo(LErrorMsg);
    end;
  finally
    Enabled := True;
  end;
  // 表示登录成功
  if LResult then begin
    ModalResult := mrOk;
//    Hide;
  end;
end;

procedure TLoginMainUI.imgLoginMouseEnter(Sender: TObject);
begin
  if imgLogin.Enabled then begin
    DoLoadImage(imgLogin, 'LoginBtn_Hot.png');
  end;
end;

procedure TLoginMainUI.imgLoginMouseLeave(Sender: TObject);
begin
  DoLoadImage(imgLogin, 'LoginBtn.png');
end;

procedure TLoginMainUI.imgSettingClick(Sender: TObject);
var
  LRect: TRect;
  LMonitor: TMonitor;
  LLoginSettingUI: TLoginSettingUI;
begin
  LLoginSettingUI := TLoginSettingUI.Create(nil);
  try
    LLoginSettingUI.Parent := Self;
    LLoginSettingUI.Initialize(FAppContext);
    LMonitor := Screen.MonitorFromWindow(Self.Handle);
    if LMonitor = nil then begin
      LMonitor := Self.Monitor;
    end;
    LRect := LMonitor.WorkareaRect;
    LLoginSettingUI.Top := (LRect.Height - LLoginSettingUI.Height) div 2;
    LLoginSettingUI.Left := (LRect.Width - LLoginSettingUI.Width) div 2;
    if LLoginSettingUI.ShowModal = mrOK then begin
      LLoginSettingUI.UpdateLoginSettingDataToUserData;
    end;
  finally
    LLoginSettingUI.UnInitialize;
    LLoginSettingUI.Free;
  end;
end;

procedure TLoginMainUI.imgSettingMouseEnter(Sender: TObject);
begin
  if (Sender as TImage).Tag = 0 then begin
    DoLoadImage(imgSetting, 'Setting_Hot.png')
  end else begin
    DoLoadImage(imgClose, 'Close_Hot.png');
  end;
end;

procedure TLoginMainUI.imgSettingMouseLeave(Sender: TObject);
begin
  if (Sender as TImage).Tag = 0 then begin
    DoLoadImage(imgSetting, 'Setting.png')
  end else begin
    DoLoadImage(imgClose, 'Close.png');
  end;
end;

procedure TLoginMainUI.edtUserNameEnter(Sender: TObject);
begin
  if edtUserName.Text = LOGIN_USERNAME then begin
    edtUserName.Font.Color := $333333;
    edtUserName.Text := '';
  end;
end;

procedure TLoginMainUI.edtUserNameExit(Sender: TObject);
begin
  if edtUserName.Text = '' then begin
    edtUserName.Font.Color := $B7B7B7;
    edtUserName.Text := LOGIN_USERNAME;
  end;
end;

procedure TLoginMainUI.edtUserNameChange(Sender: TObject);
begin
  if edtUserName.Text = '' then begin
    edtCipherPassword.Font.Color := $00B7B7B7;
    edtCipherPassword.PasswordChar := #0;
    edtCipherPassword.Text := LOGIN_PASSWORD;
  end;
end;

procedure TLoginMainUI.edtCipherPasswordEnter(Sender: TObject);
begin
  if edtCipherPassword.Text = LOGIN_PASSWORD then begin
    edtCipherPassword.Font.Color := $00333333;
    edtCipherPassword.PasswordChar := '*';
    edtCipherPassword.Text := '';
  end;
  edtCipherPassword.SetFocus;
end;

procedure TLoginMainUI.edtCipherPasswordExit(Sender: TObject);
begin
  if edtCipherPassword.Text = '' then begin
    edtCipherPassword.Font.Color := $00B7B7B7;
    edtCipherPassword.PasswordChar := #0;
    edtCipherPassword.Text := LOGIN_PASSWORD;
  end;
end;

procedure TLoginMainUI.edtCipherPasswordChange(Sender: TObject);
begin
  // 记录有改变

end;

end.
