unit ComponentUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Component UI
// Author£º      lksoulman
// Date£º        2017-10-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  RenderDC,
  CommonRefCounter;

type

  // Component UI
  TComponentUI = class(TAutoObject)
  private
  protected
    // Id
    FId: Integer;
    //
    FTag: Integer;
    // Rect
    FRectEx: TRect;
    // Caption
    FCaption: string;
    // Visible
    FVisible: Boolean;
    // Resource Name
    FResourceName: string;
    // Resource Stream
    FResourceStream: TResourceStream;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Is valid Rect
    function IsValidRect: Boolean; virtual; abstract;
    // Paint
    procedure Paint(ARenderDC: TRenderDC); virtual; abstract;

    property Id: Integer read FId write FId;
    property Tag: Integer read FTag write FTag;
    property RectEx: TRect read FRectEx write FRectEx;
    property Caption: string read FCaption write FCaption;
    property Visible: Boolean read FVisible write FVisible;
    property ResourceName: string read FResourceName write FResourceName;
    property ResourceStream: TResourceStream read FResourceStream write FResourceStream;
  end;

implementation

{ TComponentUI }

constructor TComponentUI.Create;
begin
  inherited;
  FVisible := True;
end;

destructor TComponentUI.Destroy;
begin
  if FResourceStream <> nil then begin
    FResourceStream.Free;
  end;
  inherited;
end;

end.
