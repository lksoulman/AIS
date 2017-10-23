unit ServiceExplorerUI;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  RzPanel,
  RzSplit,
  NxScrollControl,
  NxCustomGridControl,
  NxCustomGrid,
  NxGrid,
  NxColumns,
  NxDBGrid,
  NxDBColumns,
  Vcl.ComCtrls,
  RzTreeVw,
  RzButton,
  RzRadChk,
  RzRadGrp,
  Vcl.StdCtrls,
  RzTabs,
  RzEdit,
  Data.DB,
  GFData,
  GFDataSet,
  ErrorCode,
  AppContext,
  BasicService,
  AssetService;

type

  // Service Explorer UI
  TServiceExplorerUI = class(TForm)
    rzSpliterLR: TRzSplitter;
    rzSpliterUD: TRzSplitter;
    rzRichEdt: TRzRichEdit;
    rzPageControl: TRzPageControl;
    rzSheetData: TRzTabSheet;
    rzErrorStatus: TRzTabSheet;
    NextDBGridDataSource: TDataSource;
    rzMemErrorStatus: TRzMemo;
    NextDBGrid: TNextDBGrid;
    rzPanelBtns: TRzPanel;
    rzPanelHis: TRzPanel;
    rzRadioBtnBasic: TRzRadioButton;
    rzRadioBtnAsset: TRzRadioButton;
    rzBtnExec: TRzButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NextDBGridCellDblClick(Sender: TObject; ACol, ARow: Integer);
    procedure NextDBGridColumnAdded(Sender: TObject; Column: TNxDBCustomColumn);
    procedure NextDBGridColumnCreate(Sender: TObject; Field: TField;
      var ColumnClass: TNxDBColumnClass; var AddColumn: Boolean);
    procedure NextDBGridDrawCellBackground(Sender: TObject; ACol, ARow: Integer;
      CellRect: TRect; CellState: TCellState; var DefaultDrawing: Boolean);
    procedure NextDBGridHeaderDblClick(Sender: TObject; ACol: Integer);
    procedure NextDBGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rzBtnExecClick(Sender: TObject);
  private
    // GF Data
    FGFData: IGFData;
    // Application Context
    FAppContext: IAppContext;
    // Basic Service
    FBasicService: IBasicService;
    // Asset Service
    FAssetService: IAssetService;
  protected

    // Load Data
    procedure DoLoadData(ADataSet: TGFDataSet);
    // Show Status
    procedure DoShowStatus(AErrorInfo: WideString);
    // Service Data Arrive
    procedure DoServiceDataArrive(AGFData: IGFData);
    // Basic Service Execute
    procedure DoBasicServiceExecute(AIndicator: string);
    // Asset Service Execute
    procedure DoAssetServiceExecute(AIndicator: string);
  public
    // Initialize Resources(only execute once)
    procedure Initialize(AContext: IAppContext);
    // Releasing Resources(only execute once)
    procedure UnInitialize;
  end;

implementation

{$R *.dfm}

procedure TServiceExplorerUI.FormCreate(Sender: TObject);
begin
  Position := poScreenCenter;
  rzRadioBtnBasic.Checked := True;
end;

procedure TServiceExplorerUI.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TServiceExplorerUI.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_F5] then begin
    rzBtnExecClick(nil);
  end;
end;

procedure TServiceExplorerUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  if FAppContext <> nil then begin
    FBasicService := FAppContext.GetBasicService;
    FAssetService := FAppContext.GetAssetService;
  end;
end;

procedure TServiceExplorerUI.NextDBGridCellDblClick(Sender: TObject; ACol,
  ARow: Integer);
begin
//
end;

procedure TServiceExplorerUI.NextDBGridColumnAdded(Sender: TObject;
  Column: TNxDBCustomColumn);
begin
  if (Column.Field <> nil)
    and (Column.Field.DataType in [ftBCD, ftFmtBCD , ftLargeint]) then begin
    Column.Alignment := taRightJustify;
  end;
end;

procedure TServiceExplorerUI.NextDBGridColumnCreate(Sender: TObject;
  Field: TField; var ColumnClass: TNxDBColumnClass; var AddColumn: Boolean);
begin
  if Field.DataType in [ftBCD, ftFmtBCD, ftLargeint ] then begin
    ColumnClass := TNxDBTextColumn;
  end;
end;

procedure TServiceExplorerUI.NextDBGridDrawCellBackground(Sender: TObject; ACol,
  ARow: Integer; CellRect: TRect; CellState: TCellState;
  var DefaultDrawing: Boolean);
begin
  if (not (csSelected in CellState) and not(csEmpty in CellState))
    and (NextDBGrid.Columns[ACol] is TNxDBCustomColumn)
    and (NextDBGrid.Columns[ACol].Field <> nil)
    and NextDBGrid.Columns[ACol].Field.isNull then begin
    NextDBGrid.Canvas.Brush.Color := clInfoBk;
    NextDBGrid.Canvas.FillRect(CellRect);
    DefaultDrawing := false;
  end;
end;

procedure TServiceExplorerUI.NextDBGridHeaderDblClick(Sender: TObject;
  ACol: Integer);
begin
//
end;

procedure TServiceExplorerUI.NextDBGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  if NextDBGrid.RowCount = 0 then exit;

end;

procedure TServiceExplorerUI.UnInitialize;
begin
  FAssetService := nil;
  FBasicService := nil;
  FAppContext := nil;
end;

procedure TServiceExplorerUI.DoLoadData(ADataSet: TGFDataSet);
var
  LIndex: Integer;
begin
  NextDBGrid.BeginUpdate;
  try
    NextDBGridDataSource.DataSet := ADataSet;
    for LIndex:= 0 to NextDBGrid.Columns.Count - 1 do begin
      NextDBGrid.Columns[LIndex].Width := 100;
      NextDBGrid.Columns[LIndex].NullText := 'NULL';
    end;
  finally
    NextDBGrid.EndUpdate;
    NextDBGrid.Refresh;
  end;
end;

procedure TServiceExplorerUI.DoShowStatus(AErrorInfo: WideString);
begin
  rzMemErrorStatus.Lines.Add(AErrorInfo);
end;

procedure TServiceExplorerUI.DoServiceDataArrive(AGFData: IGFData);
var
  LDataSet: TGFDataSet;
begin
  if AGFData.GetErrorCode = ErrorCode_Success then begin
    if rzPageControl.ActivePageIndex <> 0 then begin
      rzPageControl.ActivePageIndex := 0;
    end;
    LDataSet := TGFDataSet.Create(AGFData);
    try
      DoLoadData(LDataSet);
//      rzMemErrorStatus.Clear;
//      DoShowStatus(Format('( %d rows )', [LDataSet.RecordCount]));
    finally
//      LDataSet.Free;
    end;
  end else begin
    if rzPageControl.ActivePageIndex <> 1 then begin
      rzPageControl.ActivePageIndex := 1;
    end;
    rzMemErrorStatus.Clear;
    DoShowStatus(AGFData.GetErrorInfo);
    DoShowStatus(FAppContext.GetErrorInfo(AGFData.GetErrorCode));
  end;
  if FGFData <> nil then begin
    FGFData := nil;
  end;
end;

procedure TServiceExplorerUI.DoBasicServiceExecute(AIndicator: string);
begin
  if FGFData <> nil then begin
    FGFData.Cancel;
    FGFData := nil;
  end;
  if FBasicService <> nil then begin
    FGFData := FBasicService.AsyncPOST(AIndicator, DoServiceDataArrive, 0);
  end;
end;

procedure TServiceExplorerUI.DoAssetServiceExecute(AIndicator: string);
begin
  if FGFData <> nil then begin
    FGFData.Cancel;
    FGFData := nil;
  end;
  if FAssetService <> nil then begin
    FGFData := FAssetService.AsyncPOST(AIndicator, DoServiceDataArrive, 0);
  end;
end;

procedure TServiceExplorerUI.rzBtnExecClick(Sender: TObject);
var
  LIndicator: string;
begin
  LIndicator := Trim(rzRichEdt.SelText);
  if LIndicator <> '' then begin
    if rzRadioBtnBasic.Checked then begin
      DoBasicServiceExecute(LIndicator);
    end else begin
      DoAssetServiceExecute(LIndicator);
    end;
  end;
end;

end.
