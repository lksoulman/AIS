object ServiceExplorerUI: TServiceExplorerUI
  Left = 0
  Top = 0
  Caption = 'ServiceExplorerUI'
  ClientHeight = 672
  ClientWidth = 1105
  Color = clWindow
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Times New Roman'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 15
  object rzSpliterLR: TRzSplitter
    Left = 0
    Top = 0
    Width = 1105
    Height = 672
    Position = 220
    Percent = 20
    SplitterStyle = ssBump
    SplitterWidth = 6
    Align = alClient
    Color = clWindow
    TabOrder = 0
    BarSize = (
      220
      0
      226
      672)
    UpperLeftControls = (
      rzPanelHis)
    LowerRightControls = (
      rzSpliterUD)
    object rzPanelHis: TRzPanel
      Left = 0
      Top = 0
      Width = 220
      Height = 672
      Align = alClient
      BorderInner = fsFlat
      BorderOuter = fsNone
      Color = clWindow
      TabOrder = 0
    end
    object rzSpliterUD: TRzSplitter
      Left = 0
      Top = 0
      Width = 879
      Height = 672
      Orientation = orVertical
      Position = 368
      Percent = 55
      SplitterStyle = ssBump
      SplitterWidth = 6
      Align = alClient
      BorderOuter = fsButtonUp
      TabOrder = 0
      VisualStyle = vsGradient
      BarSize = (
        2
        370
        877
        376)
      UpperLeftControls = (
        rzRichEdt
        rzPanelBtns)
      LowerRightControls = (
        rzPageControl)
      object rzRichEdt: TRzRichEdit
        Left = 0
        Top = 41
        Width = 875
        Height = 327
        Align = alClient
        Font.Charset = GB2312_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Zoom = 100
      end
      object rzPanelBtns: TRzPanel
        Left = 0
        Top = 0
        Width = 875
        Height = 41
        Align = alTop
        BorderInner = fsGroove
        BorderOuter = fsNone
        Color = clWindow
        TabOrder = 1
        object rzRadioBtnBasic: TRzRadioButton
          Left = 24
          Top = 13
          Width = 48
          Height = 17
          Caption = 'Basic'
          FocusColor = clRed
          HighlightColor = clRed
          LightTextStyle = True
          TabOrder = 0
        end
        object rzRadioBtnAsset: TRzRadioButton
          Left = 88
          Top = 13
          Width = 51
          Height = 17
          Caption = 'Asset'
          HighlightColor = clRed
          LightTextStyle = True
          TabOrder = 1
        end
        object rzBtnExec: TRzButton
          Left = 157
          Top = 7
          Caption = 'Exec (F5)'
          Color = clWindow
          TabOrder = 2
          OnClick = rzBtnExecClick
        end
      end
      object rzPageControl: TRzPageControl
        Left = 0
        Top = 0
        Width = 875
        Height = 294
        Hint = ''
        ActivePage = rzSheetData
        Align = alClient
        TabIndex = 0
        TabOrder = 0
        TabOrientation = toBottom
        FixedDimension = 21
        object rzSheetData: TRzTabSheet
          Caption = 'Data'
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 273
          object NextDBGrid: TNextDBGrid
            Left = 0
            Top = 0
            Width = 873
            Height = 271
            Touch.InteractiveGestures = [igPan, igPressAndTap]
            Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
            Align = alClient
            AppearanceOptions = [aoAlphaBlendedSelection, aoBoldTextSelection, aoHideSelection, aoHighlightSlideCells, aoIndicateSelectedCell, aoIndicateSortedColumn]
            Caption = ''
            GridLinesStyle = lsActiveRows
            Options = [goGrid, goHeader, goIndicator, goMultiSelect]
            TabOrder = 0
            TabStop = True
            OnCellDblClick = NextDBGridCellDblClick
            OnDrawCellBackground = NextDBGridDrawCellBackground
            OnHeaderDblClick = NextDBGridHeaderDblClick
            OnKeyDown = NextDBGridKeyDown
            DataSource = NextDBGridDataSource
            OnColumnAdded = NextDBGridColumnAdded
            OnColumnCreate = NextDBGridColumnCreate
            ExplicitHeight = 273
          end
        end
        object rzErrorStatus: TRzTabSheet
          Caption = 'ErrorStatus'
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 267
          object rzMemErrorStatus: TRzMemo
            Left = 0
            Top = 0
            Width = 873
            Height = 271
            Align = alClient
            TabOrder = 0
            ExplicitHeight = 267
          end
        end
      end
    end
  end
  object NextDBGridDataSource: TDataSource
    Left = 394
    Top = 429
  end
end
