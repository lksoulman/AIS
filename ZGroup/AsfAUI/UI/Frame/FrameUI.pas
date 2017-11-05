unit FrameUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Component UI
// Author：      lksoulman
// Date：        2017-10-27
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Messages,
  ExtCtrls,
  GDIPAPI,
  RenderDC,
  CommonLock,
  ComponentUI,
  Generics.Collections;

const

  WM_CLICK_COMPONENT = WM_USER + 100;

type

  // Frame UI
  TFrameUI = class(TWinControl)
  private
  protected
    // Is Repaint
    FIsRepaint: Boolean;
    // Mouse Keys
    FMouseKeys: Integer;
    // Mouse Move Point
    FMouseMovePt: TPoint;
    // Mouse Leave Point
    FMouseLeavePt: TPoint;
    // Mouse Move Timer
    FMouseMoveTimer: TTimer;
    // Select Component Id
    FSelectComponentId: Integer;
    // Mouse Move Component Id
    FMouseMoveComponentId: Integer;
    // Mouse Down Component Id
    FMouseDownComponentId: Integer;
    // Component
    FComponentDic: TDictionary<Integer, TComponentUI>;

    // Incr Id
    FIncrId: Integer;
    // Lock
    FIncrLock: TCSLock;

    // Frame Rect
    FFrameRectEx: TRect;
    // Render DC
    FFrameRenderDC: TRenderDC;
    // On Click Item
    FOnClickItem: TNotifyEvent;

    // Size
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    // Paint
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    // EarseBkgnd
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    // Dlg Code
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
    // Mouse Move
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    // Left Button Up
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    // Left Button Down
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    // Click Component
    procedure WMClickComponent(var Message: TMessage); message WM_CLICK_COMPONENT;

    // Get Component Incr Id
    function DoGetIncrId: Integer;
    // Do Invalidate Paint
    procedure DoInvalidatePaint;
    // Mouse Move Timer
    procedure DoMouseMoveTimer(AObject: TObject);
    // Update Component
    procedure DoUpdateComponent(AMouseMoveId: Integer);
    // Paint
    procedure DoPaint(ADC: HDC; AInvalidateRect: TRect); virtual;

    // Size
    procedure DoSize(AWidth: Integer; AHeight: Integer); virtual;
    // Paint Backgroud
    procedure DoPaintBackground(AInvalidateRect: TRect); virtual;
    // Paint Components
    procedure DoPaintComponents(AInvalidateRect: TRect); virtual;
    // Mouse Move
    procedure DoMouseMove(AMousePt: TPoint; AKeys: Integer); virtual;
    // Click Component
    procedure DoClickComponent(AComponent: TComponentUI); virtual;
    // Find Component
    function DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; overload; virtual;
    // Find Component
    function DoFindComponent(AId: Integer; var AComponent: TComponentUI): Boolean; overload; virtual;
  public
    // Constructor
    constructor Create(AOwner: TComponent); override;
    // Destructor
    destructor Destroy; override;

    property OnClickItem: TNotifyEvent read FOnClickItem write FOnClickItem;
    property SelectComponentId: Integer read FSelectComponentId write FSelectComponentId;
    property MouseMoveComponentId: Integer read FMouseMoveComponentId write FMouseMoveComponentId;
    property MouseDownComponentId: Integer read FMouseDownComponentId write FMouseDownComponentId;
  end;

implementation

{ TFrameUI }

constructor TFrameUI.Create(AOwner: TComponent);
begin
  inherited;
  FIsRepaint := True;
  FIncrId := 0;
  FSelectComponentId := -1;
  FMouseMoveComponentId := -1;
  FMouseDownComponentId := -1;
  FIncrLock := TCSLock.Create;
  FComponentDic := TDictionary<Integer, TComponentUI>.Create;
  FFrameRenderDC := TRenderDC.Create;
  FMouseMoveTimer := TTimer.Create(nil);
  FMouseMoveTimer.Enabled := False;
  FMouseMoveTimer.Interval := 100;
  FMouseMoveTimer.OnTimer := DoMouseMoveTimer;

end;

destructor TFrameUI.Destroy;
begin
  FFrameRenderDC.Free;
  FComponentDic.Free;
  FIncrLock.Free;
  inherited;
end;

procedure TFrameUI.WMSize(var Message: TWMSize);
begin
  inherited;
  DoSize(Message.Width, Message.Height);
end;

procedure TFrameUI.WMPaint(var Message: TWMPaint);
var
  LPAINTSTRUCT: PAINTSTRUCT;
begin
  BeginPaint(Handle, LPAINTSTRUCT);
  try
    DoPaint(LPAINTSTRUCT.hdc, FFrameRectEx);//LPAINTSTRUCT.rcPaint);
  finally
    EndPaint(Handle, LPAINTSTRUCT);
  end;
end;

procedure TFrameUI.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  // 不做任何操作，直接在绘制里刷新背景,防止闪烁
  Message.Result := 1;
  FIsRepaint := True;
end;

procedure TFrameUI.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTALLKEYS or DLGC_WANTARROWS or DLGC_WANTTAB;
end;

procedure TFrameUI.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  FMouseMovePt.X := Message.XPos;
  FMouseMovePt.Y := Message.YPos;
  FMouseKeys := Message.Keys;
  FMouseMoveTimer.Enabled := True;
end;

procedure TFrameUI.DoMouseMoveTimer(AObject: TObject);
var
  LCurrentPt: TPoint;
  LComponent: TComponentUI;
begin
  FMouseMoveTimer.Enabled := False;

  if (Abs(FMouseLeavePt.X - FMouseMovePt.X) > 2)
    or (Abs(FMouseLeavePt.Y - FMouseMovePt.Y) > 2) then
  begin
    FMouseLeavePt := FMouseMovePt;
  end else begin
    Exit;
  end;

  LCurrentPt.X := FMouseMovePt.X;
  LCurrentPt.Y := FMouseMovePt.Y;
  if DoFindComponent(LCurrentPt, LComponent) then begin
    DoUpdateComponent(LComponent.Id);
  end else begin
    DoUpdateComponent(-1);
  end;
  DoMouseMove(LCurrentPt, FMouseKeys);
end;

procedure TFrameUI.WMLButtonUp(var Message: TWMLButtonUp);
var
  LComponentId: Integer;
begin
  inherited;
  FMouseLeavePt.X := Message.XPos;
  FMouseLeavePt.Y := Message.YPos;
  if FMouseDownComponentId <> -1 then begin
    LComponentId := FMouseDownComponentId;
    FSelectComponentId := FMouseDownComponentId;
    FMouseDownComponentId := -1;
    InvalidateRect(Self.Handle, FFrameRectEx, False);
    PostMessage(Self.Handle, WM_CLICK_COMPONENT, LComponentId, 0);
  end;
end;

procedure TFrameUI.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  FMouseLeavePt.X := Message.XPos;
  FMouseLeavePt.Y := Message.YPos;
  if FMouseDownComponentId <> FMouseMoveComponentId then begin
    FMouseDownComponentId := FMouseMoveComponentId;
    DoInvalidatePaint;
  end;
end;

procedure TFrameUI.WMClickComponent(var Message: TMessage);
var
  LComponent: TComponentUI;
begin
  if DoFindComponent(Integer(Message.WParam), LComponent) then begin
    DoClickComponent(LComponent);
  end;
end;

function TFrameUI.DoGetIncrId: Integer;
begin
  FIncrLock.Lock;
  try
    Result := FIncrId;
    Inc(FIncrId);
  finally
    FIncrLock.UnLock;
  end;
end;

procedure TFrameUI.DoInvalidatePaint;
begin
  InvalidateRect(Self.Handle, FFrameRectEx, False);
end;

procedure TFrameUI.DoPaint(ADC: HDC; AInvalidateRect: TRect);
begin
  try
    if not FFrameRenderDC.IsInit then begin
      FFrameRenderDC.SetDC(ADC);
    end;
    FFrameRenderDC.SetBounds(ADC, AInvalidateRect);
    DoPaintBackground(AInvalidateRect);
    DoPaintComponents(AInvalidateRect);
  finally
    FFrameRenderDC.BitBltX(ADC, AInvalidateRect);
  end;
end;

procedure TFrameUI.DoUpdateComponent(AMouseMoveId: Integer);
begin
  if FMouseMoveComponentId <> AMouseMoveId then begin
    FMouseMoveComponentId := AMouseMoveId;
    if FMouseDownComponentId <> AMouseMoveId then begin
      FMouseDownComponentId := -1;
    end;
    DoInvalidatePaint;
  end;
end;

procedure TFrameUI.DoSize(AWidth: Integer; AHeight: Integer);
begin
  FFrameRectEx := Rect(0, 0, AWidth, AHeight);
end;

procedure TFrameUI.DoPaintBackground(AInvalidateRect: TRect);
begin

end;

procedure TFrameUI.DoPaintComponents(AInvalidateRect: TRect);
begin

end;

procedure TFrameUI.DoMouseMove(AMousePt: TPoint; AKeys: Integer);
begin

end;

procedure TFrameUI.DoClickComponent(AComponent: TComponentUI);
begin

end;

function TFrameUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
begin
  Result := False;
end;

function TFrameUI.DoFindComponent(AId: Integer; var AComponent: TComponentUI): Boolean;
begin
  if Self.FComponentDic.TryGetValue(AId, AComponent) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

end.
