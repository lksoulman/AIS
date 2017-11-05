unit AppMenuUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º App Menu UI
// Author£º      lksoulman
// Date£º        2017-10-26
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  GDIPOBJ,
  RenderDC,
  RenderUtil,
  AppContext,
  ComponentUI,
  CommonRefCounter,
  Generics.Collections;

type

  // App Menu Item
  TAppMenuItem = class(TComponentUI)
  private
    // Parent
    FParent: TObject;
  protected
  public
    // Constructor
    constructor Create(AParent: TObject); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Is valid Rect
    function IsValidRect: Boolean; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;
  end;

  // App Menu UI
  TAppMenuUI = class(TAutoObject)
  private
    // Incr Id
    FIncrId: Integer;
    // Hit Id
    FHitId: Integer;
    // Down Hit Id
    FDownHitId: Integer;
    // App Context
    FAppContext: IAppContext;
    // App Left Menu Rect
    FAppLMenuRect: TRect;
    // App Right Menu Rect
    FAppRMenuRect: TRect;
    // App Left Menu Items
    FAppLMenuItems: TList<TAppMenuItem>;
    // App Right Menu Items
    FAppRMenuItems: TList<TAppMenuItem>;
    // App Menu Item Dic
    FAppMenuItemDic: TDictionary<Integer, TAppMenuItem>;
  protected
    // IncrId
    function DoIncrId: Integer;
    // Init Menu Items
    procedure DoInitMenuItems;
    // Clear Menu Items
    procedure DoClear(AItems: TList<TAppMenuItem>);
    // Calc Menu Items
    procedure DoCalcMenuItems(ARect: TRect);
    // Load Resource
    procedure DoLoadResources(AItems: TList<TAppMenuItem>);
    // Paint Menu Items
    procedure DoPaintMenuItems(ARenderDC: TRenderDC; ARect: TRect; AItems: TList<TAppMenuItem>);
    // Load Resource
    procedure DoLoadResource(AComponent: TComponentUI);
    // Menu Item Dic Add
    procedure DoMenuItemDicAdd(AMenuItem: TAppMenuItem);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
    // Paint Menu
    procedure PaintMenu(ARenderDC: TRenderDC; AInvalidateRect: TRect);
    // Get Menu Item
    function GetMenuItemById(AId: Integer): TAppMenuItem;
    // Get Menu Item
    function GetMenuItemByPt(ARect: TRect; APt: TPoint; var AMenuItem: TAppMenuItem): Boolean;

    property HitId: Integer read FHitId write FHitId;
    property DownHitId: Integer read FDownHitId write FDownHitId;
  end;

implementation


{ TAppMenuItem }

constructor TAppMenuItem.Create(AParent: TObject);
begin
  inherited Create;
  FParent := AParent;
  FRectEx := Rect(0, 0, 0, 0);
end;

destructor TAppMenuItem.Destroy;
begin
  inherited;
end;

function TAppMenuItem.IsValidRect: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

procedure TAppMenuItem.Paint(ARenderDC: TRenderDC);
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  if FResourceStream = nil then Exit;

  LRect := FRectEx;
  LRect.Left := LRect.Right - 30;
  LGPImage := ResourceStreamToGPImage(FResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FId = TAppMenuUI(Self.FParent).HitId then begin
    OffsetRect(LSrcRect, 30, 0);
    if FId = TAppMenuUI(Self.FParent).DownHitId then begin
      OffsetRect(LSrcRect, 30, 0);
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TAppMenuUI }

constructor TAppMenuUI.Create;
begin
  inherited;
  FIncrId := 0;
  FHitId := -1;
  FDownHitId := -1;
  FAppLMenuItems := TList<TAppMenuItem>.Create;
  FAppRMenuItems := TList<TAppMenuItem>.Create;
  FAppMenuItemDic := TDictionary<Integer, TAppMenuItem>.Create(15);
  DoInitMenuItems;
end;

destructor TAppMenuUI.Destroy;
begin
  DoClear(FAppLMenuItems);
  DoClear(FAppRMenuItems);
  FAppLMenuItems.Free;
  FAppRMenuItems.Free;
  FAppMenuItemDic.Free;
  inherited;
end;

procedure TAppMenuUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  if FAppContext <> nil then begin
    DoLoadResources(FAppLMenuItems);
    DoLoadResources(FAppRMenuItems);
  end;
end;

procedure TAppMenuUI.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TAppMenuUI.PaintMenu(ARenderDC: TRenderDC; AInvalidateRect: TRect);
begin
  if ARenderDC.MemDC = 0 then Exit;
  if AInvalidateRect.Left >= AInvalidateRect.Right then Exit;

  DoCalcMenuItems(AInvalidateRect);

  if FAppLMenuRect.Left < FAppLMenuRect.Right then begin
    DoPaintMenuItems(ARenderDC, FAppLMenuRect, FAppLMenuItems);
  end;

  if FAppRMenuRect.Left < FAppRMenuRect.Right then begin
    DoPaintMenuItems(ARenderDC, FAppRMenuRect, FAppRMenuItems);
  end;
end;

function TAppMenuUI.GetMenuItemById(AId: Integer): TAppMenuItem;
begin
  if FAppMenuItemDic.TryGetValue(AId, Result) then begin
    Result := nil;
  end;
end;

function TAppMenuUI.GetMenuItemByPt(ARect: TRect; APt: TPoint; var AMenuItem: TAppMenuItem): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  AMenuItem := nil;
  DoCalcMenuItems(ARect);

  if PtInRect(FAppLMenuRect, APt) then begin
    for LIndex := 0 to FAppLMenuItems.Count - 1 do begin
      AMenuItem := FAppLMenuItems.Items[LIndex];
      if AMenuItem.Visible
        and AMenuItem.IsValidRect then begin
        if PtInRect(AMenuItem.RectEx, APt) then begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;

  if PtInRect(FAppRMenuRect, APt) then begin
    for LIndex := 0 to FAppRMenuItems.Count - 1 do begin
      AMenuItem := FAppRMenuItems.Items[LIndex];
      if AMenuItem.Visible
        and AMenuItem.IsValidRect then begin
        if PtInRect(AMenuItem.RectEx, APt) then begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
end;

function TAppMenuUI.DoIncrId: Integer;
begin
  Result := FIncrId;
  Inc(FIncrId);
end;

procedure TAppMenuUI.DoInitMenuItems;
var
  LAppMenuItem: TAppMenuItem;
begin
  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_BACKSPACE';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppLMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_FORWARD';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppLMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_REFRESH';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppLMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_SKIN';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppRMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_HELP';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppRMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_NEWWORK';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppRMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_F6';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppRMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_F4';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppRMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_F3';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppRMenuItems.Add(LAppMenuItem);

  LAppMenuItem := TAppMenuItem.Create(Self);
  LAppMenuItem.Id := DoIncrId;
  LAppMenuItem.ResourceName := 'SKIN_APP_81';
  DoMenuItemDicAdd(LAppMenuItem);
  FAppRMenuItems.Add(LAppMenuItem);

//  LAppMenuItem := TAppMenuItem.Create(Self);
//  LAppMenuItem.Id := DoIncrId;
//  LAppMenuItem.ResourceName := '';
//  DoMenuItemDicAdd(LAppMenuItem);
//  FAppMenuItems.Add(LAppMenuItem);
//
//  LAppMenuItem := TAppMenuItem.Create(Self);
//  LAppMenuItem.Id := DoIncrId;
//  LAppMenuItem.ResourceName := '';
//  DoMenuItemDicAdd(LAppMenuItem);
//  FAppMenuItems.Add(LAppMenuItem);
end;

procedure TAppMenuUI.DoClear(AItems: TList<TAppMenuItem>);
var
  LIndex: Integer;
  LAppMenuItem: TAppMenuItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LAppMenuItem := AItems.Items[LIndex];
    if LAppMenuItem <> nil then begin
      LAppMenuItem.Free;
    end;
  end;
  AItems.Clear;
end;

procedure TAppMenuUI.DoLoadResources(AItems: TList<TAppMenuItem>);
var
  LIndex: Integer;
  LAppMenuItem: TAppMenuItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LAppMenuItem := AItems.Items[LIndex];
    if LAppMenuItem <> nil then begin
      DoLoadResource(LAppMenuItem);
    end;
  end;
end;

procedure TAppMenuUI.DoLoadResource(AComponent: TComponentUI);
begin
  if AComponent.ResourceName = '' then Exit;

  AComponent.ResourceStream := FAppContext.GetResourceSkin.GetStream(AComponent.ResourceName);
end;

procedure TAppMenuUI.DoMenuItemDicAdd(AMenuItem: TAppMenuItem);
begin
  FAppMenuItemDic.AddOrSetValue(AMenuItem.Id, AMenuItem);
end;

procedure TAppMenuUI.DoCalcMenuItems(ARect: TRect);
var
  LIndex: Integer;
  LRectEx, LFixRect: TRect;
  LAppMenuItem: TAppMenuItem;

  procedure CalcLMenuItemRectEx(var ARectEx: TRect);
  begin
    if ARectEx.Right < LFixRect.Right then begin
      OffsetRect(ARectEx, 30, 0);
      if ARectEx.Right > LFixRect.Right then begin
        ARectEx.Right := LFixRect.Right;
      end;
      if ARectEx.Left > LFixRect.Right then begin
        ARectEx.Left := LFixRect.Right;
      end;
    end else begin
      if ARectEx.Right > LFixRect.Right then begin
        ARectEx.Right := LFixRect.Right;
      end;
      if ARectEx.Left > LFixRect.Right then begin
        ARectEx.Left := LFixRect.Right;
      end;
    end;
    if ARectEx.Left < LFixRect.Left then begin
      ARectEx.Left := LFixRect.Left;
    end;
  end;

  procedure CalcRMenuItemRectEx(var ARectEx: TRect);
  begin
    if ARectEx.Left > LFixRect.Left then begin
      OffsetRect(ARectEx, -30, 0);
      if ARectEx.Left < LFixRect.Left then begin
        ARectEx.Left := LFixRect.Left;
      end;
      if ARectEx.Right < LFixRect.Left then begin
        ARectEx.Right := LFixRect.Left;
      end;
    end else begin
      if ARectEx.Left < LFixRect.Left then begin
        ARectEx.Left := LFixRect.Left;
      end;
      if ARectEx.Right > LFixRect.Left then begin
        ARectEx.Right := LFixRect.Left;
      end;
    end;

    if ARectEx.Right > LFixRect.Right then begin
      ARectEx.Right := LFixRect.Right;
    end;
  end;
begin
  LFixRect := ARect;
  LRectEx := LFixRect;
  FAppLMenuRect := LRectEx;
  LRectEx.Left := ARect.Left - 30;
  LRectEx.Right := ARect.Left;
  for LIndex := 0 to FAppLMenuItems.Count - 1 do begin
    LAppMenuItem := FAppLMenuItems.Items[LIndex];
    if LAppMenuItem.Visible then begin
      CalcLMenuItemRectEx(LRectEx);
      LAppMenuItem.RectEx := LRectEx;
    end;
  end;
  FAppLMenuRect.Right := LRectEx.Right;

  LFixRect := ARect;
  LFixRect.Left := LRectEx.Right;
  if LFixRect.Left > ARect.Right then begin
    LFixRect.Left := ARect.Right;
  end;
  LRectEx := LFixRect;
  LRectEx.Left := LRectEx.Right;
  LRectEx.Right := LRectEx.Left + 30;
  FAppRMenuRect := LFixRect;
  for LIndex := 0 to FAppRMenuItems.Count - 1 do begin
    LAppMenuItem := FAppRMenuItems.Items[LIndex];
    if LAppMenuItem.Visible then begin
      CalcRMenuItemRectEx(LRectEx);
      LAppMenuItem.RectEx := LRectEx;
    end;
  end;
  FAppRMenuRect.Left := LRectEx.Left;
end;

procedure TAppMenuUI.DoPaintMenuItems(ARenderDC: TRenderDC; ARect: TRect; AItems: TList<TAppMenuItem>);
var
  LClipRgn: HRGN;
  LIndex: Integer;
  LAppMenuItem: TAppMenuItem;
begin
  LClipRgn := CreateRectRgnIndirect(ARect);
  if LClipRgn = 0 then Exit;
  SelectClipRgn(ARenderDC.MemDC, LClipRgn);
  try
    for LIndex := 0 to AItems.Count - 1 do begin
      LAppMenuItem := AItems.Items[LIndex];
      if LAppMenuItem.Visible
        and LAppMenuItem.IsValidRect then begin
        LAppMenuItem.Paint(ARenderDC);
      end;
    end;
  finally
    SelectClipRgn(ARenderDC.MemDC, 0);
    DeleteObject(LClipRgn);
  end;
end;

end.
