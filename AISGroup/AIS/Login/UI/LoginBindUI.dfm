object LoginBindUI: TLoginBindUI
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FIAS'
  ClientHeight = 190
  ClientWidth = 411
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object edtBindAccount: TRzEdit
    Left = 80
    Top = 57
    Width = 265
    Height = 21
    Text = ''
    TabOrder = 0
  end
  object btnOk: TRzButton
    Left = 96
    Top = 112
    Width = 89
    Caption = #30830#23450
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TRzButton
    Left = 240
    Top = 112
    Width = 89
    ModalResult = 2
    Caption = #21462#28040
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
