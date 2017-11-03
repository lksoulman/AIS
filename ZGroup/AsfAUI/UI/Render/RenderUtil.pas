unit RenderUtil;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Render Utils
// Author：      lksoulman
// Date：        2017-10-26
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  GDIPAPI,
  GDIPOBJ,
  ActiveX,
  SysUtils;


  // Fill Solid Rect
  procedure FillSolidRect(ADC: HDC; APRect: PRECT; AColorRef: COLORREF); overload;

  // Fill Solid Rect
  procedure FillSolidRect(ADC: HDC; AX, AY, ACX, ACY: Integer; AColorRef: COLORREF); overload;

  // Draw Border
  procedure DrawBorder(ADC: HDC; ABorderPen : HGDIOBJ; const ARect: TRect; ABorderType: integer);

  // ResourceStream To GPImage
  function ResourceStreamToGPImage(AResStream: TResourceStream): TGPImage;
  // Draw Image X
  procedure DrawImageX(AGraphics: TGPGraphics; AImage: TGPImage; ADesRect, ASrcRect: TRect);
  // Draw Text Ex X
  procedure DrawTextExX(ADC: HDC; AGraphics: TGPGraphics; AText: string; ARect: TRect; AFont: HFONT; ABKColor: COLORREF; AHorzAlignment, AVertAlignment: TStringAlignment);

implementation


  procedure FillSolidRect(ADC: HDC; APRect: PRECT; AColorRef: COLORREF);
  begin
    SetBkColor(ADC, AColorRef);
    ExtTextOut(ADC, 0, 0, ETO_OPAQUE, APRect, nil, 0, nil);
  end;

  procedure FillSolidRect(ADC: HDC; AX, AY, ACX, ACY: Integer; AColorRef: COLORREF);
  var
    LRect: TRect;
  begin
    LRect.Left := AX;
    LRect.Top := AY;
    LRect.Right := AX + ACX;
    LRect.Bottom := AY + ACY;

    SetBkColor(ADC, AColorRef);
    ExtTextOut(ADC, 0, 0, ETO_OPAQUE, @LRect, nil, 0, nil);
  end;

  procedure DrawBorder(ADC: HDC; ABorderPen : HGDIOBJ; const ARect: TRect; ABorderType: integer);
  begin
    if ABorderType = 0 then Exit;

    SelectObject(ADC, ABorderPen);
    //绘制左边框
    if (ABorderType and 1) > 0 then begin
      MoveToEx(ADC, ARect.Left, ARect.Top, nil);
      //bottom加一是为了把结束点像素也画上
      LineTo(ADC, ARect.Left, ARect.Bottom + 1);
    end;

    //绘制右边框
    if (ABorderType and 2) > 0 then begin
      MoveToEx(ADC, ARect.Right, ARect.Top, nil);
      LineTo(ADC, ARect.Right, ARect.Bottom + 1);
    end;

    //绘制上边框
    if (ABorderType and 4) > 0 then begin
      MoveToEx(ADC, ARect.Left, ARect.Top, nil);
      LineTo(ADC, ARect.Right + 1, ARect.Top);
    end;

    //绘制下边框
    if (ABorderType and 8) > 0 then begin
      MoveToEx(ADC, ARect.Left, ARect.Bottom, nil);
      LineTo(ADC, ARect.Right + 1, ARect.Bottom);
    end;
  end;

  procedure DumpRect(ADesRectF: PGPRectF; ASrcRect: PRect);
  begin
    ADesRectF^.X := ASrcRect^.Left;
    ADesRectF^.Y := ASrcRect^.Top;
    ADesRectF^.Width := ASrcRect^.Width;
    ADesRectF^.Height := ASrcRect^.Height;
  end;

  function ResourceStreamToGPImage(AResStream: TResourceStream): TGPImage;
  var
    LStream: IStream;
  begin
    Result := nil;
    if AResStream = nil then Exit;
    LStream := TStreamAdapter.Create(AResStream);
    Result := TGPImage.Create(LStream);
  end;

  procedure DrawImageX(AGraphics: TGPGraphics; AImage: TGPImage; ADesRect, ASrcRect: TRect);
  var
    LDesRectF, LSrcRectF: TGPRectF;
  begin
    DumpRect(@LDesRectF, @ADesRect);
    DumpRect(@LSrcRectF, @ASrcRect);
    AGraphics.DrawImage(AImage, LDesRectF, LSrcRectF.X, LSrcRectF.Y,
      LSrcRectF.Width, LSrcRectF.Height, UnitPixel);
  end;

  procedure DrawTextExX(ADC: HDC; AGraphics: TGPGraphics; AText: string; ARect: TRect; AFont: HFONT; ABKColor: TGPColor;
    AHorzAlignment, AVertAlignment: TStringAlignment);
  var

    LFont: TGPFont;
    LRectF: TGPRectF;
    LBrush: TGPBrush;
    LFormat: TGPStringFormat;
  begin
    LRectF := MakeRect(ARect.Left + 0.0, ARect.Top + 0.0, ARect.Width + 0.0, ARect.Height + 0.0);
//    LFont := TGPFont.Create(ADC, AFont);
    LFont := TGPFont.Create('微软雅黑', 10, FontStyleBold);
    try
//    sb := TGPSolidBrush.Create(aclRed);



      LBrush := TGPSolidBrush.Create(aclRed);      //ABKColor
      try
        LFormat := TGPStringFormat.Create;
        try
          LFormat.SetAlignment(AHorzAlignment);
          LFormat.SetLineAlignment(AVertAlignment);
          AGraphics.DrawString(AText, -1, LFont, LRectF, LFormat, LBrush);
        finally
          LFormat.Free;
        end;
      finally
        LBrush.Free;
      end;
    finally
      LFont.Free;
    end;
  end;


end.
