unit BaseFormUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Base Form UI
// Author：      lksoulman
// Date：        2017-10-26
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  CommCtrl,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Graphics,
  Vcl.Controls,
  GDIPOBJ,
  GDIPAPI,
  RenderDC,
  RenderGDI,
  RenderUtil;

type

  // Base Form UI
  TBaseFormUI = class(TForm)
  private
  protected
    // Is MaxBox
    FIsMaxBox: Boolean;
    // Is MinBox
    FIsMinBox: Boolean;
    // Is App Form
    FIsAppMainForm: Boolean;
    // Is Activate
    FIsActivate: Boolean;
    // Is Tracking
    FIsTracking: Boolean;
    // Hit Test
    FHitTest: Integer;
    // Mouse Down Hit
    FDownHitTest: Integer;
    // Mouse Leave Point
    FMouseLeavePt: TPoint;
    // Min Width
    FMinWidth: Integer;
    // Min Height
    FMinHeight: Integer;
    // Border Width
    FBorderWidth: Integer;
    // Caption Height
    FCaptionHeight: Integer;
    // Form Border Style
    FBorderStyleEx: TFormBorderStyle;
    // NC Render DC
    FNCRenderDC: TRenderDC;

    // Get Hit Status
    function GetHitStatus(ABtnType: Integer): Integer;
    // Paint Caption Background
    procedure PaintCaptionBK(ADC: HDC; AInvalidateRect: TRect); virtual;
    // Paint Caption Sys Menu
    procedure PaintCaptionSys(ADC: HDC; AInvalidateRect: TRect); virtual;
    // Paint Caption App Icon
    procedure PaintCaptionAppIcon(ADC: HDC; AInvalidateRect: TRect); virtual;
    // Paint Caption App Menu
    procedure PaintCaptionAppMenu(ADC: HDC; AInvalidateRect: TRect); virtual;

    // 更新鼠标点击点状态
    procedure UpdateHitTest(AHitTest: Integer; AHitMenu: Integer = -1); virtual;
    // App Menu Hit Test
    function NCAppMenuHitTest(var Msg: TMessage; ANCRect: TRect): Boolean; virtual;
    // 创建句柄
    procedure CreateWnd; override;
    // 设置标题消息响应
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    // 响应程序激活消息
    procedure OnActivateApp(var message: TWMACTIVATEAPP); message WM_ACTIVATEAPP;
    // 响应激活消息
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    // 获取最大值最小值信息
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    // 绘制非客户区域
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    // 非客户区点击测试
    procedure WMNCHitTest(var Msg: TMessage); message WM_NCHITTEST;
    // 响应非客户区激活消息
    procedure WMNCActivate(var Message: TWMNCActivate); message WM_NCACTIVATE;
    // 计算非客户区域大小
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    // 响应鼠标离开非客户区消息
    procedure WMNCMouseLeave(var Message: TMessage); message WM_NCMOUSELEAVE;
    // 响应在非客户区移动鼠标消息
    procedure WMNCMouseMove(var Message: TWMMouseMove); message WM_NCMOUSEMOVE;
    // 非客户去左键抬起消息响应
    procedure WMNCLButtonUp(var Message: TWMNCLButtonUp); message WM_NCLBUTTONUP;
    // 非客户去左键按下消息响应
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
    // 双击非客户区域
    procedure WMNCLButtonDbClk(var Message: TWMNCLButtonDblClk); message WM_NCLBUTTONDBLCLK;
    // 修改窗体创建参数
    procedure CreateParams(var Params: TCreateParams); override;
  public
    // Constructor
    constructor Create(AOwner: TComponent); override;
    // Destructor
    destructor Destroy; override;

    property IsActivate: Boolean read FIsActivate;
    property MinWidth: Integer read FMinWidth write FMinWidth;
    property MinHeight: Integer read FMinHeight write FMinHeight;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property CaptionHeight: Integer read FCaptionHeight write FCaptionHeight;
  end;

implementation

uses
  Math,
  Vcl.Imaging.pngimage,
  MultiMon;

{$R *.dfm}

{ TBaseFormUI }

constructor TBaseFormUI.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIsMaxBox := True;
  FIsMinBox := True;
  FIsAppMainForm := False;
  FIsActivate := False;
  FIsTracking := False;
  FHitTest := HTNOWHERE;
  FDownHitTest := HTNOWHERE;
  FIsTracking := False;
  FBorderWidth := 1;
//  FBorderStyleEx := bsNone;
  FCaptionHeight := 30;
  FNCRenderDC := TRenderDC.Create;
end;

destructor TBaseFormUI.Destroy;
begin
  FNCRenderDC.Free;
  inherited;
end;

procedure TBaseFormUI.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if FIsMinBox then begin
    Params.Style := Params.Style or WS_MINIMIZEBOX;
  end else begin
    Params.Style := Params.Style and (not (Params.Style and WS_MINIMIZEBOX));
  end;

  if FIsMaxBox then begin
    Params.Style := Params.Style or WS_MAXIMIZEBOX;
  end else begin
    Params.Style := Params.Style and (not (Params.Style and WS_MAXIMIZEBOX));
  end;
end;

procedure TBaseFormUI.CreateWnd;
begin
  if FBorderStyleEx = bsNone then begin
    FBorderStyleEx := Self.BorderStyle;
  end;
  BorderStyle := bsNone;
  inherited;
end;

procedure TBaseFormUI.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if not (csLoading in Self.ComponentState) then begin
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TBaseFormUI.OnActivateApp(var message: TWMACTIVATEAPP);
begin
  inherited;
//  if not message.Active then begin
//    SendMessage(Handle, WM_NCPAINT, 0, 0);
//  end;
end;

procedure TBaseFormUI.WMActivate(var Message: TWMActivate);
begin
  if message.Active in [WA_ACTIVE, WA_CLICKACTIVE] then begin
    FIsActivate := True;
  end else begin
    FIsActivate := False;
  end;
  SendMessage(Handle, WM_NCPAINT, 0, 0);
  inherited;
end;

procedure TBaseFormUI.WMNCActivate(var Message: TWMNCActivate);
begin
  message.Result := 1;          //去掉默认响应，关闭默认标题栏绘制
end;

procedure TBaseFormUI.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  //如果原来没有边框，则不设置非客户区域
  if FBorderStyleEx = bsNone then begin
    inherited;
    Exit;
  end;

  Message.CalcSize_Params.rgrc[0].Left := Message.CalcSize_Params.rgrc[0].Left + FBorderWidth;
  Message.CalcSize_Params.rgrc[0].Right := Message.CalcSize_Params.rgrc[0].Right - FBorderWidth;
  Message.CalcSize_Params.rgrc[0].Top := Message.CalcSize_Params.rgrc[0].Top + FBorderWidth + FCaptionHeight;
  Message.CalcSize_Params.rgrc[0].Bottom := Message.CalcSize_Params.rgrc[0].Bottom - FBorderWidth;

  if Message.CalcValidRects then begin
    Message.CalcSize_Params.rgrc[1].Left := Message.CalcSize_Params.rgrc[1].Left + FBorderWidth;
    Message.CalcSize_Params.rgrc[1].Right := Message.CalcSize_Params.rgrc[1].Right - FBorderWidth;
    Message.CalcSize_Params.rgrc[1].Top := Message.CalcSize_Params.rgrc[1].Top + FBorderWidth + FCaptionHeight;
    Message.CalcSize_Params.rgrc[1].Bottom := Message.CalcSize_Params.rgrc[1].Bottom - FBorderWidth;
  end;
end;

procedure TBaseFormUI.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
var
  LMonitor: HMONITOR;
  LMonitorInfo: MONITORINFO;
begin
  if FBorderStyleEx <> bsNone then begin
    Message.MinMaxInfo.ptMinTrackSize.X := FMinWidth;
    Message.MinMaxInfo.ptMinTrackSize.Y := FMinHeight;
    // 调整窗口最大化时高度，避免窗口最大化时盖住主屏任务栏
    LMonitorInfo.cbSize := SizeOf(MONITORINFO);
    LMonitor := MonitorFromWindow(Handle, MONITOR_DEFAULTTONULL);
    if LMonitor <> 0 then begin
      GetMonitorInfo(LMonitor, @LMonitorInfo);
      // ptMaxSize的默认大小为主屏的分辨率，在不同分辨率的屏幕上是以默认大小为基准按比例设置的。
      // 如主屏分辨率X1*Y1,副屏分辨率X2*Y2，如果该值设为x*y，在副屏上计算的实际大小是x*X2/X1和y*Y2/Y1
      Message.MinMaxInfo.ptMaxSize.X :=
        Min(LMonitorInfo.rcWork.Right - LMonitorInfo.rcWork.Left, Message.MinMaxInfo.ptMaxSize.X);
      Message.MinMaxInfo.ptMaxSize.Y :=
        Min(LMonitorInfo.rcWork.Bottom - LMonitorInfo.rcWork.Top, Message.MinMaxInfo.ptMaxSize.Y);
    end;
  end;
  inherited;
end;

procedure TBaseFormUI.WMNCHitTest(var Msg: TMessage);
var
  I: Integer;
  LMousePt: TPoint;
  LRect, LBorderRect, LMenuRect, LCaptionRect, LButtonRect: TRect;
begin
  // 如果是无边框嵌入窗体，则让消息继续传递，解决边框拖动问题
  if FBorderStyleEx = bsNone then begin
    inherited;
    Msg.Result := HTTRANSPARENT;
    Exit;
  end;
  LMousePt.X := SmallInt(Msg.LParamLo);
  LMousePt.Y := SmallInt(Msg.LParamHi);
  GetWindowRect(Handle, LRect);
  // 如果窗体处在一般状态且可拖动大小，则判断鼠标是否点击在边框
  if (WindowState = wsNormal)
    and (FBorderStyleEx = bsSizeable) then begin
    LBorderRect := LRect;
    InflateRect(LBorderRect, -4, -4);
    // 如果鼠标在边框区域
    if not PtInRect(LBorderRect, LMousePt) then begin
      if LMousePt.Y <= LBorderRect.Top then begin
        if LMousePt.X < LRect.Left + 8 then begin
          Msg.Result := HTTOPLEFT
        end else if LMousePt.X > LRect.Right - 8 then begin
          Msg.Result := HTTOPRIGHT
        end else begin
          Msg.Result := HTTOP;
        end;
      end else if LMousePt.Y >= LBorderRect.Bottom then begin
        if LMousePt.X < LRect.Left + 8 then begin
          Msg.Result := HTBOTTOMLEFT
        end else if LMousePt.X > LRect.Right - 8 then begin
          Msg.Result := HTBOTTOMRIGHT
        end else begin
          Msg.Result := HTBOTTOM;
        end;
      end else if LMousePt.X <= LBorderRect.Left then begin
        if LMousePt.Y < LRect.Top + 8 then begin
          Msg.Result := HTTOPLEFT
        end else if LMousePt.Y > LRect.Bottom - 8 then begin
          Msg.Result := HTBOTTOMLEFT
        end else begin
          Msg.Result := HTLEFT;
        end;
      end else begin
        if LMousePt.Y < LRect.Top + 8 then begin
          Msg.Result := HTTOPRIGHT
        end else if LMousePt.Y > LRect.Bottom - 8 then begin
          Msg.Result := HTBOTTOMRIGHT
        end else begin
          Msg.Result := HTRIGHT;
        end;
      end;
      UpdateHitTest(Msg.Result);
      Exit;
    end;
  end;

  //判断鼠标是否在标题区域
  LCaptionRect := LRect;
  LCaptionRect.Bottom := LRect.Top + FBorderWidth + FCaptionHeight;

  if PtInRect(LCaptionRect, LMousePt) then begin
    Msg.Result := HTCAPTION;
    //判断鼠标是否点击在关闭按钮上
    LButtonRect.Top := LRect.Top + FBorderWidth;
    LButtonRect.Bottom := LButtonRect.Top + 30;
    LButtonRect.Right := LRect.Right - FBorderWidth;
    LButtonRect.Left := LButtonRect.Right - 30;
    if PtInRect(LButtonRect, LMousePt) then  begin
      Msg.Result := HTCLOSE;
      UpdateHitTest(Msg.Result);
      Exit;
    end;

    if FIsMaxBox then begin
      //计算最大化按钮
      LButtonRect.Right := LButtonRect.Left;
      LButtonRect.Left := LButtonRect.Right - 30;
      if PtInRect(LButtonRect, LMousePt) then begin
        Msg.Result := HTMAXBUTTON;
        UpdateHitTest(Msg.Result);
        Exit;
      end;
    end;

    if FIsMinBox then begin
      LButtonRect.Right := LButtonRect.Left;
      LButtonRect.Left := LButtonRect.Right - 30;
      if PtInRect(LButtonRect, LMousePt) then begin
        Msg.Result := HTMINBUTTON;
        UpdateHitTest(Msg.Result);
        Exit;
      end;
    end;

    if FIsAppMainForm then begin
      LMenuRect := LCaptionRect;
      LMenuRect.Right := LButtonRect.Left;
      LMenuRect.Left := LCaptionRect.Left + 60;
      if NCAppMenuHitTest(Msg, LMenuRect) then begin
        Exit;
      end;
    end;
  end else begin
    inherited;
  end;
  UpdateHitTest(Msg.Result);
end;

function TBaseFormUI.NCAppMenuHitTest(var Msg: TMessage; ANCRect: TRect): Boolean;
begin
  Result := False;
end;

procedure TBaseFormUI.UpdateHitTest(AHitTest, AHitMenu: Integer);
begin
  if (FHitTest <> AHitTest) then begin
    FHitTest := AHitTest;
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TBaseFormUI.WMNCLButtonDown(var Message: TWMNCLButtonDown);
begin
  // 保存按下时鼠标位置
  FMouseLeavePt.X := Message.XCursor;
  FMouseLeavePt.Y := Message.YCursor;
  // 保存按下是鼠标的点击位置类型
  FDownHitTest := Message.HitTest;
  SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  // 点击激活
  if not Self.IsActivate then begin
    PostMessage(Self.Handle, WM_ACTIVATE, 1, 0);
  end;
  // 调用inherited会导致 WMNCLButtonUp 不响应,所以屏蔽一些，但窗体大小拖动还需要 Inherited
  if (Message.HitTest <> HTCAPTION)
    and (Message.HitTest <> HTCLOSE)
    and (Message.HitTest <> HTMENU)
    and (Message.HitTest <> HTMAXBUTTON)
    and (Message.HitTest <> HTMINBUTTON)
    and (WindowState <> wsMaximized) then begin
    inherited;
  end;
end;

procedure TBaseFormUI.WMNCLButtonUp(var Message: TWMNCLButtonUp);
begin
  //如果抬起时和按下时位置一致
  if Message.HitTest = FDownHitTest then begin
    case Message.HitTest of
      HTMENU:
        begin
          SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
        end;
      HTCLOSE:
        Self.Close;
      HTMAXBUTTON:
        begin
          FHitTest := HTNOWHERE;
          if Self.WindowState = wsNormal then
            Self.WindowState := wsMaximized
          else
            Self.WindowState := wsNormal;
        end;
      HTMINBUTTON:
        Self.WindowState := wsMinimized;
    end;
  end;
  FDownHitTest := HTNOWHERE;
  inherited;
end;

procedure TBaseFormUI.WMNCMouseMove(var Message: TWMMouseMove);
var
  LEvent: TTrackMouseEvent;
  LPosX, LPosY, LWidth: Integer;
begin
  if (Abs(FMouseLeavePt.X - Message.XPos) > 3)
    or (Abs(FMouseLeavePt.Y - Message.YPos) > 3) then begin
    if FDownHitTest = HTCAPTION then begin
      //如果窗体最大化状态，则拖动还原
      if (FBorderStyleEx = bsSizeable)
        and (Self.WindowState = wsMaximized) then begin
        LPosX := Self.Left;
        LPosY := Self.Top;
        LWidth := Self.Width;
        Self.WindowState := wsNormal;
        //收缩窗体后按比例计算窗体的位置
        LPosX := LPosX + (Message.XPos - LPosX) * Self.Width div LWidth;
        SetBounds(LPosX, LPosY, Width, Height);
      end;
      FMouseLeavePt.X := Message.XPos;
      FMouseLeavePt.Y := Message.YPos;
      SendMessage(Self.Handle, WM_SYSCOMMAND, SC_MOVE + HTCAPTION, 0);
      Exit;
    end;
  end;

  inherited;
  //跟踪鼠标移开非客户区消息，如果无此操作，则收不到 WM_NCMOUSELEAVE 消息
  if not FIsTracking then begin
    FIsTracking := True;
    LEvent.cbSize := SizeOf(TTrackMouseEvent);
    //Flag 需指定 TME_NONCLIENT，否则只会发送离开客户区域消息
    LEvent.dwFlags := TME_LEAVE or TME_NONCLIENT;
    LEvent.hwndTrack := Handle;
    LEvent.dwHoverTime := 20;
    //发送离开非客户区消息
    TrackMouseEvent(LEvent);
  end;
end;

procedure TBaseFormUI.WMNCMouseLeave(var Message: TMessage);
begin
  inherited;
  FIsTracking := False;
  UpdateHitTest(HHT_NOWHERE);
end;

procedure TBaseFormUI.WMNCLButtonDbClk(var Message: TWMNCLButtonDblClk);
begin
  if (FBorderStyleEx = bsSizeable)
    and (Message.HitTest = HTCAPTION) then begin
    if Self.WindowState = wsMaximized then
      Self.WindowState := wsNormal
    else
      Self.WindowState := wsMaximized;
  end;
  UpdateHitTest(HHT_NOWHERE);
end;

procedure TBaseFormUI.WMNCPaint(var Message: TMessage);
var
  LDC: HDC;
  I, LIndex: Integer;
  LNCGPRect: TGPRect;
  LRect, LNCRect, LSysRect, LAppIconRect, LAppMenuRect: TRect;
begin
  //没有边框，不绘制
  if FBorderStyleEx = bsNone then
    Exit;

  LDC := GetWindowDC(Handle);
  try
    SetWindowRgn(handle, 0, False);
    GetWindowRect(Handle, LRect);
    OffsetRect(LRect, -LRect.Left, -LRect.Top);
    //计算标题区域(不包括边框)
    LNCRect := LRect;
    LNCRect.Top := LRect.Top + FBorderWidth;
    LNCRect.Bottom := LNCRect.Top + FCaptionHeight;
    LNCRect.Left := LRect.Left + FBorderWidth;
    LNCRect.Right := LRect.Right - FBorderWidth;

    if not FNCRenderDC.IsInit then begin
      FNCRenderDC.SetDC(LDC);
    end;
    FNCRenderDC.SetBounds(LDC, LNCRect);
    SetBkMode(FNCRenderDC.MemDC, TRANSPARENT);

    PaintCaptionBK(FNCRenderDC.MemDC, LNCRect);

    LSysRect := LNCRect;
    LSysRect.Left := LSysRect.Right - 30;

    if FIsMaxBox then begin
      LSysRect.Left := LSysRect.Left - 30;
    end;

    if FIsMinBox then begin
      LSysRect.Left := LSysRect.Left - 30;
    end;

    PaintCaptionSys(FNCRenderDC.MemDC, LSysRect);

    LAppIconRect := LNCRect;
    LAppIconRect.Right := LAppIconRect.Left + 60;
    PaintCaptionAppIcon(FNCRenderDC.MemDC, LAppIconRect);

    LAppMenuRect := LNCRect;
    LAppMenuRect.Left := LAppIconRect.Right;
    LAppMenuRect.Right := LSysRect.Left;
    PaintCaptionAppMenu(FNCRenderDC.MemDC, LAppMenuRect);

    FNCRenderDC.BitBltX(LDC);
  finally
    Message.Result := 0;
    ReleaseDC(Handle, LDC);
  end;
end;

function TBaseFormUI.GetHitStatus(ABtnType: Integer): Integer;
begin
  Result := 0;
  if FIsActivate then begin
    //热点状态
    if FHitTest = ABtnType then begin
      if FDownHitTest = ABtnType then begin
        Result := 2;
      end else begin
        Result := 1;
      end;
    end
  end;
end;

procedure TBaseFormUI.PaintCaptionBK(ADC: HDC; AInvalidateRect: TRect);
begin
  FillSolidRect(ADC, @AInvalidateRect, APPC_MAINFORM_CAPTION_BACK);
end;

procedure TBaseFormUI.PaintCaptionSys(ADC: HDC; AInvalidateRect: TRect);
var
  LCloseRect, LMaxRect, LMinRect, LRect: TRect;

  procedure PaintSys(ARect: TRect; ABtnType: Integer; AResStrem: TResourceStream);
  var
    LGPImage: TGPImage;
  begin
    LGPImage := ResourceStreamToGPImage(AResStrem);
    if LGPImage = nil then Exit;

    case GetHitStatus(ABtnType) of
      1:
        begin
          LRect := Rect(30, 0, 60, 30);
        end;
      2:
        begin
          LRect := Rect(60, 0, 90, 30);
        end;
    else
      begin
        LRect := Rect(0, 0, 30, 30);
      end;
    end;
    DrawImageX(FNCRenderDC.GPGraphics, LGPImage, ARect, LRect);
    LGPImage.Free;
  end;
begin
  LCloseRect := AInvalidateRect;
  LCloseRect.Left := LCloseRect.Right - 30;
  PaintSys(LCloseRect, HTCLOSE, APPIMG_CAPTION_SYSCLOSE);

  if FIsMaxBox then begin
    LMaxRect := LCloseRect;
    OffsetRect(LMaxRect, -30, 0);
    if WindowState = wsNormal then begin
      PaintSys(LMaxRect, HTMAXBUTTON, APPIMG_CAPTION_SYSMAX);
    end else begin
      PaintSys(LMaxRect, HTMAXBUTTON, APPIMG_CAPTION_SYSRES);
    end;
  end;

  if FIsMinBox then begin
    LMinRect := LCloseRect;
    OffsetRect(LMinRect, -60, 0);
    PaintSys(LMinRect, HTMINBUTTON, APPIMG_CAPTION_SYSMIN);
  end;
end;

procedure TBaseFormUI.PaintCaptionAppIcon(ADC: HDC; AInvalidateRect: TRect);
begin

end;

procedure TBaseFormUI.PaintCaptionAppMenu(ADC: HDC; AInvalidateRect: TRect);
begin

end;

end.

