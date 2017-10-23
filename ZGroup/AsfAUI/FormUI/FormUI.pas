unit FormUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Form UI
// Author��      lksoulman
// Date��        2017-10-16
// Comments��
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

  // ���ര��
  TFormUI = class(TForm)
  private
  protected
    // �ǲ��Ǽ���״̬
    FIsActivate: Boolean;
    // �Ƿ��������¼�
    FIsTracking: Boolean;
    // �������λ��
    FHitTest: Integer;
    // ��갴��λ��
    FDownHitTest: Integer;
    // �������λ��
    FMouseLeavePt: TPoint;
    // ���
    FMinWidth: Integer;
    // �߶�
    FMinHeight: Integer;
    // �߿���
    FBorderWidth: Integer;
    // ����߶�
    FCaptionHeight: Integer;
    // ����ԭ�߿�����
    FBorderStyleEx: TFormBorderStyle;

    // �����������״̬
    procedure UpdateHitTest(AHitTest: Integer; AHitMenu: Integer = -1);
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
    // ���ƿͻ���
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    // ��������
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
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
    // ���캯��
    constructor Create(AOwner: TComponent); override;
    // ��������
    destructor Destroy; override;
  published
    // ��ǰ�����Ƿ��Ǽ���״̬
    property IsActivate: Boolean read FIsActivate;
    // ������С���
    property MinWidth: Integer read FMinWidth write FMinWidth;
    // ������С�߶�
    property MinHeight: Integer read FMinHeight write FMinHeight;
    // �߿���
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    // �������߶�
    property CaptionHeight: Integer read FCaptionHeight write FCaptionHeight;
  end;

implementation

uses
  Math,
  MultiMon;

{$R *.dfm}

{ TFormUI }

// ���캯��
constructor TFormUI.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHitTest := HTNOWHERE;
  FDownHitTest := HTNOWHERE;
  FIsTracking := False;
  FBorderWidth := 1;
  FBorderStyleEx := bsNone;
end;

// ��������
destructor TFormUI.Destroy;
begin

  inherited;
end;

// �޸Ĵ��崴������
procedure TFormUI.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_MINIMIZEBOX;
end;

// �������
procedure TFormUI.CreateWnd;
begin
  if FBorderStyleEx = bsNone then
    FBorderStyleEx := Self.BorderStyle;
  BorderStyle := bsNone;
  inherited;
end;

// ���ñ�����Ϣ��Ӧ
procedure TFormUI.CMTextChanged(var Message: TMessage);
begin
  inherited;
  if not (csLoading in Self.ComponentState) then
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
end;

// ��Ӧ���򼤻���Ϣ
procedure TFormUI.OnActivateApp(var message: TWMACTIVATEAPP);
begin
  inherited;
  if not message.Active then begin

  end;
end;

// ��Ӧ������Ϣ
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

// ��Ӧ�ǿͻ���������Ϣ
procedure TFormUI.WMNCActivate(var Message: TWMNCActivate);
begin
  message.Result := 1;          //ȥ��Ĭ����Ӧ���ر�Ĭ�ϱ���������
end;

// ����ǿͻ������С
procedure TFormUI.WMNCCalcSize(var Message: TWMNCCalcSize);
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

// ��ȡ���ֵ��Сֵ��Ϣ
procedure TFormUI.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
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

// �ǿͻ����������
procedure TFormUI.WMNCHitTest(var Msg: TMessage);
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

  //�ж�����Ƿ��ڱ�������
  LCaptionRect := LRect;
  LCaptionRect.Bottom := LRect.Top + FBorderWidth + FCaptionHeight;

  if PtInRect(LCaptionRect, LMousePt) then begin
    msg.Result := HTCAPTION;
    //�ж�����Ƿ����ڹرհ�ť��
    LButtonRect.Top := LRect.Top + FBorderWidth;
    LButtonRect.Bottom := LButtonRect.Top + 30;
    LButtonRect.Right := LRect.Right - FBorderWidth;
    LButtonRect.Left := LButtonRect.Right - 30;
    if PtInRect(LButtonRect, LMousePt) then  begin
      Msg.Result := HTCLOSE;
      UpdateHitTest(msg.Result);
      Exit;
    end;
    //�ж�����Ƿ����������С����ť��
    if FBorderStyleEx = bsSizeable then begin
      //������󻯰�ť
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

// �����������״̬
procedure TFormUI.UpdateHitTest(AHitTest, AHitMenu: Integer);
begin
  if (FHitTest <> AHitTest) then begin
    FHitTest := AHitTest;
    SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  end;
end;

//�ǿͻ�ȥ���������Ϣ��Ӧ
procedure TFormUI.WMNCLButtonDown(var Message: TWMNCLButtonDown);
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

//�ǿͻ�ȥ���̧����Ϣ��Ӧ
procedure TFormUI.WMNCLButtonUp(var Message: TWMNCLButtonUp);
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
//      HTOBJECT:
//        OnClickNewFormButton;
    end;
  end;
  FDownHitTest := HTNOWHERE;
  inherited;
end;

//��Ӧ�ڷǿͻ����ƶ������Ϣ
procedure TFormUI.WMNCMouseMove(var Message: TWMMouseMove);
var
  LPosX, LPosY, LWidth: Integer;
  LEvent: TTrackMouseEvent;
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
  //��������ƿ��ǿͻ�����Ϣ������޴˲��������ղ���WM_NCMOUSELEAVE��Ϣ
  if not FIsTracking then begin
    FIsTracking := True;
    LEvent.cbSize := SizeOf(TTrackMouseEvent);
    //Flag��ָ��TME_NONCLIENT������ֻ�ᷢ���뿪�ͻ�������Ϣ
    LEvent.dwFlags := TME_LEAVE or TME_NONCLIENT;
    LEvent.hwndTrack := Handle;
    LEvent.dwHoverTime := 20;
    //�����뿪�ǿͻ�����Ϣ
    TrackMouseEvent(LEvent);
  end;
end;

//��Ӧ����뿪�ǿͻ�����Ϣ
procedure TFormUI.WMNCMouseLeave(var Message: TMessage);
begin
  inherited;
  FIsTracking := False;
//  UpdateHitTest(HHT_NOWHERE);
end;

//˫���ǿͻ�����
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

//���Ʒǿͻ�����
procedure TFormUI.WMNCPaint(var Message: TMessage);
var
  LDC: HDC;
  I, LIndex: Integer;
  LRect, LNCTitleRect, LMenuRect: TRect;
begin
  //û�б߿򣬲�����
  if FBorderStyleEx = bsNone then
    Exit;

  LDC := GetWindowDC(Handle);
  try
    SetWindowRgn(handle, 0, False);
    GetWindowRect(Handle, LRect);
    OffsetRect(LRect, -LRect.Left, -LRect.Top);
//    //�����������(�������߿�)
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
