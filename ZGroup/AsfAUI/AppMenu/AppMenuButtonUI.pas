unit AppMenuButtonUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� AppMenu Button UI
// Author��      lksoulman
// Date��        2017-10-19
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  RenderEngine,
  ImageButtonUI;

type

  // AppMenu Button UI
  TAppMenuButtonUI = class(TImageButtonUI)
  private
  protected
    // Paint Backgroud
    procedure PaintBk(ADC : HDC; ARenderEngine: TRenderEngine); override;
    // Paint Draw
    procedure PaintDraw(ADC : HDC; ARenderEngine: TRenderEngine); override;
  public
    // Constructor
    constructor Create(AParent: TObject); override;
    // Destructor
    destructor Destroy; override;
    // Left Button Down
    function OnLButtonDown(AFlags: UINT; var AMousePt: TPoint): Boolean; override;
    // Left Button Up
    function OnLButtonUp(AFlags: UINT; var AMousePt: TPoint): Boolean; override;
    // Left Button Click
    function OnLButtonClick(AFlags: UINT; var AMousePt: TPoint): Boolean; override;
  end;

implementation

{ TAppMenuButtonUI }

constructor TAppMenuButtonUI.Create(AParent: TObject);
begin
  inherited;

end;

destructor TAppMenuButtonUI.Destroy;
begin

  inherited;
end;

procedure TAppMenuButtonUI.PaintBk(ADC : HDC; ARenderEngine: TRenderEngine);
begin

end;

procedure TAppMenuButtonUI.PaintDraw(ADC : HDC; ARenderEngine: TRenderEngine);
begin

end;

function TAppMenuButtonUI.OnLButtonDown(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin

end;

function TAppMenuButtonUI.OnLButtonUp(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin

end;

function TAppMenuButtonUI.OnLButtonClick(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin

end;

end.
