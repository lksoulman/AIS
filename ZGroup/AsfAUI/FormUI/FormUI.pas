unit FormUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Form UI
// Author：      lksoulman
// Date：        2017-10-16
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

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
  Vcl.Dialogs;

type

  // 基类窗口
  TFormUI = class(TForm)
  private
  protected
    // 是不是激活状态
    FIsActivate: Boolean;
    // 是否跟踪鼠标事件
    FIsTracking: Boolean;
    // 鼠标命中位置
    FHitTest: Integer;
    // 鼠标按下位置
    FDownHitTest: Integer;
    // 鼠标最后的位置
    FMouseLeavePt: TPoint;
    // 宽度
    FMinWidth: Integer;
    // 高度
    FMinHeight: Integer;
    // 边框宽度
    FBorderWidth: Integer;
    // 标题高度
    FCaptionHeight: Integer;
    // 窗体原边框类型
    FBorderStyleEx: TFormBorderStyle;

    // 更新鼠标点击点状态
    procedure UpdateHitTest(AHitTest: Integer; AHitMenu: Integer = -1);
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
    // 绘制客户区
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    // 擦除背景
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
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
    // 构造函数
    constructor Create(AOwner: TComponent); override;
    // 析构函数
    destructor Destroy; override;
  published
    // 当前窗体是否是激活状态
    property IsActivate: Boolean read FIsActivate;
    // 窗体最小宽度
    property MinWidth: Integer read FMinWidth write FMinWidth;
    // 窗体最小高度
    property MinHeight: Integer read FMinHeight write FMinHeight;
    // 边框宽度
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    // 标题栏高度
    property CaptionHeight: Integer read FCaptionHeight write FCaptionHeight;
  end;

implementation

uses
  Math,
  MultiMon;

{$R *.dfm}

{ TFormUI }

// 构造函数
constructor TFormUI.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHitTest := HTNOWHERE;
  FDownHitTest := HTNOWHERE;
  FIsTracking := False;
  FBorderWidth := 1;
  FBorderStyleEx := bsNone;
end;

// 析构函数
destructor TFormUI.Destroy;
begin

  inherited;
end;

// 修改窗体创建参数
procedure TFormUI.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_MINIMIZEBOX;
end;

// 创建句柄
procedure TFormUI.CreateWnd;
begin
  if FBorderStyleEx = bsNone then
    FBorderStyleEx := Self.BorderStyle;
  BorderStyle := bsNone;
  inherited;
end;

// 设置标题消息响应
procedure TFormUI.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if not (csLoading in Self.ComponentState) then
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
end;

// 响应程序激活消息
procedure TFormUI.OnActivateApp(var message: TWMACTIVATEAPP);
begin
  inherited;
  if not message.Active then begin

  end;
end;

// 响应激活消息
procedure TFormUI.WMActivate(var Message: TWMActivate);
begin
  if message.Active in [WA_ACTIVE, WA_CLICKACTIVE] then begin
    FIsActivate := True;
  end else begin
    FIsActivate := False;
  end;
  SendMessage(Handle, WM_NCPAINT, 0, 0);
  inherited;
end;

// 响应非客户区激活消息
procedure TFormUI.WMNCActivate(var Message: TWMNCActivate);
begin
  message.Result := 1;          //去掉默认响应，关闭默认标题栏绘制
end;

// 计算非客户区域大小
procedure TFormUI.WMNCCalcSize(var Message: TWMNCCalcSize);
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

// 获取最大值最小值信息
procedure TFormUI.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
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

procedure TFormUI.WMPaint(var Message: TWMPaint);
var
  LDC: HDC;
  LPaintStruct: PAINTSTRUCT;
begin
  LDC := BeginPaint(Handle, LPaintStruct);
  try

  finally
    EndPaint(Handle, LPaintStruct);
  end;
  Message.Result := 0;
end;

procedure TFormUI.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin

end;

// 非客户区点击测试
procedure TFormUI.WMNCHitTest(var Msg: TMessage);
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
        if LMousePt.X < LRect.Left + 8 then
          Msg.Result := HTTOPLEFT
        else if LMousePt.X > LRect.Right - 8 then
          Msg.Result := HTTOPRIGHT
        else
          Msg.Result := HTTOP;
      end else if LMousePt.Y >= LBorderRect.Bottom then begin
        if LMousePt.X < LRect.Left + 8 then
          Msg.Result := HTBOTTOMLEFT
        else if LMousePt.X > LRect.Right - 8 then
          Msg.Result := HTBOTTOMRIGHT
        else
          Msg.Result := HTBOTTOM;
      end else if LMousePt.X <= LBorderRect.Left then begin
        if LMousePt.Y < LRect.Top + 8 then
          Msg.Result := HTTOPLEFT
        else if LMousePt.Y > LRect.Bottom - 8 then
          Msg.Result := HTBOTTOMLEFT
        else
          Msg.Result := HTLEFT;
      end else begin
        if LMousePt.Y < LRect.Top + 8 then
          Msg.Result := HTTOPRIGHT
        else if LMousePt.Y > LRect.Bottom - 8 then
          Msg.Result := HTBOTTOMRIGHT
        else
          Msg.Result := HTRIGHT;
      end;
      UpdateHitTest(msg.Result);
      Exit;
    end;
  end;

  //判断鼠标是否在标题区域
  LCaptionRect := LRect;
  LCaptionRect.Bottom := LRect.Top + FBorderWidth + FCaptionHeight;

  if PtInRect(LCaptionRect, LMousePt) then begin
    msg.Result := HTCAPTION;
    //判断鼠标是否点击在关闭按钮上
    LButtonRect.Top := LRect.Top + FBorderWidth;
    LButtonRect.Bottom := LButtonRect.Top + 30;
    LButtonRect.Right := LRect.Right - FBorderWidth;
    LButtonRect.Left := LButtonRect.Right - 30;
    if PtInRect(LButtonRect, LMousePt) then  begin
      Msg.Result := HTCLOSE;
      UpdateHitTest(msg.Result);
      Exit;
    end;
    //判断鼠标是否点击在最大化最小化按钮上
    if FBorderStyleEx = bsSizeable then begin
      //计算最大化按钮
      LButtonRect.Right := LButtonRect.Left;
      LButtonRect.Left := LButtonRect.Right - 30;
      if PtInRect(LButtonRect, LMousePt) then
      begin
        Msg.Result := HTMAXBUTTON;
        UpdateHitTest(Msg.Result);
        Exit;
      end;
    end;
  end
  else
    inherited;
  UpdateHitTest(msg.Result);
end;

// 更新鼠标点击点状态
procedure TFormUI.UpdateHitTest(AHitTest, AHitMenu: Integer);
begin
  if (FHitTest <> AHitTest) then begin
    FHitTest := AHitTest;
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  end;
end;

//非客户去左键按下消息响应
procedure TFormUI.WMNCLButtonDown(var Message: TWMNCLButtonDown);
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

//非客户去左键抬起消息响应
procedure TFormUI.WMNCLButtonUp(var Message: TWMNCLButtonUp);
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
//      HTOBJECT:
//        OnClickNewFormButton;
    end;
  end;
  FDownHitTest := HTNOWHERE;
  inherited;
end;

//响应在非客户区移动鼠标消息
procedure TFormUI.WMNCMouseMove(var Message: TWMMouseMove);
var
  LPosX, LPosY, LWidth: Integer;
  LEvent: TTrackMouseEvent;
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
  //跟踪鼠标移开非客户区消息，如果无此操作，则收不到WM_NCMOUSELEAVE消息
  if not FIsTracking then begin
    FIsTracking := True;
    LEvent.cbSize := SizeOf(TTrackMouseEvent);
    //Flag需指定TME_NONCLIENT，否则只会发送离开客户区域消息
    LEvent.dwFlags := TME_LEAVE or TME_NONCLIENT;
    LEvent.hwndTrack := Handle;
    LEvent.dwHoverTime := 20;
    //发送离开非客户区消息
    TrackMouseEvent(LEvent);
  end;
end;

//响应鼠标离开非客户区消息
procedure TFormUI.WMNCMouseLeave(var Message: TMessage);
begin
  inherited;
  FIsTracking := False;
//  UpdateHitTest(HHT_NOWHERE);
end;

//双击非客户区域
procedure TFormUI.WMNCLButtonDbClk(var Message: TWMNCLButtonDblClk);
begin
  if (FBorderStyleEx = bsSizeable)
    and (Message.HitTest = HTCAPTION) then begin
    if Self.WindowState = wsMaximized then
      Self.WindowState := wsNormal
    else
      Self.WindowState := wsMaximized;
  end;
//  UpdateHitTest(HHT_NOWHERE);
end;

//绘制非客户区域
procedure TFormUI.WMNCPaint(var Message: TMessage);
var
  LDC: HDC;
  I, LIndex: Integer;
  LRect, LNCTitleRect, LMenuRect: TRect;
begin
  //没有边框，不绘制
  if FBorderStyleEx = bsNone then
    Exit;

  LDC := GetWindowDC(Handle);
  try
    SetWindowRgn(handle, 0, False);
    GetWindowRect(Handle, LRect);
    OffsetRect(LRect, -LRect.Left, -LRect.Top);
//    //计算标题区域(不包括边框)
//    LClientRect := LRect;
//    LClientRect.Top := LRect.Top + FBorderWidth;
//    LClientRect.Bottom := LClientRect.Top + FCaptionHeight;
//    LClientRect.Left := LRect.Left + FBorderWidth;
//    LClientRect.Right := LRect.Right - FBorderWidth;

  finally
    Message.Result := 0;
    ReleaseDC(Handle, LDC);
  end;
end;

end.
