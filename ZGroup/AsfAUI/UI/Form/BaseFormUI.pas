unit BaseFormUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Base Form UI
// Author��      lksoulman
// Date��        2017-10-26
// Comments��
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

    // �����������״̬
    procedure UpdateHitTest(AHitTest: Integer; AHitMenu: Integer = -1); virtual;
    // App Menu Hit Test
    function NCAppMenuHitTest(var Msg: TMessage; ANCRect: TRect): Boolean; virtual;
    // �������
    procedure CreateWnd; override;
    // ���ñ�����Ϣ��Ӧ
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    // ��Ӧ���򼤻���Ϣ
    procedure OnActivateApp(var message: TWMACTIVATEAPP); message WM_ACTIVATEAPP;
    // ��Ӧ������Ϣ
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    // ��ȡ���ֵ��Сֵ��Ϣ
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    // ���Ʒǿͻ�����
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    // �ǿͻ����������
    procedure WMNCHitTest(var Msg: TMessage); message WM_NCHITTEST;
    // ��Ӧ�ǿͻ���������Ϣ
    procedure WMNCActivate(var Message: TWMNCActivate); message WM_NCACTIVATE;
    // ����ǿͻ������С
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    // ��Ӧ����뿪�ǿͻ�����Ϣ
    procedure WMNCMouseLeave(var Message: TMessage); message WM_NCMOUSELEAVE;
    // ��Ӧ�ڷǿͻ����ƶ������Ϣ
    procedure WMNCMouseMove(var Message: TWMMouseMove); message WM_NCMOUSEMOVE;
    // �ǿͻ�ȥ���̧����Ϣ��Ӧ
    procedure WMNCLButtonUp(var Message: TWMNCLButtonUp); message WM_NCLBUTTONUP;
    // �ǿͻ�ȥ���������Ϣ��Ӧ
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
    // ˫���ǿͻ�����
    procedure WMNCLButtonDbClk(var Message: TWMNCLButtonDblClk); message WM_NCLBUTTONDBLCLK;
    // �޸Ĵ��崴������
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
  message.Result := 1;          //ȥ��Ĭ����Ӧ���ر�Ĭ�ϱ���������
end;

procedure TBaseFormUI.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  //���ԭ��û�б߿������÷ǿͻ�����
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
    // �����������ʱ�߶ȣ����ⴰ�����ʱ��ס����������
    LMonitorInfo.cbSize := SizeOf(MONITORINFO);
    LMonitor := MonitorFromWindow(Handle, MONITOR_DEFAULTTONULL);
    if LMonitor <> 0 then begin
      GetMonitorInfo(LMonitor, @LMonitorInfo);
      // ptMaxSize��Ĭ�ϴ�СΪ�����ķֱ��ʣ��ڲ�ͬ�ֱ��ʵ���Ļ������Ĭ�ϴ�СΪ��׼���������õġ�
      // �������ֱ���X1*Y1,�����ֱ���X2*Y2�������ֵ��Ϊx*y���ڸ����ϼ����ʵ�ʴ�С��x*X2/X1��y*Y2/Y1
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
  // ������ޱ߿�Ƕ�봰�壬������Ϣ�������ݣ�����߿��϶�����
  if FBorderStyleEx = bsNone then begin
    inherited;
    Msg.Result := HTTRANSPARENT;
    Exit;
  end;
  LMousePt.X := SmallInt(Msg.LParamLo);
  LMousePt.Y := SmallInt(Msg.LParamHi);
  GetWindowRect(Handle, LRect);
  // ������崦��һ��״̬�ҿ��϶���С�����ж�����Ƿ����ڱ߿�
  if (WindowState = wsNormal)
    and (FBorderStyleEx = bsSizeable) then begin
    LBorderRect := LRect;
    InflateRect(LBorderRect, -4, -4);
    // �������ڱ߿�����
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

  //�ж�����Ƿ��ڱ�������
  LCaptionRect := LRect;
  LCaptionRect.Bottom := LRect.Top + FBorderWidth + FCaptionHeight;

  if PtInRect(LCaptionRect, LMousePt) then begin
    Msg.Result := HTCAPTION;
    //�ж�����Ƿ����ڹرհ�ť��
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
      //������󻯰�ť
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
  // ���水��ʱ���λ��
  FMouseLeavePt.X := Message.XCursor;
  FMouseLeavePt.Y := Message.YCursor;
  // ���水�������ĵ��λ������
  FDownHitTest := Message.HitTest;
  SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  // �������
  if not Self.IsActivate then begin
    PostMessage(Self.Handle, WM_ACTIVATE, 1, 0);
  end;
  // ����inherited�ᵼ�� WMNCLButtonUp ����Ӧ,��������һЩ���������С�϶�����Ҫ Inherited
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
  //���̧��ʱ�Ͱ���ʱλ��һ��
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
      //����������״̬�����϶���ԭ
      if (FBorderStyleEx = bsSizeable)
        and (Self.WindowState = wsMaximized) then begin
        LPosX := Self.Left;
        LPosY := Self.Top;
        LWidth := Self.Width;
        Self.WindowState := wsNormal;
        //��������󰴱������㴰���λ��
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
  //��������ƿ��ǿͻ�����Ϣ������޴˲��������ղ��� WM_NCMOUSELEAVE ��Ϣ
  if not FIsTracking then begin
    FIsTracking := True;
    LEvent.cbSize := SizeOf(TTrackMouseEvent);
    //Flag ��ָ�� TME_NONCLIENT������ֻ�ᷢ���뿪�ͻ�������Ϣ
    LEvent.dwFlags := TME_LEAVE or TME_NONCLIENT;
    LEvent.hwndTrack := Handle;
    LEvent.dwHoverTime := 20;
    //�����뿪�ǿͻ�����Ϣ
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
  //û�б߿򣬲�����
  if FBorderStyleEx = bsNone then
    Exit;

  LDC := GetWindowDC(Handle);
  try
    SetWindowRgn(handle, 0, False);
    GetWindowRect(Handle, LRect);
    OffsetRect(LRect, -LRect.Left, -LRect.Top);
    //�����������(�������߿�)
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
    //�ȵ�״̬
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

