unit AppMenu;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º App Main Menu UI Interface
// Author£º      lksoulman
// Date£º        2017-10-26
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  GDIPOBJ,
  RenderDC,
  RenderGDI,
  RenderUtil,
  AppContext,
  ComponentUI,
  CommonRefCounter,
  Generics.Collections;

type

  // App Main Menu Hit
  TAppMainMenuHit = class(TAutoObject)
  private
    // Hit Id
    FHitId: Integer;
    // Down Hit Id
    FDownHitId: Integer;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    property HitId: Integer read FHitId write FHitId;
    property DownHitId: Integer read FDownHitId write FDownHitId;
  end;

  // App Main Menu Item UI
  TAppMainMenuItemUI = class(TComponentUI)
  private
    // App Main Menu Hit
    FAppMainMenuHit: TAppMainMenuHit;
    // ResourceStream
    FResourceStream: TResourceStream;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Is valid Rect
    function IsValidRect: Boolean; override;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); override;

    property AppMainMenuHit: TAppMainMenuHit read FAppMainMenuHit write FAppMainMenuHit;
    property ResourceStream: TResourceStream read FResourceStream write FResourceStream;
  end;

  // App Main Menu UI
  IAppMainMenuUI = interface(IInterface)
    ['{8D136CC3-498B-4D72-8714-68561DEA9712}']
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
    // Paint Menu
    procedure PaintMenu(ARenderDC: TRenderDC; AInvalidateRect: TRect);
    // Get App Menu Rect
    function GetAppMenuRect: TRect;
    // Get Forward Rect
    function GetForwardRect: TRect;
    // Get BackSpace Rect
    function GetBackSpaceRect: TRect;
    // Get Menu Item Count
    function GetMenuItemCount: Integer;
    // Get Menu Hit
    function GetMenuHit: TAppMainMenuHit;
    // Get Menu Item
    function GetMenuItem(AIndex: Integer): TAppMainMenuItemUI;
    // Get Menu Item
    function GetMenuItemById(AId: Integer): TAppMainMenuItemUI;
    // Get Id
    function GetIdByMousePt(AMousePt: TPoint; var AId: Integer): Boolean;
  end;

implementation

{ TAppMainMenuHit }

constructor TAppMainMenuHit.Create;
begin
  inherited;
  FHitId := -1;
  FDownHitId := -1;
end;

destructor TAppMainMenuHit.Destroy;
begin

  inherited;
end;

{ TAppMainMenuItemUI }

constructor TAppMainMenuItemUI.Create;
begin
  inherited;
  FRectEx := Rect(0, 0, 0, 0);
end;

destructor TAppMainMenuItemUI.Destroy;
begin
  if FResourceStream <> nil then begin
    FResourceStream.Free;
  end;
  inherited;
end;

function TAppMainMenuItemUI.IsValidRect: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

procedure TAppMainMenuItemUI.Paint(ARenderDC: TRenderDC);
var
  LGPImage: TGPImage;
  LRect, LSrcRect: TRect;
begin
  if FResourceStream = nil then Exit;

  LRect := FRectEx;
  LRect.Left := LRect.Right - 30;
  LGPImage := ResourceStreamToGPImage(FResourceStream);

  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, 30, 30);
  if FAppMainMenuHit <> nil then begin
    if FId = FAppMainMenuHit.FHitId then begin
      OffsetRect(LSrcRect, 30, 0);
      if FId = FAppMainMenuHit.DownHitId then begin
        OffsetRect(LSrcRect, 30, 0);
      end;
    end;
  end;
  DrawImageX(ARenderDC.GPGraphics, LGPImage, LRect, LSrcRect);
  LGPImage.Free;
end;



end.
