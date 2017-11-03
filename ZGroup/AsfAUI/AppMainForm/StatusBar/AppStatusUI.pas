unit AppStatusUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º App Status Bar UI
// Author£º      lksoulman
// Date£º        2017-10-31
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  GDIPAPI,
  GDIPOBJ,
  FrameUI,
  RenderDC,
  AppStatus,
  RenderGDI,
  RenderUtil,
  AppContext,
  CommonLock,
  ComponentUI,
  Generics.Collections;

type

  TAppStatusUI = class;

  // App Status Item
  TAppStatusItem = class(TComponentUI)
  private
    // Width
    FWidth: Integer;
    // Parent
    FAppStatusUI: TAppStatusUI;
  protected
    // Calc Rect
    procedure DoCalcRect; virtual;
    // Update Data
    procedure DoUpdateData; virtual;
  public
    // Constructor
    constructor Create(AParent: TObject); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize; virtual;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;

    property Width: Integer read FWidth write FWidth;
  end;

  TAppHqType = (hstLeft, hstRight);

  // App Hq Item
  TAppHqItem = class(TAppStatusItem)
  private
    // Secu Abbr
    FSecuAbbr: string;
    // Turnover
    FTurnover: string;
    // NowPrice High Low
    FNowPriceHL: string;
    // Color Value
    FColorValue: Integer;
    // Current Index
    FCurrIndex: Integer;
    // Item Count
    FItemCount: Integer;
    // SecuAbbr Rect
    FSecuAbbrRectEx: TRect;
    // Turnover Rect
    FTurnoverRectEx: TRect;
    // NowPrice Rect
    FNowPriceHLRectEx: TRect;
    // Hq Type
    FAppHqType: TAppHqType;
  protected
    // Calc Rect
    procedure DoCalcRect; override;
    // Update Data
    procedure DoUpdateData; override;
    // Increment Item Curr Index
    procedure DoIncrementItemCurrIndex;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;

    property AppHqType: TAppHqType read FAppHqType write FAppHqType;
  end;

  // App News Item
  TAppNewsItem = class(TAppStatusItem)
  private
  protected
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;
  end;

  // App Time Item
  TAppTimeItem = class(TAppStatusItem)
  private
  protected
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;
  end;

  // App Alarm Item
  TAppAlarmItem = class(TAppStatusItem)
  private
  protected
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;
  end;

  // App Report Item
  TAppReportItem = class(TAppStatusItem)
  private
  protected
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;
  end;

  // App Network Item
  TAppNetworkItem = class(TAppStatusItem)
  private
  protected
    // Calc Rect
    procedure DoCalcRect; override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;
  end;

  // App Status UI
  TAppStatusUI = class(TFrameUI)
  private
    // Lock
    FLock: TCSLock;
    // App Status
    FAppStatus: IAppStatus;
    // App Context
    FAppContext: IAppContext;
    // News Item Index
    FNewsItemIndex: Integer;
    // News Item Index
    FAppNewsItem: TAppStatusItem;
    // Status Items
    FAppStatusItems: TList<TAppStatusItem>;
  protected
    // Load Resource
    procedure DoLoadResources;
    // Load Resource
    procedure DoLoadResource(AComponent: TComponentUI);
    // Init Status Items
    procedure DoInitStatusItems;
    // Calc Status Items
    procedure DoCalcStatusItems;
    // Update Data
    procedure DoStatusItemsUpdateData;
    // Clear Items
    procedure DoClear(AItems: TList<TAppStatusItem>);
    // Size
    procedure DoSize(AWidth: Integer; AHeight: Integer); override;
    // Paint Backgroud
    procedure DoPaintBackground(AInvalidateRect: TRect); override;
    // Paint Components
    procedure DoPaintComponents(AInvalidateRect: TRect); override;
    // Mouse Move
    procedure DoMouseMove(AMousePt: TPoint; AKeys: Integer); override;
    // Click Component
    procedure DoClickComponent(AComponent: TComponentUI); override;
    // Find Component
    function DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; override;
  public
    // Constructor
    constructor Create(AStatus: IAppStatus); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
  end;

implementation

{ TAppStatusItem }

constructor TAppStatusItem.Create(AParent: TObject);
begin
  inherited Create;
  FAppStatusUI := TAppStatusUI(AParent);
end;

destructor TAppStatusItem.Destroy;
begin
  inherited;
end;

procedure TAppStatusItem.Initialize;
begin

end;

procedure TAppStatusItem.DoCalcRect;
begin

end;

procedure TAppStatusItem.DoUpdateData;
begin

end;

procedure TAppStatusItem.Paint(ARenderDC: TRenderDC);
begin
  inherited;

end;

{ TAppHqItem }

constructor TAppHqItem.Create(AParent: TObject);
begin
  inherited Create(AParent);
  FWidth := 260;
  FAppHqType := hstLeft;
  FItemCount := 0;
  FCurrIndex := 0;
  FColorValue := 0;
end;

destructor TAppHqItem.Destroy;
begin

  inherited;
end;

procedure TAppHqItem.DoCalcRect;
begin
  FSecuAbbrRectEx := FRectEx;
  FSecuAbbrRectEx.Left := 10 + FSecuAbbrRectEx.Left;
  FSecuAbbrRectEx.Right := FSecuAbbrRectEx.Left + 40;

  FNowPriceHLRectEx := FRectEx;
  FNowPriceHLRectEx.Left := FSecuAbbrRectEx.Right + 10;
  FNowPriceHLRectEx.Right := FNowPriceHLRectEx.Left + 150;

  FTurnoverRectEx := FRectEx;
  FTurnoverRectEx.Left := FNowPriceHLRectEx.Right + 10;
  FTurnoverRectEx.Right := FTurnoverRectEx.Left + 40;
end;

procedure TAppHqItem.DoUpdateData;
var
  LPAppHqItem: PAppHqItem;
begin
  if FAppStatusUI.FAppStatus = nil then Exit;

  case FAppHqType of
    hstLeft:
      begin
        LPAppHqItem := FAppStatusUI.FAppStatus.GetLHqItem(FCurrIndex);
      end;
  else
    begin
      LPAppHqItem := FAppStatusUI.FAppStatus.GetLHqItem(FCurrIndex);
    end;
  end;

  if LPAppHqItem <> nil then begin
    FSecuAbbr := LPAppHqItem^.FSecuAbbr + ':';
    FTurnover := LPAppHqItem^.GetTurnover;
    FNowPriceHL := LPAppHqItem^.GetNowPriceHL;
    FColorValue := LPAppHqItem^.GetColorValue;
  end;
end;

procedure TAppHqItem.Initialize;
begin
  if FAppStatusUI.FAppStatus = nil then Exit;

  case FAppHqType of
    hstLeft:
      begin
        FItemCount := FAppStatusUI.FAppStatus.GetLHqItemCount;
      end;
  else
    FItemCount := FAppStatusUI.FAppStatus.GetRHqItemCount;
  end;
end;

procedure TAppHqItem.DoIncrementItemCurrIndex;
begin
  if FItemCount = 0 then Exit;

  Inc(FCurrIndex);
  FCurrIndex := FCurrIndex mod FItemCount;
end;

procedure TAppHqItem.Paint(ARenderDC: TRenderDC);
begin
  DrawTextExX(ARenderDC.MemDC, ARenderDC.GPGraphics, FSecuAbbr, FSecuAbbrRectEx,
    HFONT(APPF_STATUS_TEXT), APPC_STATUS_TEXT, StringAlignmentCenter, StringAlignmentCenter);

  DrawTextExX(ARenderDC.MemDC, ARenderDC.GPGraphics, FNowPriceHL, FNowPriceHLRectEx,
    HFONT(APPF_STATUS_TEXT), APPC_STATUS_TEXT, StringAlignmentCenter, StringAlignmentCenter);

  DrawTextExX(ARenderDC.MemDC, ARenderDC.GPGraphics, FTurnover, FTurnoverRectEx,
    HFONT(APPF_STATUS_TEXT), APPC_STATUS_TEXT, StringAlignmentCenter, StringAlignmentCenter);
end;

{ TAppNewsItem }

constructor TAppNewsItem.Create(AParent: TObject);
begin
  inherited;

end;

destructor TAppNewsItem.Destroy;
begin

  inherited;
end;

procedure TAppNewsItem.DoCalcRect;
begin
  inherited;

end;

procedure TAppNewsItem.Paint(ARenderDC: TRenderDC);
begin
  inherited;

end;

{ TAppTimeItem }

constructor TAppTimeItem.Create(AParent: TObject);
begin
  inherited;

end;

destructor TAppTimeItem.Destroy;
begin

  inherited;
end;

procedure TAppTimeItem.DoCalcRect;
begin
  inherited;

end;

procedure TAppTimeItem.Paint(ARenderDC: TRenderDC);
begin
  inherited;

end;

{ TAppAlarmItem }

constructor TAppAlarmItem.Create(AParent: TObject);
begin
  inherited;
  FWidth := 24;
end;

destructor TAppAlarmItem.Destroy;
begin

  inherited;
end;

procedure TAppAlarmItem.DoCalcRect;
begin
  FRectEx.Inflate(-2, -5);
end;

procedure TAppAlarmItem.Paint(ARenderDC: TRenderDC);
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  if FResourceStream = nil then Exit;

  LRect := FRectEx;
  LGPImage := ResourceStreamToGPImage(FResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 20, 20);
//  if FId = TAppSuperTabUI(Self.FParent).SelectComponentId then begin
//    OffsetRect(LSrcRect, 120, 0);
//  end else begin
//    if FId = TAppSuperTabUI(Self.FParent).MouseMoveComponentId then begin
//      OffsetRect(LSrcRect, 60, 0);
//      if FId = TAppSuperTabUI(Self.FParent).MouseDownComponentId then begin
//        OffsetRect(LSrcRect, 60, 0);
//      end;
//    end;
//  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TAppReportItem }

constructor TAppReportItem.Create(AParent: TObject);
begin
  inherited;
  FWidth := 24;
end;

destructor TAppReportItem.Destroy;
begin

  inherited;
end;

procedure TAppReportItem.DoCalcRect;
begin
  FRectEx.Inflate(-2, -5);
end;

procedure TAppReportItem.Paint(ARenderDC: TRenderDC);
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  if FResourceStream = nil then Exit;

  LRect := FRectEx;
  LGPImage := ResourceStreamToGPImage(FResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 20, 20);
//  if FId = TAppSuperTabUI(Self.FParent).SelectComponentId then begin
//    OffsetRect(LSrcRect, 120, 0);
//  end else begin
//    if FId = TAppSuperTabUI(Self.FParent).MouseMoveComponentId then begin
//      OffsetRect(LSrcRect, 60, 0);
//      if FId = TAppSuperTabUI(Self.FParent).MouseDownComponentId then begin
//        OffsetRect(LSrcRect, 60, 0);
//      end;
//    end;
//  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TAppNetworkItem }

constructor TAppNetworkItem.Create(AParent: TObject);
begin
  inherited;
  FWidth := 24;
end;

destructor TAppNetworkItem.Destroy;
begin

  inherited;
end;

procedure TAppNetworkItem.DoCalcRect;
begin
  FRectEx.Inflate(-2, -5);
end;

procedure TAppNetworkItem.Paint(ARenderDC: TRenderDC);
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  if FResourceStream = nil then Exit;

  LRect := FRectEx;
  LGPImage := ResourceStreamToGPImage(FResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 20, 20);
//  if FId = TAppSuperTabUI(Self.FParent).SelectComponentId then begin
//    OffsetRect(LSrcRect, 120, 0);
//  end else begin
//    if FId = TAppSuperTabUI(Self.FParent).MouseMoveComponentId then begin
//      OffsetRect(LSrcRect, 60, 0);
//      if FId = TAppSuperTabUI(Self.FParent).MouseDownComponentId then begin
//        OffsetRect(LSrcRect, 60, 0);
//      end;
//    end;
//  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TAppStatusUI }

constructor TAppStatusUI.Create(AStatus: IAppStatus);
begin
  inherited Create(nil);
  FAppStatus := AStatus;
  FAppStatusItems := TList<TAppStatusItem>.Create;
  DoInitStatusItems;
end;

destructor TAppStatusUI.Destroy;
begin
  DoClear(FAppStatusItems);
  FAppStatusItems.Free;
  FAppStatus := nil;
  inherited;
end;

procedure TAppStatusUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  if FAppContext <> nil then begin
    DoLoadResources;
    DoStatusItemsUpdateData;
  end;
end;

procedure TAppStatusUI.UnInitialize;
begin

  FAppContext := nil;
end;

procedure TAppStatusUI.DoLoadResources;
var
  LIndex: Integer;
  LAppStatusItem: TAppStatusItem;
begin
  for LIndex := 0 to FAppStatusItems.Count - 1 do begin
    LAppStatusItem := FAppStatusItems.Items[LIndex];
    DoLoadResource(LAppStatusItem);
  end;
end;

procedure TAppStatusUI.DoLoadResource(AComponent: TComponentUI);
begin
  if AComponent.ResourceName = '' then Exit;

  AComponent.ResourceStream := FAppContext.GetResourceSkin.GetStream(AComponent.ResourceName);
end;

procedure TAppStatusUI.DoInitStatusItems;
var
  LAppStatusItem: TAppStatusItem;
begin
  LAppStatusItem := TAppHqItem.Create(Self);
  FAppStatusItems.Add(LAppStatusItem);

  LAppStatusItem := TAppHqItem.Create(Self);
  TAppHqItem(LAppStatusItem).AppHqType := hstRight;
  FAppStatusItems.Add(LAppStatusItem);

  LAppStatusItem := TAppNewsItem.Create(Self);
  FNewsItemIndex := FAppStatusItems.Add(LAppStatusItem);
  FAppNewsItem := LAppStatusItem;

  LAppStatusItem := TAppTimeItem.Create(Self);
  FAppStatusItems.Add(LAppStatusItem);

  LAppStatusItem := TAppAlarmItem.Create(Self);
  LAppStatusItem.ResourceName := 'SKIN_APP_ALARM';
  FAppStatusItems.Add(LAppStatusItem);

  LAppStatusItem := TAppReportItem.Create(Self);
  LAppStatusItem.ResourceName := 'SKIN_APP_REPORT';
  FAppStatusItems.Add(LAppStatusItem);

  LAppStatusItem := TAppNetworkItem.Create(Self);
  LAppStatusItem.ResourceName := 'SKIN_APP_NETWORK';
  FAppStatusItems.Add(LAppStatusItem);
end;

procedure TAppStatusUI.DoCalcStatusItems;
var
  LIndex: Integer;
  LLRect, LRRect: TRect;
  LAppStatusItem: TAppStatusItem;
begin
  LLRect := FFrameRectEx;
  LLRect.Top := LLRect.Top + 1;
  LRRect := LLRect;

  for LIndex := 0 to FNewsItemIndex - 1 do begin
    LAppStatusItem := FAppStatusItems.Items[LIndex];
    if LAppStatusItem.Visible then begin
      LLRect.Right := LLRect.Left + LAppStatusItem.Width;
      LAppStatusItem.RectEx := LLRect;
      LAppStatusItem.DoCalcRect;
      LLRect.Left := LLRect.Right;
    end;
  end;

  for LIndex := FAppStatusItems.Count - 1 downto FNewsItemIndex + 1 do begin
    LAppStatusItem := FAppStatusItems.Items[LIndex];
    if LAppStatusItem.Visible then begin
      LRRect.Left := LRRect.Right - LAppStatusItem.Width;
      LAppStatusItem.RectEx := LRRect;
      LAppStatusItem.DoCalcRect;
      LRRect.Right := LRRect.Left;
    end;
  end;

  LRRect.Left := LLRect.Left;
  FAppNewsItem.RectEx := LRRect;
end;

procedure TAppStatusUI.DoStatusItemsUpdateData;
var
  LIndex: Integer;
  LAppStatusItem: TAppStatusItem;
begin
  for LIndex := 0 to FAppStatusItems.Count - 1 do begin
    LAppStatusItem := FAppStatusItems.Items[LIndex];
    LAppStatusItem.DoUpdateData;
  end;
end;

procedure TAppStatusUI.DoClear(AItems: TList<TAppStatusItem>);
var
  LIndex: Integer;
  LAppStatusItem: TAppStatusItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LAppStatusItem := AItems.Items[LIndex];
    if LAppStatusItem <> nil then begin
      LAppStatusItem.Free;
    end;
  end;
  AItems.Clear;
end;

procedure TAppStatusUI.DoSize(AWidth: Integer; AHeight: Integer);
begin
  inherited;
  DoCalcStatusItems;
end;

procedure TAppStatusUI.DoPaintBackground(AInvalidateRect: TRect);
begin
  FillSolidRect(FFrameRenderDC.MemDC, @AInvalidateRect, APPC_MAINFORM_SUPERTAB_BACK);
end;

procedure TAppStatusUI.DoPaintComponents(AInvalidateRect: TRect);
var
  LIndex: Integer;
  LAppStatusItem: TAppStatusItem;
begin
  for LIndex := 0 to FAppStatusItems.Count - 1 do begin
    LAppStatusItem := FAppStatusItems.Items[LIndex];
    if LAppStatusItem.Visible then begin
      LAppStatusItem.Paint(FFrameRenderDC);
    end;
  end;
end;

procedure TAppStatusUI.DoMouseMove(AMousePt: TPoint; AKeys: Integer);
begin

end;

procedure TAppStatusUI.DoClickComponent(AComponent: TComponentUI);
begin

end;

function TAppStatusUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
begin

end;

end.
