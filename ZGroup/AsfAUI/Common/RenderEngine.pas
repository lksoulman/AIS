unit RenderEngine;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Render Engine
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
  CommonObject,
  CommonRefCounter;

type

  // 字体居中方法
  TRenderTextAlign = (atCenter,     // 居中
                      atLeft,       // 居左
                      atRight       // 居右
                      );

  //
  TRectDynArray = Array of TRect;
  //
  TGPRectDynArray = Array of TGPRect;

  // Render Engine
  TRenderEngine = class(TAutoObject)
  private
    // Memory DC
    FDC: HDC;
    // GDI+
    FGraphics: TGPGraphics;
  protected

    // 赋值矩形数据数据
    procedure DumpRect(ADesRectF: PGPRectF; ASrcRect: PRect);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Refresh Graphics
    procedure RefreshGraphics(ADC: HDC); virtual;
    // Fill Solid Rect X
    procedure FillSolidRectX(ARect: TRect; ABackColor: TColor); virtual;
    // Draw Image X
    procedure DrawImageX(ADesRect, ASrcRect: TRect; AImage: TGPImage); virtual;
    // Draw Image List X
    procedure DrawImageListX(ADesRect, ASrcRect: TRect; AImage: TGPImage); virtual;
    // Draw Rect X
    procedure DrawRectX(ARect: TRect; ABorderWidth: Integer; ABorderColor: TColor); virtual;
    // Draw Rects X
    procedure DrawRectsX(ARects: TRectDynArray; ABorderWidth: Integer; ABorderColor: TColor); virtual;
    // Draw Text X
    procedure DrawTextX(ARect: TRect; AText: string; ATextAlign: TRenderTextAlign; AFontColor: TColor); virtual;
    // Draw Texts X
    procedure DrawTextsX(ARects: TRectDynArray; ATexts: TStringDynArray; ATextAlign: TRenderTextAlign; AFontColor: TColor); virtual;
  end;

implementation

{ TRenderEngine }

constructor TRenderEngine.Create;
begin
  inherited;

end;

destructor TRenderEngine.Destroy;
begin

  inherited;
end;

procedure TRenderEngine.RefreshGraphics(ADC: HDC);
begin
  if FGraphics <> nil then begin
    FGraphics.Free;
  end;
  FDC := ADC;
  FGraphics := TGPGraphics.Create(ADC);
  FGraphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
end;

procedure TRenderEngine.DumpRect(ADesRectF: PGPRectF; ASrcRect: PRect);
begin
  ADesRectF^.X := ASrcRect^.Left;
  ADesRectF^.Y := ASrcRect^.Top;
  ADesRectF^.Width := ASrcRect^.Width;
  ADesRectF^.Height := ASrcRect^.Height;
end;

procedure TRenderEngine.FillSolidRectX(ARect: TRect; ABackColor: TColor);
begin

end;

procedure TRenderEngine.DrawImageX(ADesRect, ASrcRect: TRect; AImage: TGPImage);
var
  LDesRectF, LSrcRectF: TGPRectF;
begin
  DumpRect(@LDesRectF, @ADesRect);
  DumpRect(@LSrcRectF, @ASrcRect);
  FGraphics.DrawImage(AImage, LDesRectF, LSrcRectF.X, LSrcRectF.Y,
    LSrcRectF.Width, LSrcRectF.Height, UnitPixel);
end;

procedure TRenderEngine.DrawImageListX(ADesRect, ASrcRect: TRect; AImage: TGPImage);
var
  LDesRectF, LSrcRectF: TGPRectF;
begin
  DumpRect(@LDesRectF, @ADesRect);
  DumpRect(@LSrcRectF, @ASrcRect);
  FGraphics.DrawImage(AImage, LDesRectF, LSrcRectF.X, LSrcRectF.Y,
    LSrcRectF.Width, LSrcRectF.Height, UnitPixel);
end;

procedure TRenderEngine.DrawRectX(ARect: TRect; ABorderWidth: Integer; ABorderColor: TColor);
var
  LPen: TGPPen;
  LRectF: TGPRectF;
begin
  LPen := TGPPen.Create(ABorderWidth);
  try
    DumpRect(@LRectF, @ARect);
    FGraphics.DrawRectangle(LPen, LRectF);
  finally
    LPen.Free;
  end;
end;

procedure TRenderEngine.DrawRectsX(ARects: TRectDynArray; ABorderWidth: Integer; ABorderColor: TColor);
var
  LPen: TGPPen;
  LRectF: PGPRect;
  LCount, LIndex: Integer;
  LRectFs: TGPRectDynArray;
begin
  LCount := Length(ARects);
  if LCount <= 0 then Exit;

  SetLength(LRectFs, LCount);
  for LIndex := 0 to LCount - 1 do begin
    DumpRect(@LRectFs[LIndex], @ARects[LIndex]);
  end;
  LPen := TGPPen.Create(ABorderWidth);
  try
    LRectF := @LRectFs[0];
    FGraphics.DrawRectangles(LPen, LRectF, LCount);
  finally
    LPen.Free;
  end;
end;

procedure TRenderEngine.DrawTextX(ARect: TRect; AText: string; ATextAlign: TRenderTextAlign; AFontColor: TColor);
//var
//  LFont: TGPFont;
//  LBrush: TGPBrush;
//  LRectF: TGPRectF;
//  LCount: Integer;
//  LString: WideString;
//  LFormat: TGPStringFormat;
begin
//  LFont := TGPFont.Create(FDC);
//  try
//    LFormat := TGPStringFormat.Create();
//    try
//      LBrush := TGPBrush.Create;
//      try
//        LString := AText;
//        DumpRect(@LRectF, @ARect);
//        LCount := Length(LString);
//        FGraphics.DrawString(LString, LCount, LFont, LRectF, LFormat, LBrush);
//      finally
//        LBrush.Free;
//      end;
//    finally
//      LFormat.Free;
//    end;
//  finally
//    LFont.Free;
//  end;
end;

procedure TRenderEngine.DrawTextsX(ARects: TRectDynArray; ATexts: TStringDynArray; ATextAlign: TRenderTextAlign; AFontColor: TColor);
//var
//  LFont: TGPFont;
//  LBrush: TGPBrush;
//  LRectF: TGPRectF;
//  LCount: Integer;
//  LString: WideString;
//  LFormat: TGPStringFormat;
begin
//  LFont := TGPFont.Create(FDC);
//  try
//    LFormat := TGPStringFormat.Create();
//    try
//      LBrush := TGPBrush.Create;
//      try
////        LString := AText;
////        DumpRect(@LRectF, @ARect);
////        LCount := Length(LString);
////        FGraphics.DrawString(LString, LCount, LFont, LRectF, LFormat, LBrush);
//      finally
//        LBrush.Free;
//      end;
//    finally
//      LFormat.Free;
//    end;
//  finally
//    LFont.Free;
//  end;
end;

end.
