unit KeyFairyUI;

interface

uses
  RzButton, FloatWin, CommonFunc, KeyFairyGrid, QuoteCommLibrary,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DateUtils, AppControllerInf, StrUtils,
  AxCtrls, Activex, {ComUnit,} Buttons, Vcl.Mask, RzEdit, Vcl.ComCtrls, RzListVw,
  NxColumns, NxColumnClasses, NxScrollControl, NxCustomGridControl,
  NxCustomGrid, NxGrid, Vcl.Imaging.pngimage, UserBehaviorConst;

type
  // PSinkRec = ^TSinkRec;
  // TSinkRec = record
  // SinkID: Integer;
  // WNLinkInex: Integer;
  // SinkOrder: Integer;
  // end;

  TKeyFairyMode = (kfDisplay, kfChoose);
  // TKeyFairyReturnKey = (rkReturn, rkAdd, rkSub);
  pStockInfoRec = ^StockInfoRec;

  TOnFairyChange = procedure(Key: string) of Object;

  TKeyFairyUI = class(TForm)
    Panel: TPanel;
    Panel2: TPanel;
    Edit1: TRzEdit;
    Timer1: TTimer;
    pnlTop: TPanel;
    PnlGrid: TPanel;
    ImgTitle: TImage;
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbSettingsClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure NextGridCellDblClick(Sender: TObject; ACol, ARow: Integer);
    procedure NextGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState);
    procedure NextGridEnter(Sender: TObject);
    procedure NextGridDrawCellBackground(Sender: TObject; ACol, ARow: Integer; CellRect: TRect; CellState: TCellState;
      var DefaultDrawing: Boolean);
    procedure NextGridPostDraw(Sender: TObject);

  private
    p_WNController: IGilAppController;
    FIsReturnDown: Boolean;
    FOnFairyChange: TOnFairyChange;
    FSelRecNo, FSelInnerCode: Integer;
    FFloatWin: TFloatWin;
    FNextGrid: TKeyFairyGrid;
    procedure OnReturnDown;
    function GetFairyStr: string;
    procedure SetFairyStr(const Value: string);

    procedure SelectSecu(Row: Integer);

  public
    procedure PopInit(Sender: TObject);
    procedure Clear;
    procedure InitSkin();
    procedure InitGrid();
    procedure ResetGridSize(IsPnlTop: Boolean);

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddStock(InnerCode: Integer; SecuCode: string; SecuName: string; Category: string);
    property OnFairyChange: TOnFairyChange read FOnFairyChange write FOnFairyChange;
    property WNController: IGilAppController write p_WNController;
    property FairyStr: string read GetFairyStr write SetFairyStr;
    property SelRecNo: Integer read FSelRecNo;
    property SelInnerCode: Integer read FSelInnerCode;
    property FloatWin: TFloatWin read FFloatWin;
    property NextGrid: TKeyFairyGrid read FNextGrid;
  end;

implementation

uses IniFiles, Math;

// const
// COLOR_BACKGROUND_ACTIVE = $0994F9;
// COLOR_BACKGROUND_DEACTIVE = $D7922C;
// COLOR_FONT_ACTIVE = clBlack;
// COLOR_FONT_DEACTIVE = clWhite;
// COLOR_BACKGROUND_ACTIVE = $0020DF;
// COLOR_BACKGROUND_DEACTIVE = $D2D2D2;
// COLOR_FONT_ACTIVE = clWhite;
// COLOR_FONT_DEACTIVE = $575757;

{$R *.dfm}
{ Tw_KeyFairy }

function TrimSqlString(const SQL: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(SQL) do
  begin
    if SQL[i] = #39 then
      Result := Result + #39 + #39
    else
      Result := Result + SQL[i];
  end;
end;

procedure TKeyFairyUI.Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Index: Integer;
begin
  if Key = VK_RETURN then
  begin
    if Timer1.Enabled then
    begin
      FIsReturnDown := True;
      // OutputDebugString('Tw_KeyFairy.Edit1KeyDown, Wait DataArrive');
    end
    else
      OnReturnDown;
    Key := 0;
  end
  else if Key = VK_UP then
  begin
    Index := NextGrid.SelectedRow;
    if Index > 0 then
    begin
      NextGrid.ClearSelection;
      NextGrid.SelectedRow := index - 1;
      if not NextGrid.IsRowInView(NextGrid.SelectedRow) then
        NextGrid.VerBar.Position := NextGrid.VerBar.Position - 1;
    end;
    Key := 0;
  end
  else if Key = VK_DOWN then
  begin
    Index := NextGrid.SelectedRow;
    if Index < NextGrid.RowCount - 1 then
    begin
      NextGrid.SelectedRow := Index + 1;
      if not NextGrid.IsRowInView(NextGrid.SelectedRow) then
        NextGrid.VerBar.Position := NextGrid.VerBar.Position + 1;

    end;
    Key := 0;
  end
  else if not(ssShift in Shift) and (Key = VK_END) then
  begin
    // if NextGrid.RowCount > 0 then
    // begin
    // NextGrid.ClearSelection;
    // NextGrid.SelectedRow := 0;
    // NextGrid.StartRowCount
    // end;
    Key := 0;
  end
  else if not(ssShift in Shift) and (Key = VK_HOME) then
  begin
    // viewList.DataController.GotoFirst;
    Key := 0;
  end
  else if Key = VK_PRIOR then
  begin // PageUp
    // (viewList.DataController as IcxGridDataController).DoScrollPage(False);
    Key := 0;
  end
  else if Key = VK_NEXT then
  begin // PageDown
    // (viewList.DataController as IcxGridDataController).DoScrollPage(True);
    Key := 0;
  end
  else if Key = VK_LEFT then
  begin
    // GotoPrevRange;
    Key := VK_LEFT;
  end
  else if Key = VK_RIGHT then
  begin
    // GotoNextRange;
    Key := VK_RIGHT;
  end { else if (Key = VK_ADD) or ((Key = 187) and (Shift = [ssShift])) then begin //shift + 187Îª´ó¼üÅÌ¼ÓºÅ
    if Timer1.Enabled then
    begin
    FIsReturnDown := True;
    //OutputDebugString('Tw_KeyFairy.Edit1KeyDown, Wait DataArrive');
    end
    else
    OnReturnDown;
    FReturnKey := rkAdd;
    Key := 0;
    end else if (Key = VK_SUBTRACT) or (Key = 189) then begin  //189Îª´ó¼üÅÌ¼õºÅ
    if Timer1.Enabled then
    begin
    FIsReturnDown := True;
    //OutputDebugString('Tw_KeyFairy.Edit1KeyDown, Wait DataArrive');
    end
    else
    OnReturnDown;
    FReturnKey := rkSub;
    Key := 0;
    end };
end;

function TKeyFairyUI.GetFairyStr: string;
begin
  Result := Edit1.Text;
end;

procedure TKeyFairyUI.NextGridCellDblClick(Sender: TObject; ACol, ARow: Integer);
begin
  SelectSecu(ARow);
end;

procedure TKeyFairyUI.NextGridCustomDrawCell(Sender: TObject; ACol, ARow: Integer; CellRect: TRect;
  CellState: TCellState);

begin
  // OutputDebugString('A');
  // else
  // if csFocused in CellState then
  // begin
  // Windows.AlphaBlend(NextGrid.Canvas.Handle, 0, 0,
  // CellRect.Width, CellRect.Height, NextGrid.Canvas.Handle,
  // 0, 0, CellRect.Width, CellRect.Height, 199);
  //
  // NextGrid.Canvas.Brush.Style := bsClear ;
  // NextGrid.Canvas.Brush.Color := NextGrid.SelectionColor;
  // NextGrid.Canvas.FillRect(CellRect);
  // end;
  NextGrid.Canvas.Font.Assign(NextGrid.Font);
  // NextGrid.Canvas.TextRect();
end;

procedure TKeyFairyUI.NextGridDrawCellBackground(Sender: TObject; ACol, ARow: Integer; CellRect: TRect;
  CellState: TCellState; var DefaultDrawing: Boolean);
// var
// BF:BLENDFUNCTION;
begin
  DefaultDrawing := False;
  if (csSelected in CellState) or (csFocused in CellState) then
  begin
    NextGrid.Canvas.Brush.Color := NextGrid.SelectionColor;
  end
  else
    NextGrid.Canvas.Brush.Color := NextGrid.Color;
  NextGrid.Canvas.FillRect(CellRect);
end;

procedure TKeyFairyUI.NextGridEnter(Sender: TObject);
begin
  // Edit1.SetFocus;
end;

procedure TKeyFairyUI.NextGridPostDraw(Sender: TObject);
// var
// R:TRect;
begin
  // R.Top := 0;
  // R.Left := 0;
  // R.Width := NextGrid.Width - 1;
  // R.Height := NextGrid.Height - 1;
  // NextGrid.Canvas.Brush.Color := NextGrid.GridLinesColor;
  // NextGrid.Canvas.FrameRect(R);
end;

procedure TKeyFairyUI.Edit1Change(Sender: TObject);
begin
  Timer1.Enabled := True;
  FIsReturnDown := False;
end;

procedure TKeyFairyUI.PopInit(Sender: TObject);
begin
  InitSkin;
  FSelRecNo := -1;
  FSelInnerCode := 0;
  Edit1.SelStart := Length(Edit1.Text);
  Edit1.SelLength := 0;
end;

procedure TKeyFairyUI.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  NextGrid.BeginUpdate;
  try
    NextGrid.ClearRows;
    if Assigned(FOnFairyChange) then
      FOnFairyChange(Edit1.Text);
    if NextGrid.RowCount > 0 then
      NextGrid.SelectFirstRow;
  finally
    NextGrid.EndUpdate();
  end;
  if FIsReturnDown then
    OnReturnDown;
end;

procedure TKeyFairyUI.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
  p_WNController := nil;
end;

procedure TKeyFairyUI.AddStock(InnerCode: Integer; SecuCode: string; SecuName: string; Category: string);
var
  i: Integer;
begin
  NextGrid.BeginUpdate;
  try
    i := NextGrid.AddRow();
    NextGrid.Cell[NextGrid.NCInnerCode.Index, i].AsInteger := InnerCode;
    NextGrid.Cell[NextGrid.NCCode.Index, i].Asstring := SecuCode;
    NextGrid.Cell[NextGrid.NCName.Index, i].Asstring := SecuName;
    NextGrid.Cell[NextGrid.NCCategory.Index, i].Asstring := Category;
    // NextGrid.Cell[NTCRecNO.Index,i].AsInteger := RecNO;
  finally
    NextGrid.EndUpdate();
  end;
end;

procedure TKeyFairyUI.Clear;
begin
  NextGrid.ClearRows;
end;

procedure TKeyFairyUI.InitSkin();
var
  Apng: TpngImage;
begin
  // 14450735;

  FFloatWin.IsBorder := True;
  FFloatWin.BorderCorlor := HexToIntDef(p_WNController.Config(ctSkin, 'PopWinBorder'), $999999);
  Edit1.ParentColor := False;
  Edit1.ParentFont := False;
  Edit1.Font.Color := HexToIntDef(p_WNController.Config(ctSkin, 'CKeyFairyText'), $00333333);
  Edit1.Color := HexToIntDef(p_WNController.Config(ctSkin, 'CKeyFairy'), $00FFFFFF);
  if p_WNController.FontRatio = Const_ScreenResolution_1080P then
  begin
    NextGrid.RowSize := 22;
    Edit1.Font.Size := StrToIntDef(p_WNController.Config(ctSkin, 'FSKeyFairy'), 9) + 2;
  end
  else
  begin
    NextGrid.RowSize := 18;
    Edit1.Font.Size := StrToIntDef(p_WNController.Config(ctSkin, 'FSKeyFairy'), 9);
  end;
  Edit1.Font.Name := p_WNController.Config(ctSkin, 'FNKeyFairy');
  Edit1.Font.Color := HexToIntDef(p_WNController.Config(ctSkin, 'CKeyFairyText'), $00636363);
  Edit1.FrameVisible := True;
  Edit1.FrameColor := HexToIntDef(p_WNController.Config(ctSkin, 'CKeyFairyFrame'), $00CCCCCC);
  // <Color Key="CKeyFairyFrame" Val="0x00CCCCCC"/>
  FFloatWin.Color := Edit1.Color;
  FFloatWin.Font.Assign(Edit1.Font);
  // Panel2.ParentColor := False;
  // Panel2.ParentFont := False;
  Panel2.Color := Edit1.Color;
  pnlTop.Color := Edit1.Color;
  pnlTop.Font.Assign(Edit1.Font);

  Apng := TpngImage.Create;
  try
    Apng.LoadFromResourceName(p_WNController.GetSkinInstance, 'KeyFairyTitle');
    ImgTitle.Picture.Assign(Apng);
  finally
    Apng.Free;
  end;

  NextGrid.ParentFont := False;
  NextGrid.ParentColor := False;
  NextGrid.Color := Edit1.Color;
  NextGrid.GridLinesColor := Edit1.Color;
  NextGrid.Font.Assign(Edit1.Font);

  NextGrid.NCCode.Font.Assign(NextGrid.Font);
  NextGrid.NCName.Font.Assign(NextGrid.Font);
  NextGrid.NCCategory.Font.Assign(NextGrid.Font);
  // NextGrid.
  NextGrid.HighlightedTextColor := Edit1.Font.Color;
  NextGrid.SelectionColor := HexToIntDef(p_WNController.Config(ctSkin, 'CKeyFairySel'), $00DCECF9);
  NextGrid.AppearanceOptions := NextGrid.AppearanceOptions + [aoHideFocus];
  // Edit1.FrameColor := $E4BA8B;
  // Edit1.FrameHotColor := $E4BA8B;
  // NextGrid.GridLinesColor := $E4BA8B;
  // NextGrid.BorderStyle := bsNone;
  // NextGrid.VerBar.Instance := p_WNController.GetSkinInstance;
  NextGrid.VerBar.UpdateSkin(p_WNController);

end;

procedure TKeyFairyUI.InitGrid();
begin
  NextGrid.VerBar.Parent := PnlGrid;
  NextGrid.VerBar.Align := alRight;
  NextGrid.Parent := PnlGrid;
  NextGrid.Align := alClient;
  NextGrid.BorderStyle := bsNone;
  NextGrid.AppearanceOptions := NextGrid.AppearanceOptions - [aoHideSelection];
  NextGrid.Options := NextGrid.Options + [goCanHideColumn, goDisableColumnMoving, goSelectFullRow] - [goHeader];
  NextGrid.ReadOnly := True;
  NextGrid.RowSize := 18;
  NextGrid.OnCellClick := NextGridCellDblClick;
  NextGrid.OnCustomDrawCell := NextGridCustomDrawCell;
  NextGrid.OnEnter := NextGridEnter;
  NextGrid.OnDrawCellBackground := NextGridDrawCellBackground;
  NextGrid.OnPostDraw := NextGridPostDraw;
  NextGrid.Init;

end;

procedure TKeyFairyUI.ResetGridSize(IsPnlTop: Boolean);
begin
  pnlTop.Visible := IsPnlTop;
  if pnlTop.Visible then
    PnlGrid.Height := Panel.Height - Edit1.Height - 12 - pnlTop.Height
  else
    PnlGrid.Height := Panel.Height - Edit1.Height - 12;
end;

constructor TKeyFairyUI.Create(AOwner: TComponent);
begin
  inherited;
  FFloatWin := TFloatWin.CreateNew(nil);
  FNextGrid := TKeyFairyGrid.Create(nil);
  InitGrid;
end;

destructor TKeyFairyUI.Destroy;
begin
  if FFloatWin <> nil then
    FFloatWin.PopClose(False);
  FreeAndNil(FNextGrid);
  FreeAndNil(FFloatWin);
  p_WNController := nil;
  inherited;
end;

procedure TKeyFairyUI.sbSettingsClick(Sender: TObject);
// var
// lc_Form: Tw_KeyFairyRangeSetup;
begin
  // lc_Form := Tw_KeyFairyRangeSetup.Create(nil);
  // try
  // lc_Form.InitDefines(FRangeDefines);
  // if lc_Form.ShowModal = mrOk then
  // begin
  // SaveUserRange(lc_Form.DefineResult);
  // GenUserRange(lc_Form.DefineResult);
  // InitButtons;
  // Timer1.Enabled := True;
  // end;
  // finally
  // lc_Form.Free;
  // end;
end;

procedure TKeyFairyUI.SelectSecu(Row: Integer);
var
  tmpNumKey: Integer;
begin
  if (Row > -1) and (Row < NextGrid.RowCount) then
  begin
    FSelInnerCode := NextGrid.Cell[NextGrid.NCInnerCode.Index, Row].AsInteger;
    if TryStrToInt(NextGrid.Cell[NextGrid.NCCode.Index, Row].AsString, tmpNumKey) then
    begin
      if tmpNumKey in [81 .. 89] then
        p_WNController.AddUserBehavior(Con_NumKeys[tmpNumKey - 81])
      else if tmpNumKey = 812 then
        p_WNController.AddUserBehavior(Con_NumKeys[9]);
    end;
    // FSelSinkID := NextGrid.Cell[NTCSinkID.Index,Row].asString;
    // FSelRecNo := NextGrid.Cell[NTCRecNO.Index,Row].asInteger;
    GetParentForm(Self.Panel).ModalResult := mrOk;
  end
  else
    GetParentForm(Self.Panel).ModalResult := mrCancel;
end;

procedure TKeyFairyUI.SetFairyStr(const Value: string);
begin
  Edit1.OnChange := nil;
  Edit1.Text := UpperCase(Value);
  Edit1.OnChange := Edit1Change;
  Edit1.OnChange(Edit1);
end;

// procedure Tw_KeyFairy.sbHelpClick(Sender: TObject);
// begin
// p_WNController.WNCreateModuleByAlisa('NetIII_¼üÅÌ¾«Áé°ïÖú', '', False);
// end;

procedure TKeyFairyUI.OnReturnDown;
begin
  SelectSecu(NextGrid.SelectedRow);
end;

procedure TKeyFairyUI.Edit1KeyPress(Sender: TObject; var Key: Char);
begin

  if not(p_WNController.GetKeyFairyMng.IskeyFairyString(Key) or (Word(Key) in [VK_BACK, VK_UP, VK_DOWN, VK_RETURN,
    VK_DELETE])) then
  begin
    Key := #0;
  end;
  if (Key >= 'a') and (Key <= 'z') then
  begin
    Key := Char(Word(Key) - 32);
  end;

end;

end.
