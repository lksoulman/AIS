object UpdateMainForm: TUpdateMainForm
  Left = 0
  Top = 0
  Caption = 'UpdateMainForm'
  ClientHeight = 591
  ClientWidth = 1005
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
  object BtnGenerateUpdateList: TButton
    Left = 368
    Top = 216
    Width = 153
    Height = 25
    Caption = 'BtnGenerateUpdateList'
    TabOrder = 0
    OnClick = BtnGenerateUpdateListClick
  end
  object BtnBackup: TButton
    Left = 368
    Top = 272
    Width = 75
    Height = 25
    Caption = 'BtnBackup'
    TabOrder = 1
    OnClick = BtnBackupClick
  end
  object BtnCompress: TButton
    Left = 368
    Top = 320
    Width = 75
    Height = 25
    Caption = 'BtnCompress'
    TabOrder = 2
    OnClick = BtnCompressClick
  end
  object BtnUncompress: TButton
    Left = 368
    Top = 376
    Width = 105
    Height = 25
    Caption = 'BtnUncompress'
    TabOrder = 3
    OnClick = BtnUncompressClick
  end
  object BtnGenerateNeedUpdateList: TButton
    Left = 368
    Top = 424
    Width = 153
    Height = 25
    Caption = 'BtnGenerateNeedUpdateList'
    TabOrder = 4
    OnClick = BtnGenerateNeedUpdateListClick
  end
  object BtnUpgrade: TButton
    Left = 368
    Top = 480
    Width = 105
    Height = 25
    Caption = 'BtnUpgrade'
    TabOrder = 5
    OnClick = BtnUpgradeClick
  end
end
