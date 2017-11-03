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
    // Graphics
    FGPGraphics: TGPGraphics;
    // Bound Rect
    FBoundsRect: TGPRect;
    // Memory Bitmap Rect
    FMemBitmapRect: TGPRect;

    function GetIsInit: Boolean;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Set DC
    procedure SetDC(ADC: HDC);
    // Set Background
    procedure SetBkModeX(ABkMode: Integer);
    // Set Bound
    procedure SetBounds(ADC: HDC; ABoundsRect: TRect);
    // Copy Memory DC To ADC
    procedure BitBltX(ADC: HDC); overload;
    // Copy Memory DC's InvalidateRect To ADC's InvalidateRect
    procedure BitBltX(ADC: HDC; AInvalidateRect: TRect); overload;

    property MemDC: HDC read FMemDC;
    property IsInit: Boolean read GetIsInit;
    property GPGraphics: TGPGraphics read FGPGraphics;
  end;

implementation

{ TRenderDC }

constructor TRenderDC.Create;
begin
  inherited;
  FMemDC := 0;
  FMemBitmap := 0;
  FOldMemBitmap := 0;
end;

destructor TRenderDC.Destroy;
begin
  if FGPGraphics <> nil then begin
    FGPGraphics.Free;
    FGPGraphics := nil;
  end;
  if FMemBitmap <> 0 then begin
    DeleteObject(FMemBitmap);
    FMemBitmap := 0;
  end;
  if FMemDC <> 0 then begin
    if FOldMemBitmap <> 0 then begin
      SelectObject(FMemDC, FOldMemBitmap);
      FOldMemBitmap := 0;
    end;
    DeleteDC(FMemDC);
    FMemDC := 0;
  end;
  inherited;
end;

function TRenderDC.GetIsInit: Boolean;
begin
  Result := (FMemDC <> 0);
end;

procedure TRenderDC.SetDC(ADC: HDC);
begin
  FMemDC := CreateCompatibleDC(ADC);
end;

procedure TRenderDC.SetBkModeX(ABkMode: Integer);
begin
  SetBkMode(FMemDC, ABkMode);
end;

procedure TRenderDC.SetBounds(ADC: HDC; ABoundsRect: TRect);
var
  LDC: HDC;
begin
  // 检查区域是否为空
  if (ABoundsRect.Width = 0)
    or (ABoundsRect.Height =0) then Exit;

  //如果已有区域大于新区域，则不重新创建
//  if (FMemBitmapRect.Width >= ABoundsRect.Width)
//    and (FMemBitmapRect.Height  >= ABoundsRect.Height) then
//  begin
//    FBoundsRect := ABoundsRect;
//    Exit;
//  end;

  if FGPGraphics <> nil then begin
    FGPGraphics.Free;
    FGPGraphics := nil;
  end;

  if FMemBitmap <> 0 then begin
    DeleteObject(FMemBitmap);
    FMemBitmap := 0;
  end;

  if FMemDC <> 0 then begin
    if FOldMemBitmap <> 0 then begin
      SelectObject(FMemDC, FOldMemBitmap);
      FOldMemBitmap := 0;
    end;
  end;

  FBoundsRect := MakeRect(ABoundsRect);
  FMemBitmapRect := MakeRect(0, 0, ABoundsRect.Width, ABoundsRect.Height);

  // 创建 LDC 的缓冲位图
  FMemBitmap := CreateCompatibleBitmap(ADC, FMemBitmapRect.Width, FMemBitmapRect.Height);
  FOldMemBitmap := SelectObject(FMemDC, FMemBitmap);

  FGPGraphics := TGPGraphics.Create(FMemDC);
  FGPGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
end;

procedure TRenderDC.BitBltX(ADC: HDC);
begin
  BitBlt(ADC,
    FBoundsRect.X,
    FBoundsRect.Y,
    FBoundsRect.Width,
    FBoundsRect.Height,
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
    AInvalidateRect.Left - FBoundsRect.X,
    AInvalidateRect.Top - FBoundsRect.Y,
    SRCCOPY);
end;

end.
