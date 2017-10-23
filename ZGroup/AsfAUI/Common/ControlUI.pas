unit ControlUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Control UI
// Author£º      lksoulman
// Date£º        2017-10-16
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  ActiveX,
  SysUtils,
  Graphics,
  Controls,
  Messages,
  CommCtrl,
  RenderEngine,
  CommonRefCounter;

type

  // Control UI
  TControlUI = class(TAutoObject)
  private
  protected
    // Tag
    FTag: Integer;
    // parent
    FParent: TObject;
    // Hovered
    FHovered: Boolean;
    // Focused
    FFocused: Boolean;
    // Visible
    FVisible: Boolean;
    // Clip Rgn
    FControlRgn: HRGN;
    // Backgroud Brush
    FBkBrush: HBRUSH;
    // Border Pen
    FBorderPen: HPEN;
    // Control Rect
    FControlRect: TRect;

    // Get Hovered
    function GetHovered: Boolean; virtual;
    // Set Hovered
    procedure SetHovered(AHovered: Boolean); virtual;
    // Get Visible
    function GetVisible: Boolean; virtual;
    // Set Visible
    procedure SetVisible(AVisible: Boolean); virtual;
    // Get Focused
    function GetFocused: Boolean; virtual;
    // Set Focused
    procedure SetFocused(AFocused: Boolean); virtual;
    // Set Control Rect
    procedure SetControlRect(ARect: TRect); virtual;
    // ReCreate Rgn
    procedure ReCreateRgn; virtual;
    // Paint Backgroud
    procedure PaintBk(ADC : HDC; ARenderEngine: TRenderEngine); virtual;
    // Paint Draw
    procedure PaintDraw(ADC : HDC; ARenderEngine: TRenderEngine); virtual;
  public
    // Constructor
    constructor Create(AParent: TObject); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // Set Gdi Value
    procedure SetGdiValue; virtual;
    // Paint
    procedure Paint(ADC: HDC; ARenderEngine: TRenderEngine); virtual;

    // Left Button Down
    function OnLButtonDown(AFlags: UINT; var AMousePt: TPoint): Boolean; virtual;
    // Left Button Up
    function OnLButtonUp(AFlags: UINT; var AMousePt: TPoint): Boolean; virtual;
    // Right Button Down
    function OnRButtonDown(AFlags: UINT; var AMousePt: TPoint): Boolean; virtual;
    // Right Button Up
    function OnRButtonUp(AFlags: UINT; var AMousePt: TPoint): Boolean; virtual;
    // Mouse Move
    function OnMouseMove(AFlags: UINT; var AMousePt: TPoint): Boolean; virtual;
    // Left Button Click
    function OnLButtonClick(AFlags: UINT; var AMousePt: TPoint): Boolean; virtual;
    // Left Button Double Click
    function OnLButtonDblClk(AFlags: UINT; var AMousePt: TPoint): Boolean; virtual;
    // Mouse Wheel
    function OnMouseWheel(AFlags: UINT; AIsDown : Boolean): Boolean; virtual;
    // Key Down
    function OnKeyDown(ACharCode: Word; AKeyData: LongInt): Boolean; virtual;
    // Key Up
    function OnKeyUp(ACharCode: Word; AKeyData: LongInt): Boolean; virtual;

    property Tag: Integer read FTag write FTag;
    property Hovered: Boolean read GetHovered write SetHovered;
    property Visible: Boolean read GetVisible write SetVisible;
    property Focused: Boolean read GetFocused write SetFocused;
    property ControlRect: TRect read FControlRect write SetControlRect;
  end;

  TControlUIClass = class of TControlUI;

implementation

uses
  FrameUI;

{ TControlUI }

constructor TControlUI.Create(AParent: TObject);
begin
  inherited Create;
  FParent := AParent;
  FVisible := True;
  FControlRgn := 0;
  if (FParent <> nil)
    and (FParent is TFrameUI) then begin
    TFrameUI(FParent).AddChildControlUI(Self);
  end;
  SetGdiValue;
end;

destructor TControlUI.Destroy;
begin
  if (FParent <> nil)
    and (FParent is TFrameUI) then begin
    TFrameUI(FParent).DeleteChildControlUI(Self);
  end;
  if FControlRgn <> 0 then begin
    DeleteObject(FControlRgn);
    FControlRgn := 0;
  end;
  inherited;
end;

procedure TControlUI.SetGdiValue;
begin

end;

function TControlUI.GetHovered: Boolean;
begin
  Result := FHovered;
end;

procedure TControlUI.SetHovered(AHovered: Boolean);
begin
  FHovered := AHovered;
end;

function TControlUI.GetVisible: Boolean;
begin
  Result := FVisible;
end;

procedure TControlUI.SetVisible(AVisible: Boolean);
begin
  FVisible := AVisible;
end;

function TControlUI.GetFocused: Boolean;
begin
  Result := FFocused;
end;

procedure TControlUI.SetFocused(AFocused: Boolean);
begin
  FFocused := AFocused;
end;

procedure TControlUI.SetControlRect(ARect: TRect);
begin
  FControlRect := ARect;
  ReCreateRgn;
end;

procedure TControlUI.ReCreateRgn;
begin
  if FControlRgn <> 0 then begin
    DeleteObject(FControlRgn);
  end;
  FControlRgn := CreateRectRgnIndirect(FControlRect);
end;

procedure TControlUI.Paint(ADC: HDC; ARenderEngine: TRenderEngine);
begin
  if FVisible and (FParent <> nil) then begin
    SelectClipRgn(ADC, FControlRgn);
    try
      PaintBk(ADC, ARenderEngine);
      PaintDraw(ADC, ARenderEngine);
    finally
      SelectClipRgn(ADC, 0);
    end;
  end;
end;

procedure TControlUI.PaintBk(ADC : HDC; ARenderEngine: TRenderEngine);
begin
//  SelectObject(ADC, FBorderPen);
//  SelectObject(ADC, FBkBrush);
end;

procedure TControlUI.PaintDraw(ADC : HDC; ARenderEngine: TRenderEngine);
begin

end;

function TControlUI.OnLButtonDown(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin
  Result := False;
end;

function TControlUI.OnLButtonUp(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin
  Result := False;
end;

function TControlUI.OnRButtonDown(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin
  Result := False;
end;

function TControlUI.OnRButtonUp(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin
  Result := False;
end;

function TControlUI.OnMouseMove(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin
  Result := False;
end;

function TControlUI.OnLButtonClick(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin
  Result := False;
end;

function TControlUI.OnLButtonDblClk(AFlags: UINT; var AMousePt: TPoint): Boolean;
begin
  Result := False;
end;

function TControlUI.OnMouseWheel(AFlags: UINT; AIsDown: Boolean): Boolean;
begin
  Result := False;
end;

function TControlUI.OnKeyDown(ACharCode: Word; AKeyData: Integer): Boolean;
begin
  Result := False;
end;

function TControlUI.OnKeyUp(ACharCode: Word; AKeyData: Integer): Boolean;
begin
  Result := False;
end;

end.
