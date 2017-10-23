unit ContainerPanelUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Container Panel UI
// Author£º      lksoulman
// Date£º        2017-10-16
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Messages,
  ControlUI,
  CommonLock,
  RenderDC,
  RenderClip,
  RenderEngine,
  CommonRefCounter,
  Generics.Collections;

type

  // Container Panel UI
  TContainerPanelUI = class(TAutoObject)
  private
  protected
    // Caption
    FCaption: string;
    // Container Rect
    FContainerRect: TRect;
    // ControlUI Class
    FControlUIClass: TControlUIClass;


    // Set Container Rect
    procedure SetContainerRect(ARect: TRect); virtual;
    // Paint Controls
    procedure PaintControls; virtual;
    // Paint Backgroud
    procedure PaintBg(ADC: HDC; ACompRect: TRect); virtual;
    // Paint Front groud
    procedure PaintFg(ADC: HDC; ACompRect, AInvalidateRect: TRect); virtual;
    // Paint Memory Backgroud
    procedure PaintMemBg(ADC: HDC; ACompRect, AInvalidateRect: TRect); virtual;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Create Control
    procedure CreateControls; virtual;
    // Calc Control Rect
    procedure CalcControlRect; virtual;
    // Paint
    procedure Paint(ADC: HDC; AInvalidateRect: TRect); virtual;
    // Add Child Control UI
    procedure AddChildControlUI(AControlUI: TControlUI); virtual;
    // Del Child Control UI
    procedure DeleteChildControlUI(AControlUI: TControlUI); virtual;
    // Left Button Down
    procedure WMLButtonDown(var Message: TWMLButtonDown); virtual;
    // Left Button Up
    procedure WMLButtonUp(var Message: TWMLButtonUp); virtual;
    // Left Button Double Click
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); virtual;
    // Right Button Down
    procedure WMRButtonDown(var Message: TWMRButtonDown); virtual;
    // Right Button Up
    procedure WMRButtonUp(var Message: TWMRButtonUp); virtual;
    // Mouse Move
    procedure WMMouseMove(var Message: TWMMouseMove); virtual;
    // Mouse Wheel
    procedure WMMouseWheel(var Message: TWMMouseWheel); virtual;
    // Key Down
    procedure WMKeyDown(var Message: TWMKeyDown); virtual;
    // Key Up
    procedure WMKeyUp(var Message: TWMKeyUp); virtual;

    property ContainerRect: TRect read FContainerRect write SetContainerRect;
  end;

  TContainerPanelUIClass = class of TContainerPanelUI;

implementation

{ TContainerPanelUI }

constructor TContainerPanelUI.Create;
begin
  inherited;
  FLock := TCSLock.Create;
  FControlUIs := TList<TControlUI>.Create;
end;

destructor TContainerPanelUI.Destroy;
begin
  FControlUIs.Free;
  FLock.Free;
  inherited;
end;

procedure TContainerPanelUI.CreateControls;
begin

end;

procedure TContainerPanelUI.CalcControlRect;
begin

end;

procedure TContainerPanelUI.SetContainerRect(ARect: TRect);
begin
  FContainerRect := ARect;
end;

procedure TContainerPanelUI.Paint(ADC: HDC; AInvalidateRect: TRect);
begin
//  PaintMemBg(ADC, LCompRect, LInvalidateRect);
//  PaintFg(ADC, LCompRect, LInvalidateRect);
end;

procedure TContainerPanelUI.AddChildControlUI(AControlUI: TControlUI);
begin
  if AControlUI = nil then Exit;

  FLock.Lock;
  try
    FControlUIs.Add(AControlUI);
  finally
    FLock.UnLock;
  end;
end;

procedure TContainerPanelUI.DeleteChildControlUI(AControlUI: TControlUI);
begin
  FLock.Lock;
  try
    FControlUIs.Remove(AControlUI);
  finally
    FLock.UnLock;
  end;
end;

procedure TContainerPanelUI.PaintControls;
var
  LIndex: Integer;
  LControlUI: TControlUI;
begin
  FLock.Lock;
  try
    for LIndex := 0 to FControlUIs.Count - 1 do begin
      LControlUI := FControlUIs.Items[LIndex];
//      LControlUI.Paint();
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TContainerPanelUI.PaintBg(ADC: HDC; ACompRect: TRect);
begin

end;

procedure TContainerPanelUI.PaintFg(ADC: HDC; ACompRect, AInvalidateRect: TRect);
begin

end;

procedure TContainerPanelUI.PaintMemBg(ADC: HDC; ACompRect, AInvalidateRect: TRect);
begin

end;

procedure TContainerPanelUI.WMLButtonDown(var Message: TWMLButtonDown);
begin

end;

procedure TContainerPanelUI.WMLButtonUp(var Message: TWMLButtonUp);
begin

end;

procedure TContainerPanelUI.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin

end;

procedure TContainerPanelUI.WMRButtonDown(var Message: TWMRButtonDown);
begin

end;

procedure TContainerPanelUI.WMRButtonUp(var Message: TWMRButtonUp);
begin

end;

procedure TContainerPanelUI.WMMouseMove(var Message: TWMMouseMove);
begin

end;

procedure TContainerPanelUI.WMMouseWheel(var Message: TWMMouseWheel);
begin

end;

procedure TContainerPanelUI.WMKeyDown(var Message: TWMKeyDown);
begin

end;

procedure TContainerPanelUI.WMKeyUp(var Message: TWMKeyUp);
begin

end;

end.
