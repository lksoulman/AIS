object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 433
  ClientWidth = 775
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object BtnServiceExplorer: TButton
    Left = 120
    Top = 64
    Width = 121
    Height = 25
    Caption = 'BtnServiceExplorer'
    TabOrder = 0
    OnClick = BtnServiceExplorerClick
  end
  object BtnProAuth: TButton
    Left = 120
    Top = 128
    Width = 75
    Height = 25
    Caption = 'BtnProAuth'
    TabOrder = 1
    OnClick = BtnProAuthClick
  end
  object BtnHqAuth: TButton
    Left = 120
    Top = 184
    Width = 75
    Height = 25
    Caption = 'BtnHqAuth'
    TabOrder = 2
    OnClick = BtnHqAuthClick
  end
  object BtnBaseCache: TButton
    Left = 120
    Top = 232
    Width = 89
    Height = 25
    Caption = 'BtnBaseCache'
    TabOrder = 3
    OnClick = BtnBaseCacheClick
  end
  object BtnSecuMain: TButton
    Left = 256
    Top = 232
    Width = 75
    Height = 25
    Caption = 'BtnSecuMain'
    TabOrder = 4
    OnClick = BtnSecuMainClick
  end
  object BtnUpdate: TButton
    Left = 120
    Top = 280
    Width = 75
    Height = 25
    Caption = 'BtnUpdate'
    TabOrder = 5
    OnClick = BtnUpdateClick
  end
  object BtnMainFrameUI: TButton
    Left = 120
    Top = 328
    Width = 105
    Height = 25
    Caption = 'BtnMainFrameUI'
    TabOrder = 6
    OnClick = BtnMainFrameUIClick
  end
end
