unit FrameUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Frame UI
// Author：      lksoulman
// Date：        2017-10-16
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
  ControlUI,
  CommonLock,
  ActiveX,
  GDIPOBJ,
  RenderDC,
  AppContext,
  RenderEngine,
  Generics.Collections;

type

  // Frame UI
  TFrameUI = class(TWinControl)
  private
    // No Client Hit Test
    procedure WMNCHitTest(var Msg: TMessage); message WM_NCHITTEST;
    // Visible Change
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    // Size
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    // Paint
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    // EarseBkgnd
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    // Left Button Down
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    // Left Button Up
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    // Left Button Double Click
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    // Right Button Down
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    // Right Button Up
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    // Mouse Move
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    // Mouse Wheel
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    // Key Down
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    // Key Up
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    // 设置框架的输入消息处理
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
  protected
    // BkBrush
    FBkBrush: HBRUSH;
    // Render DC
    FRenderDC: TRenderDC;
    // Render Engine
    FRenderEngine: TRenderEngine;
    // Memory DC Render Engine
    FMemRenderEngine: TRenderEngine;
    // Repaint
    FRepaintBk: Boolean;
    // Mouse Move
    FMouseMovePt: TPoint;
    // Mouse Last Point
    FMouseLastPt: TPoint;
    // Mouse Move Timer
    FMouseMoveTimer: TTimer;
    // FLock
    FLock: TCSLock;
    // ControlUIs
    FControlUIs: TList<TControlUI>;
    // Hovered ControlUI
    FHoveredControlUI: TControlUI;

    // Application Context
    FAppContext: IAppContext;

    // Add Control UI
    procedure AddControlUIs; virtual;
    // Delete Control UI
    procedure DelControlUIs; virtual;
    // Calc Control Rect
    procedure CalcControlUIRect; virtual;
    // Mouse Move Timer
    procedure DoMouseMoveTimer(ASender: TObject); virtual;
    // Get Focused ControlUI
    function GetFocusedControlUI(var AControlUI: TControlUI): Boolean; virtual;
    // Get ControlUI by Point
    function GetControlUIByMousePt(APt: TPoint; var AControlUI: TControlUI): Boolean; virtual;

    // Create GPImage
    function CreateGPImageByResource(AResourceName: string): TGPImage;

    // Paint Controls
    procedure PaintControlUIs; virtual;
    // Paint Front ground
    procedure PaintFg(ADC: HDC; AInvalidateRect: TRect); virtual;
    // Paint Memory Background
    procedure PaintMemBg(ADC: HDC; AInvalidateRect: TRect); virtual;
  public
    // Constructor
    constructor Create(AOwner: TComponent); override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IAppContext); virtual;
    // Un Init
    procedure UnInitialize; virtual;
    // Add Child Control UI
    procedure AddChildControlUI(AControlUI: TControlUI);
    // Del Child Control UI
    procedure DeleteChildControlUI(AControlUI: TControlUI);

    property RenderDC: TRenderDC read FRenderDC;
    property RenderEngine: TRenderEngine read FRenderEngine;
  end;

implementation

{ TFrameUI }

constructor TFrameUI.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMouseMoveTimer := TTimer.Create(nil);
  FMouseMoveTimer.Enabled := False;
  FMouseMoveTimer.Interval := 20;
  FMouseMoveTimer.OnTimer := DoMouseMoveTimer;
  FRenderDC := TRenderDC.Create;
  FRenderEngine := TRenderEngine.Create;
  FMemRenderEngine := TRenderEngine.Create;
  FRepaintBk := True;
  FLock := TCSLock.Create;
  FControlUIs := TList<TControlUI>.Create;
  AddControlUIs;
end;

destructor TFrameUI.Destroy;
begin
  DelControlUIs;
  FControlUIs.Free;
  FLock.Free;
  FMemRenderEngine.Free;
  FRenderEngine.Free;
  FRenderDC.Free;
  FMouseMoveTimer.Enabled := False;
  FMouseMoveTimer.OnTimer := nil;
  FMouseMoveTimer.Free;
  inherited;
end;

procedure TFrameUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TFrameUI.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TFrameUI.AddControlUIs;
begin

end;

procedure TFrameUI.DelControlUIs;
begin

end;

function TFrameUI.CreateGPImageByResource(AResourceName: string): TGPImage;
var
  LStream: IStream;
  LResStream: TStream;
  LMemStream: TMemoryStream;
begin
  Result := nil;
  LResStream := FAppContext.GetResourceSkin.GetStream(AResourceName);
  if LResStream = nil then Exit;

  try
    LStream := TStreamAdapter.Create(LResStream);
    Result := TGPImage.Create(LStream);
  finally
    LResStream.Free;
  end;
end;

procedure TFrameUI.PaintControlUIs;
var
  LIndex: Integer;
  LControlUI: TControlUI;
begin
  FLock.Lock;
  try
    for LIndex := 0 to FControlUIs.Count - 1 do begin
      LControlUI := FControlUIs.Items[LIndex];

    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TFrameUI.PaintFg(ADC: HDC; AInvalidateRect: TRect);
begin

end;

procedure TFrameUI.PaintMemBg(ADC: HDC; AInvalidateRect: TRect);
begin
  if FRepaintBk then begin
    FRepaintBk := False;
    FillRect(ADC, AInvalidateRect, FBkBrush);
    PaintControlUIs;
  end;
//  FRenderDC.BitBltX(ADC, AInvalidateRect);
end;

procedure TFrameUI.CalcControlUIRect;
begin

end;

procedure TFrameUI.DoMouseMoveTimer(ASender: TObject);
var
  LControlUI: TControlUI;
begin
  FMouseMoveTimer.Enabled := False;
  if (Abs(FMouseLastPt.X - FMouseMovePt.X) > 2)
    or (Abs(FMouseLastPt.Y - FMouseMovePt.Y) > 2) then
  begin
    FMouseLastPt := FMouseMovePt;
  end else begin
    Exit;
  end;

  if GetControlUIByMousePt(FMouseMovePt, LControlUI) then begin
    LControlUI.Hovered := True;
  end else begin
    LControlUI := nil;
  end;

  if (FHoveredControlUI <> nil)
    and (LControlUI <> FHoveredControlUI)
    and FHoveredControlUI.Hovered then begin
    FHoveredControlUI.Hovered := False;
  end;
end;

function TFrameUI.GetFocusedControlUI(var AControlUI: TControlUI): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  FLock.Lock;
  try
    for LIndex := 0 to FControlUIs.Count - 1 do begin
      AControlUI := FControlUIs.Items[LIndex];
      if (AControlUI <> nil)
        and AControlUI.Visible
        and AControlUI.Focused then begin
        Result := True;
        Break;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TFrameUI.GetControlUIByMousePt(APt: TPoint; var AControlUI: TControlUI): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  AControlUI := nil;

  FLock.Lock;
  try
    for LIndex := 0 to FControlUIs.Count - 1 do begin
      AControlUI := FControlUIs.Items[LIndex];
      if (AControlUI <> nil)
        and AControlUI.Visible
        and PtInRect(AControlUI.ControlRect, APt) then begin
        Result := True;
        Break;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TFrameUI.AddChildControlUI(AControlUI: TControlUI);
begin
  if AControlUI = nil then Exit;

  FLock.Lock;
  try
    FControlUIs.Add(AControlUI);
  finally
    FLock.UnLock;
  end;
end;

procedure TFrameUI.DeleteChildControlUI(AControlUI: TControlUI);
begin
  FLock.Lock;
  try
    FControlUIs.Remove(AControlUI);
  finally
    FLock.UnLock;
  end;
end;

procedure TFrameUI.WMNCHitTest(var Msg: TMessage);
var
  LRect: TRect;
  LMousePt: TPoint;
begin
  inherited;
  //如果点击在边框区域，则消息继续向下传递直到主窗体，解决边框拖动问题
  LMousePt.X := SmallInt(Msg.LParamLo);
  LMousePt.Y := SmallInt(Msg.LParamHi);
  GetWindowRect(Handle, LRect);
  InflateRect(LRect, -2, -2);
  if not PtInRect(LRect, LMousePt) then begin
    Msg.Result := HTTRANSPARENT;
  end;
end;

procedure TFrameUI.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
end;

procedure TFrameUI.WMSize(var Message: TWMSize);
begin
  inherited;
  CalcControlUIRect;
end;

procedure TFrameUI.WMPaint(var Message: TWMPaint);
var
  LPAINTSTRUCT: PAINTSTRUCT;
begin
  BeginPaint(Handle, LPAINTSTRUCT);
  try
    FRenderDC.SetBounds(LPAINTSTRUCT.hdc, GetClientRect);
    FRenderEngine.RefreshGraphics(LPAINTSTRUCT.hdc);
    FMemRenderEngine.RefreshGraphics(FRenderDC.MemDC);
    PaintMemBg(FRenderDC.MemDC, LPAINTSTRUCT.rcPaint);
  finally
//    SetViewportOrgEx(m_memFrameDC.DC, 0, 0, nil);
    FRenderDC.BitBltX(LPAINTSTRUCT.hdc, LPAINTSTRUCT.rcPaint);
    EndPaint(Handle, LPAINTSTRUCT);
  end;
end;

procedure TFrameUI.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  //不做任何操作，直接在绘制里刷新背景,防止闪烁
  Message.Result := 1;
end;

procedure TFrameUI.WMLButtonDown(var Message: TWMLButtonDown);
var
  LPt: TPoint;
  LControlUI: TControlUI;
begin
  inherited;
  LPt.X := Message.XPos;
  LPt.Y := Message.YPos;

//  if not Self.Focused then begin
//    Self.SetFocus;
//  end;

  if GetControlUIByMousePt(LPt, LControlUI) then begin
    LControlUI.OnLButtonDown(Message.Keys, LPt);
  end;
end;

procedure TFrameUI.WMLButtonUp(var Message: TWMLButtonUp);
var
  LPt: TPoint;
  LControlUI: TControlUI;
begin
  inherited;
  LPt.X := Message.XPos;
  LPt.Y := Message.YPos;

  if GetControlUIByMousePt(LPt, LControlUI) then begin
    LControlUI.OnLButtonUp(Message.Keys, LPt);
    LControlUI.Hovered := True;
    FHoveredControlUI := LControlUI;
  end;
end;

procedure TFrameUI.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  LPt: TPoint;
  LControlUI: TControlUI;
begin
  inherited;
  LPt.X := Message.XPos;
  LPt.Y := Message.YPos;

  if GetControlUIByMousePt(LPt, LControlUI) then begin
    LControlUI.OnLButtonDblClk(Message.Keys, LPt);
  end;
end;

procedure TFrameUI.WMRButtonDown(var Message: TWMRButtonDown);
var
  LPt: TPoint;
  LControlUI: TControlUI;
begin
  inherited;
  LPt.X := Message.XPos;
  LPt.Y := Message.YPos;

//  if not Self.Focused then begin
//    Self.SetFocus;
//  end;

  if GetControlUIByMousePt(LPt, LControlUI) then begin
    LControlUI.OnRButtonDown(Message.Keys, LPt);
  end;
end;

procedure TFrameUI.WMRButtonUp(var Message: TWMRButtonUp);
var
  LPt: TPoint;
  LControlUI: TControlUI;
begin
  inherited;
  LPt.X := Message.XPos;
  LPt.Y := Message.YPos;

  if GetControlUIByMousePt(LPt, LControlUI) then begin
    LControlUI.OnRButtonUp(Message.Keys, LPt);
  end;
end;

procedure TFrameUI.WMMouseMove(var Message: TWMMouseMove);
var
  LControlUI: TControlUI;
begin
  inherited;
  FMouseMovePt.X := Message.XPos;
  FMouseMovePt.Y := Message.YPos;
  FMouseMoveTimer.Enabled := True;
end;

procedure TFrameUI.WMMouseWheel(var Message: TWMMouseWheel);
var
  LControlUI: TControlUI;
begin
  inherited;

  if GetFocusedControlUI(LControlUI) then begin
    LControlUI.OnMouseWheel(Message.Keys, True);
  end;
end;

procedure TFrameUI.WMKeyDown(var Message: TWMKeyDown);
var
  LPt: TPoint;
  LControlUI: TControlUI;
begin
  inherited;
  if GetControlUIByMousePt(LPt, LControlUI) then begin
    LControlUI.OnKeyDown(Message.CharCode, Message.KeyData);
  end;
end;

procedure TFrameUI.WMKeyUp(var Message: TWMKeyUp);
var
  LPt: TPoint;
  LControlUI: TControlUI;
begin
  inherited;
  if GetControlUIByMousePt(LPt, LControlUI) then begin
    LControlUI.OnKeyUp(Message.CharCode, Message.KeyData);
  end;
end;

procedure TFrameUI.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTALLKEYS or DLGC_WANTARROWS or DLGC_WANTTAB;
end;

end.
