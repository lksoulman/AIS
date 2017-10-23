unit ImageButtonUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Image UI
// Author��      lksoulman
// Date��        2017-10-16
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  GDIPOBJ,
  GDIPAPI,
  Windows,
  Classes,
  SysUtils,
  ControlUI,
  RenderEngine;

type

  // Image Button UI
  TImageButtonUI = class(TControlUI)
  private
    //
    FGPImage: TGPImage;
    // Resource Name
    FResourceName: string;
  protected
    // Paint Backgroud
    procedure PaintBk(ADC : HDC; ARenderEngine: TRenderEngine); override;
    // Paint Draw
    procedure PaintDraw(ADC : HDC; ARenderEngine: TRenderEngine); override;
  public

    property ResourceName: string read FResourceName write FResourceName;
  end;

implementation

{ TImageButtonUI }

procedure TImageButtonUI.PaintBk(ADC: HDC; ARenderEngine: TRenderEngine);
begin

end;

procedure TImageButtonUI.PaintDraw(ADC: HDC; ARenderEngine: TRenderEngine);
begin

end;

end.
