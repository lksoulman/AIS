unit AppSuperTabUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º App Super Tab UI
// Author£º      lksoulman
// Date£º        2017-10-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  GDIPOBJ,
  FrameUI,
  RenderDC,
  RenderGDI,
  RenderUtil,
  AppContext,
  CommonLock,
  ComponentUI,
  Generics.Collections;

type

  // App Super Tab Item
  TAppSuperTabItem = class(TComponentUI)
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

  // App Super Tab UI
  TAppSuperTabUI = class(TFrameUI)
  private
    // Lock
    FLock: TCSLock;
    // App Context
    FAppContext: IAppContext;
    // Items
    FItems: TList<TAppSuperTabItem>;
    // Draw Items
    FDrawItems: TList<TAppSuperTabItem>;
    // Sub Draw Items
    FSubDrawItems: TList<TAppSuperTabItem>;
    // Super Tab Item Dic
    FSuperTabItemDic: TDictionary<Integer, TAppSuperTabItem>;
  protected
    // Init Super Tab Items
    procedure DoInitSuperTabItems;
    // Clear Items
    procedure DoClear(AItems: TList<TAppSuperTabItem>);
    // Load Resource
    procedure DoLoadResource(AComponent: TComponentUI);
    // Super Tab Item Dic Add
    procedure DoSuperTabItemDicAdd(ATabItem: TAppSuperTabItem);
    // Load Resources
    procedure DoLoadResources(ATabItems: TList<TAppSuperTabItem>);

    // Calc Change Size
    procedure DoCalcChangeSize(AFrameRect: TRect);
    // Calc Super Tab Items
    procedure DoCalcSuperTabItems(AFrameRect: TRect);
    // Size
    procedure DoSize(AWidth: Integer; AHeight: Integer); override;
    // Paint Backgroud
    procedure DoPaintBackground(AInvalidateRect: TRect); override;
    // Paint Components
    procedure DoPaintComponents(AInvalidateRect: TRect); override;
    // Click Component
    procedure DoClickComponent(AComponent: TComponentUI); override;
    // Find Component
    function DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; override;
  public
    // Constructor
    constructor Create(AOwner: TComponent); override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
  end;

implementation

{ TAppSuperTabItem }

constructor TAppSuperTabItem.Create(AParent: TObject);
begin
  inherited Create;
  FParent := AParent;
end;

destructor TAppSuperTabItem.Destroy;
begin
  FParent := nil;
  inherited;
end;

function TAppSuperTabItem.IsValidRect: Boolean;
begin
  Result := True;
end;

procedure TAppSuperTabItem.Paint(ARenderDC: TRenderDC);
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  if FResourceStream = nil then Exit;

  LRect := FRectEx;
  LRect.Bottom := LRect.Top + 65;
  LGPImage := ResourceStreamToGPImage(FResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 60, 65);
  if FId = TAppSuperTabUI(Self.FParent).SelectComponentId then begin
    OffsetRect(LSrcRect, 120, 0);
  end else begin
    if FId = TAppSuperTabUI(Self.FParent).MouseMoveComponentId then begin
      OffsetRect(LSrcRect, 60, 0);
      if FId = TAppSuperTabUI(Self.FParent).MouseDownComponentId then begin
        OffsetRect(LSrcRect, 60, 0);
      end;
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;

{ TAppSuperTabUI }

constructor TAppSuperTabUI.Create(AOwner: TComponent);
begin
  inherited;
  FIncrId := 0;
  FLock := TCSLock.Create;
  FItems := TList<TAppSuperTabItem>.Create;
  FDrawItems := TList<TAppSuperTabItem>.Create;
  FSubDrawItems := TList<TAppSuperTabItem>.Create;
  FSuperTabItemDic := TDictionary<Integer, TAppSuperTabItem>.Create(25);
end;

destructor TAppSuperTabUI.Destroy;
begin
  DoClear(FItems);
  FSuperTabItemDic.Free;
  FSubDrawItems.Free;
  FDrawItems.Free;
  FLock.Free;
  inherited;
end;

procedure TAppSuperTabUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  if FAppContext <> nil then begin
    DoInitSuperTabItems;
    DoLoadResources(FItems);
  end;
end;

procedure TAppSuperTabUI.UnInitialize;
begin

  FAppContext := nil;
end;

procedure TAppSuperTabUI.DoCalcChangeSize(AFrameRect: TRect);
var
  LIndex, LCount, LMod: Integer;
begin
  try
    FDrawItems.Clear;
    FSubDrawItems.Clear;
    FComponentDic.Clear;

    if AFrameRect.Height > 0 then begin
      LCount := AFrameRect.Height div 65;
      LMod := AFrameRect.Height mod 65;
      if LMod > 0 then begin
        Inc(LCount);
      end;
    end else begin
      LCount := 0;
    end;

    if LCount > FItems.Count then begin
      LCount := FItems.Count;
    end;

    for LIndex := 0 to LCount - 1 do begin
      FDrawItems.Add(FItems.Items[LIndex]);
      FComponentDic.AddOrSetValue(FItems.Items[LIndex].Id, FItems.Items[LIndex]);
    end;

    for LIndex := LCount to FItems.Count - 1 do begin
      FSubDrawItems.Add(FItems.Items[LIndex]);
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TAppSuperTabUI.DoCalcSuperTabItems(AFrameRect: TRect);
var
  LRect: TRect;
  LIndex: Integer;
  LAppSuperTabItem: TAppSuperTabItem;
begin
  LRect := AFrameRect;
  LRect.Bottom := LRect.Top + 65;
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    if LRect.Bottom > AFrameRect.Bottom then begin
      LRect.Bottom := AFrameRect.Bottom;
    end;
    LAppSuperTabItem := FDrawItems.Items[LIndex];
    LAppSuperTabItem.RectEx := LRect;
    OffsetRect(LRect, 0, 65);
    if (LRect.Left >= AFrameRect.Bottom)
      and (LRect.Bottom >= AFrameRect.Bottom) then begin
      Break;
    end;
  end;
end;

procedure TAppSuperTabUI.DoInitSuperTabItems;
var
  LAppSuperTabItem: TAppSuperTabItem;
begin
  LAppSuperTabItem := TAppSuperTabItem.Create(Self);
  LAppSuperTabItem.Id := DoGetIncrId;
  LAppSuperTabItem.ResourceName := 'SKIN_APP_HQ';
  DoSuperTabItemDicAdd(LAppSuperTabItem);
  FItems.Add(LAppSuperTabItem);

  LAppSuperTabItem := TAppSuperTabItem.Create(Self);
  LAppSuperTabItem.Id := DoGetIncrId;
  LAppSuperTabItem.ResourceName := 'SKIN_APP_ASSET';
  DoSuperTabItemDicAdd(LAppSuperTabItem);
  FItems.Add(LAppSuperTabItem);

  LAppSuperTabItem := TAppSuperTabItem.Create(Self);
  LAppSuperTabItem.Id := DoGetIncrId;
  LAppSuperTabItem.ResourceName := 'SKIN_APP_PARAMSSETTING';
  DoSuperTabItemDicAdd(LAppSuperTabItem);
  FItems.Add(LAppSuperTabItem);

  LAppSuperTabItem := TAppSuperTabItem.Create(Self);
  LAppSuperTabItem.Id := DoGetIncrId;
  LAppSuperTabItem.ResourceName := 'SKIN_APP_MANAGEMENTVIEW';
  DoSuperTabItemDicAdd(LAppSuperTabItem);
  FItems.Add(LAppSuperTabItem);

  LAppSuperTabItem := TAppSuperTabItem.Create(Self);
  LAppSuperTabItem.Id := DoGetIncrId;
  LAppSuperTabItem.ResourceName := 'SKIN_APP_RISKMANAGEMENT';
  DoSuperTabItemDicAdd(LAppSuperTabItem);
  FItems.Add(LAppSuperTabItem);

  LAppSuperTabItem := TAppSuperTabItem.Create(Self);
  LAppSuperTabItem.Id := DoGetIncrId;
  LAppSuperTabItem.ResourceName := 'SKIN_APP_HQ';
  DoSuperTabItemDicAdd(LAppSuperTabItem);
  FItems.Add(LAppSuperTabItem);

  LAppSuperTabItem := TAppSuperTabItem.Create(Self);
  LAppSuperTabItem.Id := DoGetIncrId;
  LAppSuperTabItem.ResourceName := 'SKIN_APP_ASSET';
  DoSuperTabItemDicAdd(LAppSuperTabItem);
  FItems.Add(LAppSuperTabItem);

  LAppSuperTabItem := TAppSuperTabItem.Create(Self);
  LAppSuperTabItem.Id := DoGetIncrId;
  LAppSuperTabItem.ResourceName := 'SKIN_APP_PARAMSSETTING';
  DoSuperTabItemDicAdd(LAppSuperTabItem);
  FItems.Add(LAppSuperTabItem);
end;

procedure TAppSuperTabUI.DoClear(AItems: TList<TAppSuperTabItem>);
var
  LIndex: Integer;
  LAppSuperTabItem: TAppSuperTabItem;
begin
  for LIndex := 0 to AItems.Count - 1 do begin
    LAppSuperTabItem := AItems.Items[LIndex];
    if LAppSuperTabItem <> nil then begin
      LAppSuperTabItem.Free;
    end;
  end;
  AItems.Clear;
end;

procedure TAppSuperTabUI.DoLoadResource(AComponent: TComponentUI);
begin
  if AComponent.ResourceName = '' then Exit;

  AComponent.ResourceStream := FAppContext.GetResourceSkin.GetStream(AComponent.ResourceName);
end;

procedure TAppSuperTabUI.DoSuperTabItemDicAdd(ATabItem: TAppSuperTabItem);
begin
  FSuperTabItemDic.AddOrSetValue(ATabItem.Id, ATabItem);
end;

procedure TAppSuperTabUI.DoLoadResources(ATabItems: TList<TAppSuperTabItem>);
var
  LIndex: Integer;
  LAppSuperTabItem: TAppSuperTabItem;
begin
  for LIndex := 0 to ATabItems.Count - 1 do begin
    LAppSuperTabItem := ATabItems.Items[LIndex];
    DoLoadResource(LAppSuperTabItem);
  end;
end;

procedure TAppSuperTabUI.DoSize(AWidth: Integer; AHeight: Integer);
begin
  inherited;
  DoCalcChangeSize(FFrameRectEx);
  DoCalcSuperTabItems(FFrameRectEx);
end;

procedure TAppSuperTabUI.DoPaintBackground(AInvalidateRect: TRect);
begin
  FillSolidRect(FFrameRenderDC.MemDC, @AInvalidateRect, APPC_MAINFORM_SUPERTAB_BACK);
end;

procedure TAppSuperTabUI.DoPaintComponents(AInvalidateRect: TRect);
var
  LIndex: Integer;
  LComponent: TComponentUI;
begin
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    LComponent := FDrawItems.Items[LIndex];
    if LComponent.Visible then begin
      LComponent.Paint(FFrameRenderDC);
    end;
  end;
end;

procedure TAppSuperTabUI.DoClickComponent(AComponent: TComponentUI);
begin

end;

function TAppSuperTabUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FDrawItems.Count - 1 do begin
    AComponent := FDrawItems.Items[LIndex];
    if AComponent.Visible
      and PtInRect(AComponent.RectEx, APt) then begin
      Result := True;
      Exit;
    end;
  end;
end;

end.
