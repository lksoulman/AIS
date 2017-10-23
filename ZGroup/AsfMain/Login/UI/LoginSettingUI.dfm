object LoginSettingUI: TLoginSettingUI
  Left = 240
  Top = 205
  BorderStyle = bsDialog
  Caption = #30331#24405#35774#32622
  ClientHeight = 292
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object pagecontrolSetting: TRzPageControl
    Left = 0
    Top = 0
    Width = 380
    Height = 260
    Hint = ''
    ActivePage = sheetProxySetting
    Align = alClient
    Color = clWhite
    ParentColor = False
    ShowFocusRect = False
    ShowShadow = False
    TabColors.HighlightBar = 7846911
    TabColors.Shadow = 7846911
    TabColors.Unselected = clWhite
    TabIndex = 1
    TabOrder = 0
    UseGradients = False
    FixedDimension = 18
    object sheetServerSetting: TRzTabSheet
      Color = clWhite
      Caption = #26381#21153#22120#36873#25321
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lblServerList: TLabel
        Left = 35
        Top = 51
        Width = 66
        Height = 12
        Caption = #26381#21153#22120#21015#34920':'
        Transparent = True
      end
      object cmbServerList: TRzComboBox
        Left = 107
        Top = 48
        Width = 161
        Height = 20
        TabOrder = 0
      end
    end
    object sheetProxySetting: TRzTabSheet
      Color = clWhite
      Caption = #20195#29702#35774#32622
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gpbxIsUserProxy: TGroupBox
        Left = 18
        Top = 11
        Width = 341
        Height = 217
        Ctl3D = True
        DoubleBuffered = True
        ParentBackground = False
        ParentCtl3D = False
        ParentDoubleBuffered = False
        TabOrder = 0
        object lblProxyIP: TLabel
          Left = 18
          Top = 17
          Width = 42
          Height = 12
          Caption = #26381#21153#22120':'
          Enabled = False
        end
        object lblProxyPort: TLabel
          Left = 221
          Top = 18
          Width = 30
          Height = 12
          Caption = #31471#21475':'
          Enabled = False
        end
        object gpbxProxyType: TGroupBox
          Left = 19
          Top = 39
          Width = 128
          Height = 95
          TabOrder = 2
          object lblProxyType: TLabel
            Left = 3
            Top = 4
            Width = 72
            Height = 12
            Caption = #20195#29702#26381#22120#31867#22411
            Enabled = False
          end
          object rdbtnSocks5: TRzRadioButton
            Left = 15
            Top = 42
            Width = 55
            Height = 15
            Caption = 'SOCKS5'
            Enabled = False
            TabOrder = 0
          end
          object rdbtnSocks4: TRzRadioButton
            Left = 15
            Top = 62
            Width = 55
            Height = 15
            Caption = 'SOCKS4'
            Enabled = False
            TabOrder = 1
          end
          object rdbtnHttpProxy: TRzRadioButton
            Left = 15
            Top = 22
            Width = 67
            Height = 15
            Caption = 'Http'#20195#29702
            Enabled = False
            TabOrder = 2
          end
        end
        object gpbxUserInfo: TGroupBox
          Left = 156
          Top = 39
          Width = 167
          Height = 95
          TabOrder = 0
          object lblUserName: TLabel
            Left = 14
            Top = 29
            Width = 42
            Height = 12
            Caption = #29992#25143#21517':'
            Enabled = False
          end
          object lblPassword: TLabel
            Left = 14
            Top = 58
            Width = 30
            Height = 12
            Caption = #23494#30721':'
            Enabled = False
          end
          object lblUserInfo: TLabel
            Left = 3
            Top = 6
            Width = 48
            Height = 12
            Caption = #36523#20221#39564#35777
            Enabled = False
          end
          object edtUserName: TRzEdit
            Left = 60
            Top = 24
            Width = 95
            Height = 20
            Text = ''
            TabOrder = 0
          end
          object edtPassword: TRzEdit
            Left = 60
            Top = 53
            Width = 95
            Height = 20
            Text = ''
            TabOrder = 1
          end
        end
        object gpbxNTLM: TGroupBox
          Left = 18
          Top = 149
          Width = 307
          Height = 52
          TabOrder = 1
          object lblDomain: TLabel
            Left = 17
            Top = 21
            Width = 30
            Height = 12
            Caption = #22495#21517':'
            Enabled = False
          end
          object edtDomain: TRzEdit
            Left = 52
            Top = 17
            Width = 137
            Height = 20
            Text = ''
            TabOrder = 0
          end
        end
        object edtProxyIP: TRzEdit
          Left = 66
          Top = 13
          Width = 137
          Height = 20
          Text = ''
          TabOrder = 3
        end
        object sedtProxyPort: TRzSpinEdit
          Left = 269
          Top = 13
          Width = 54
          Height = 20
          AllowKeyEdit = True
          Max = 65535.000000000000000000
          Enabled = False
          ImeMode = imSKata
          TabOrder = 4
        end
        object chkIsNTLM: TRzCheckBox
          Left = 25
          Top = 140
          Width = 67
          Height = 15
          Caption = 'NTLM'#35748#35777
          Enabled = False
          State = cbUnchecked
          TabOrder = 5
          OnClick = chkIsNTLMClick
        end
      end
      object chkIsUseProxy: TRzCheckBox
        Left = 26
        Top = 3
        Width = 103
        Height = 15
        Caption = #20351#29992#20195#29702#26381#21153#22120
        State = cbUnchecked
        TabOrder = 1
        OnClick = chkIsUseProxyClick
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 260
    Width = 380
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TRzButton
      Left = 165
      Top = 8
      Width = 73
      Height = 20
      Caption = #30830#23450
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TRzButton
      Left = 264
      Top = 8
      Width = 61
      Height = 20
      Caption = #21462#28040
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
