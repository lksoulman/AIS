unit ComponentUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Component UI
// Author：      lksoulman
// Date：        2017-10-16
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  CanvasUI,
  ControlUI,
  CommonLock,
  CommonRefCounter,
  Generics.Collections;

type

  TComponentUI = class(TAutoObject)
  private
  protected
    // FLock
    FLock: TCSLock;
    // Caption
    FCaption: string;
    // Component Rect
    FComponentRect: TRect;

    procedure PaintMemBkg(DC: HDC; ACompRect, AInvalidateRect: TRect); virtual;
    procedure PaintBkg(DC: HDC; ACompRect: TRect); virtual;
    procedure PaintFg(DC: HDC; ACompRect, AInvalidateRect: TRect); virtual;
    procedure PaintControls;
  public
    // Constructor
    constructor Create; virtual;
    // Destructor
    destructor Destroy; override;
    // 设置GDI值
    procedure SetGdiValue(AIsStyleChanged: Boolean = False); virtual;
    // 重新绘制组件
    procedure Repaint(AInvalidate: Boolean = True); virtual;
    //
    procedure Paint(DC: HDC; AInvalidateRect: TRect); virtual;
    // Invalidate
    procedure Invalidate; virtual;
  public
  end;

implementation

end.
