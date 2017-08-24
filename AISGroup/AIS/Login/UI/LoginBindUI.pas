unit LoginBindUI;

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
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  RzButton,
  StdCtrls,
  Mask,
  RzEdit;

type

  // 绑定用户窗口
  TLoginBindUI = class(TForm)
    // 绑定账号
    edtBindAccount: TRzEdit;
    // 确定按钮
    btnOk: TRzButton;
    // 取消按钮
    btnCancel: TRzButton;
    // 单击确定按钮
    procedure btnOkClick(Sender: TObject);
    // 单击取消按钮
    procedure btnCancelClick(Sender: TObject);
    // 窗口展示
    procedure FormShow(Sender: TObject);
    // 键盘按下
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  public
    // 窗口创建参数
    procedure CreateParams(var Params: TCreateParams); override;
    // 获取绑定账号
    function GetBindAccount: string;
  end;

implementation

{$R *.dfm}

procedure TLoginBindUI.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TLoginBindUI.btnOkClick(Sender: TObject);
begin
  if trim(edtBindAccount.Text) = '' then
  begin
    MessageBox(Self.Handle, 'License不能为空。', '提示', MB_OK);
    Exit;
  end;
  ModalResult := mrOk;
end;

procedure TLoginBindUI.CreateParams(var Params: TCreateParams);
begin
  Params.ExStyle := Params.ExStyle or WS_EX_TOPMOST;
  inherited;
  edtBindAccount.TabStop := True;
  btnOk.TabStop := True;
  btnCancel.TabStop := True;
  edtBindAccount.TabOrder := 0;
  btnOk.TabOrder := 1;
  btnCancel.TabOrder := 2;
end;

function TLoginBindUI.GetBindAccount: string;
begin
  Result := edtBindAccount.Text;
end;

procedure TLoginBindUI.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
    btnOkClick(nil);
end;

procedure TLoginBindUI.FormShow(Sender: TObject);
begin
  Caption := 'FAIS终端License绑定';
end;

end.
