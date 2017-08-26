unit RenderUI;

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
  CommonObject,
  CommonRefCounter;

type

  // ������з���
  TRenderTextAlign = (atCenter,     // ����
                      atLeft,       // ����
                      atRight       // ����
                      );

  TRectDynArray = Array of TRect;
  TGPRectDynArray = Array of TGPRect;

  // �滭��Ⱦ����
  TRenderUI = class(TAutoObject)
  private
    // �ڴ� DC
    FMemDC: HDC;
    // GDI+ ͼ��
    FGraphics: TGPGraphics;
  protected

    // ��ֵ������������
    procedure DumpRect(ADesRectF: PGPRectF; ASrcRect: PRect);
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
    // ˢ��ͼ��
    procedure RefreshGraphics(AMemDC: HDC); virtual;
    // ���ʵ�ĵľ���
    procedure FillSolidRectX(ARect: TRect; ABackColor: TColor); virtual;
    // ��ͼƬ
    procedure DrawImageX(ADesRect, ASrcRect: TRect; AImage: TGPImage); virtual;
    // ������ͼƬ��ֳɶ���б�
    procedure DrawImageListX(ADesRect, ASrcRect: TRect; AImage: TGPImage); virtual;
    // ������
    procedure DrawRectX(ARect: TRect; ABorderWidth: Integer; ABorderColor: TColor); virtual;
    // ������
    procedure DrawRectsX(ARects: TRectDynArray; ABorderWidth: Integer; ABorderColor: TColor); virtual;
    // ������
    procedure DrawTextX(ARect: TRect; AText: string; ATextAlign: TRenderTextAlign; AFontColor: TColor); virtual;
    // ������
    procedure DrawTextsX(ARects: TRectDynArray; ATexts: TStringDynArray; ATextAlign: TRenderTextAlign; AFontColor: TColor); virtual;
  end;

implementation

{ TRenderUI }

constructor TRenderUI.Create;
begin
  inherited;

end;

destructor TRenderUI.Destroy;
begin

  inherited;
end;

procedure TRenderUI.RefreshGraphics(AMemDC: HDC);
begin
  if FGraphics <> nil then begin
    FGraphics.Free;
  end;
  FMemDC := AMemDC;
  FGraphics := TGPGraphics.Create(AMemDC);
  FGraphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
end;

procedure TRenderUI.DumpRect(ADesRectF: PGPRectF; ASrcRect: PRect);
begin
  ADesRectF^.X := ASrcRect^.Left;
  ADesRectF^.Y := ASrcRect^.Top;
  ADesRectF^.Width := ASrcRect^.Width;
  ADesRectF^.Height := ASrcRect^.Height;
end;

procedure TRenderUI.FillSolidRectX(ARect: TRect; ABackColor: TColor);
begin

end;

procedure TRenderUI.DrawImageX(ADesRect, ASrcRect: TRect; AImage: TGPImage);
var
  LDesRectF, LSrcRectF: TGPRectF;
begin
  DumpRect(@LDesRectF, @ADesRect);
  DumpRect(@LSrcRectF, @ASrcRect);
  FGraphics.DrawImage(AImage, LDesRectF, LSrcRectF.X, LSrcRectF.Y,
    LSrcRectF.Width, LSrcRectF.Height, UnitPixel);
end;

procedure TRenderUI.DrawImageListX(ADesRect, ASrcRect: TRect; AImage: TGPImage);
var
  LDesRectF, LSrcRectF: TGPRectF;
begin
  DumpRect(@LDesRectF, @ADesRect);
  DumpRect(@LSrcRectF, @ASrcRect);
  FGraphics.DrawImage(AImage, LDesRectF, LSrcRectF.X, LSrcRectF.Y,
    LSrcRectF.Width, LSrcRectF.Height, UnitPixel);
end;

procedure TRenderUI.DrawRectX(ARect: TRect; ABorderWidth: Integer; ABorderColor: TColor);
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

procedure TRenderUI.DrawRectsX(ARects: TRectDynArray; ABorderWidth: Integer; ABorderColor: TColor);
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

procedure TRenderUI.DrawTextX(ARect: TRect; AText: string; ATextAlign: TRenderTextAlign; AFontColor: TColor);
var
  LFont: TGPFont;
  LBrush: TGPBrush;
  LRectF: TGPRectF;
  LCount: Integer;
  LString: WideString;
  LFormat: TGPStringFormat;
begin
  LFont := TGPFont.Create(FMemDC);
  try
    LFormat := TGPStringFormat.Create();
    try
      LBrush := TGPBrush.Create;
      try
        LString := AText;
        DumpRect(@LRectF, @ARect);
        LCount := Length(LString);
        FGraphics.DrawString(LString, LCount, LFont, LRectF, LFormat, LBrush);
      finally
        LBrush.Free;
      end;
    finally
      LFormat.Free;
    end;
  finally
    LFont.Free;
  end;
end;

procedure TRenderUI.DrawTextsX(ARects: TRectDynArray; ATexts: TStringDynArray; ATextAlign: TRenderTextAlign; AFontColor: TColor);
var
  LFont: TGPFont;
  LBrush: TGPBrush;
  LRectF: TGPRectF;
  LCount: Integer;
  LString: WideString;
  LFormat: TGPStringFormat;
begin
  LFont := TGPFont.Create(FMemDC);
  try
    LFormat := TGPStringFormat.Create();
    try
      LBrush := TGPBrush.Create;
      try
//        LString := AText;
//        DumpRect(@LRectF, @ARect);
//        LCount := Length(LString);
//        FGraphics.DrawString(LString, LCount, LFont, LRectF, LFormat, LBrush);
      finally
        LBrush.Free;
      end;
    finally
      LFormat.Free;
    end;
  finally
    LFont.Free;
  end;
end;

end.
