unit CanvasUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  GDIPOBJ,
  GDIPAPI,
  SysUtils,
  Graphics,
  RenderUI,
  CommonRefCounter;

type

  // ����
  TCanvasUI = class(TAutoObject)
  private
  protected
    // ���ھ��
    FHWnd: HWND;
    // ���� DC
    FBackDC: HDC;
    // ���� DC �ļ���λͼ
    FBackBitmap: HBITMAP;
    // ���� DC �ϴε�λͼ
    FOldBackBitmap: HBITMAP;
    // �ڴ� DC
    FMemDC: HDC;
    // �ڴ� DC �ļ���λͼ
    FMemBitmap: HBITMAP;
    // �ڴ� DC �ϴε�λͼ
    FOldMemBitmap: HBITMAP;
    // ������
    FWidth: Integer;
    // ������
    FHeight: Integer;
    // ������������
    FDrawRect: TRect;
    // ����ͻ�����
    FClientRect: TRect;
    // �滭��Ⱦ����
    FRenderUI: TRenderUI;

    // ���� DC
    procedure DoClearDC;
    // ˢ�� DC
    procedure DoRefreshDC;
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
    // ��ʼ�����ھ��
    procedure InitWindowHWND(AHWnd: HWND);
    // ���ñ���ģʽ
    procedure SetBkModeX(ABkMode: Integer);
    // ���û��峤��
    procedure SetSize(AWidth, AHeight: Integer);
    // ���û���ͻ���
    procedure SetClientRect(AClientRect: TRect);
    // ���ڴ� DC ���Ƶ�Ŀ�� DC
    procedure BitBltX(ADC: HDC); overload;
    // ���ڴ� DC ���Ƶ�Ŀ�� DC ��ָ��������(Ҫ��֤ AInvalidateRect �� m_rcBounds ��һ������ϵ��)
    procedure BitBltX(ADC: HDC; AInvalidateRect: TRect); overload;
  end;

implementation

{ TCanvasUI }

constructor TCanvasUI.Create;
begin
  inherited;
  FHWnd := 0;
  FBackDC := 0;
  FBackBitmap := 0;
  FOldBackBitmap := 0;
  FMemDC := 0;
  FMemBitmap := 0;
  FOldMemBitmap := 0;
  FWidth := 0;
  FHeight := 0;
end;

destructor TCanvasUI.Destroy;
begin

  inherited;
end;

procedure TCanvasUI.DoClearDC;
begin
  if FMemDC <> 0 then begin
    SelectObject(FMemDC, FOldMemBitmap);
    DeleteObject(FMemBitmap);
    DeleteDC(FMemDC);
    FMemBitmap := 0;
    FMemDC := 0;
  end;

  if FBackDC <> 0 then begin
    SelectObject(FBackDC, FOldBackBitmap);
    DeleteObject(FBackBitmap);
    DeleteDC(FBackDC);
    FBackBitmap := 0;
    FBackDC := 0;
  end;
end;

procedure TCanvasUI.DoRefreshDC;
var
  LDC: HDC;
begin
  DoClearDC;
  if FHWnd <> 0 then begin
    LDC := GetDC(FHWnd);
    try
      FBackDC := CreateCompatibleDC(LDC);
      // ���� LDC �ı���λͼ
      FBackBitmap := CreateCompatibleBitmap(LDC, FWidth, FHeight);
      // �ѱ���λͼѡ�� �� �������� DC
      FOldBackBitmap := SelectObject(FBackDC, FBackBitmap);
      // ���ñ������� DC ͸��
      SetBkMode(FBackDC, TRANSPARENT);

      // ���� LDC �Ļ������ DC
      FMemDC := CreateCompatibleDC(LDC);
      // ���� LDC �Ļ���λͼ
      FMemBitmap := CreateCompatibleBitmap(LDC, FWidth, FHeight);
      // �ѻ���λͼѡ�� �� ������� DC
      FOldMemBitmap := SelectObject(FMemDC, FMemBitmap);
      // ���û������ DC ͸��
      SetBkMode(FMemDC, TRANSPARENT);

      // ˢ�»滭��Ⱦ����
      FRenderUI.RefreshGraphics(FMemDC);
    finally
      // �ͷ�
      ReleaseDC(FHWnd, LDC);
    end;
  end;
end;

procedure TCanvasUI.InitWindowHWND(AHWnd: HWND);
begin
  FHWnd := AHWnd;
end;

procedure TCanvasUI.SetBkModeX(ABkMode: Integer);
begin
  SetBkMode(FMemDC, ABkMode);
end;

procedure TCanvasUI.SetSize(AWidth, AHeight: Integer);
begin
  if (AWidth <= 0) or (AHeight <= 0) then Exit;


  if (AWidth <> FWidth) or (AHeight <> FHeight) then begin
    FWidth := AWidth;
    FHeight := AHeight;
    FDrawRect := Rect(0, 0, FWidth, FHeight);
    DoRefreshDC;
  end;
end;

procedure TCanvasUI.SetClientRect(AClientRect: TRect);
begin
  FClientRect := AClientRect;
end;

procedure TCanvasUI.BitBltX(ADC: HDC);
begin
  BitBlt(ADC,
    FDrawRect.Left,
    FDrawRect.Top,
    FDrawRect.Width,
    FDrawRect.Height,
    FMemDC,
    0,
    0,
    SRCCOPY);
end;

procedure TCanvasUI.BitBltX(ADC: HDC; AInvalidateRect: TRect);
begin
  BitBlt(ADC,
    AInvalidateRect.Left,
    AInvalidateRect.Top,
    AInvalidateRect.Width,
    AInvalidateRect.Height,
    FMemDC,
    AInvalidateRect.Left - FDrawRect.Left,
    AInvalidateRect.Top - FDrawRect.Top,
    SRCCOPY);
end;

end.
