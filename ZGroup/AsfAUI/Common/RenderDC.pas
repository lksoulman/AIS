unit RenderDC;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Render DC
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
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
  CommonRefCounter;

type

  // Render DC
  TRenderDC = class(TAutoObject)
  private
  protected
    // Memeory DC
    FMemDC: HDC;
    // Memeory DC Bitmap
    FMemBitmap: HBITMAP;
    // Old Memory DC Bitmap
    FOldMemBitmap: HBITMAP;
    // Bound Rect
    FBoundRect: TRect;

    // Clear DC
    procedure DoClearDC;
    // ReCreate DC
    procedure DoReCreateDC(ADC: HDC);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Set Backgroud
    procedure SetBkModeX(ABkMode: Integer);
    // Set Bound
    procedure SetBounds(ADC: HDC; ABoundRect: TRect);
    // Copy Memory DC To ADC
    procedure BitBltX(ADC: HDC); overload;
    // Copy Memory DC's InvalidateRect To ADC's InvalidateRect
    procedure BitBltX(ADC: HDC; AInvalidateRect: TRect); overload;

    property MemDC: HDC read FMemDC;
  end;

implementation

{ TRenderDC }

constructor TRenderDC.Create;
begin
  inherited;
//  FBackDC := 0;
//  FBackBitmap := 0;
//  FOldBackBitmap := 0;
  FMemDC := 0;
  FMemBitmap := 0;
  FOldMemBitmap := 0;
end;

destructor TRenderDC.Destroy;
begin

  inherited;
end;

procedure TRenderDC.DoClearDC;
begin
  if FMemDC <> 0 then begin
    SelectObject(FMemDC, FOldMemBitmap);
    DeleteObject(FMemBitmap);
    DeleteDC(FMemDC);
    FMemBitmap := 0;
    FMemDC := 0;
  end;
end;

procedure TRenderDC.DoReCreateDC(ADC: HDC);
var
  LDC: HDC;
begin
  DoClearDC;
  if ADC <> 0 then begin
    // 创建 LDC 的缓冲兼容 DC
    FMemDC := CreateCompatibleDC(LDC);
    // 创建 LDC 的缓冲位图
    FMemBitmap := CreateCompatibleBitmap(LDC, FBoundRect.Width, FBoundRect.Height);
    // 把缓冲位图选择 到 缓冲兼容 DC
    FOldMemBitmap := SelectObject(FMemDC, FMemBitmap);
    // 设置缓冲兼容 DC 透明
    SetBkMode(FMemDC, TRANSPARENT);
  end;
end;

procedure TRenderDC.SetBkModeX(ABkMode: Integer);
begin
  SetBkMode(FMemDC, ABkMode);
end;

procedure TRenderDC.SetBounds(ADC: HDC; ABoundRect: TRect);
begin
  if (ABoundRect.Left <= ABoundRect.Right)
    or (ABoundRect.Top >= ABoundRect.Bottom) then Exit;

  FBoundRect := Rect(0, 0, ABoundRect.Width, ABoundRect.Height);
  DoReCreateDC(ADC);
end;

procedure TRenderDC.BitBltX(ADC: HDC);
begin
  BitBlt(ADC,
    FBoundRect.Left,
    FBoundRect.Top,
    FBoundRect.Width,
    FBoundRect.Height,
    FMemDC,
    0,
    0,
    SRCCOPY);
end;

procedure TRenderDC.BitBltX(ADC: HDC; AInvalidateRect: TRect);
begin
  BitBlt(ADC,
    AInvalidateRect.Left,
    AInvalidateRect.Top,
    AInvalidateRect.Width,
    AInvalidateRect.Height,
    FMemDC,
    AInvalidateRect.Left - FBoundRect.Left,
    AInvalidateRect.Top - FBoundRect.Top,
    SRCCOPY);
end;

end.
