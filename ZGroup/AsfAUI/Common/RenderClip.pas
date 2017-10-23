unit RenderClip;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Render Clip
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
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

  // Render Clip
  TRenderClip = class(TAutoObject)
  private
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{ TRenderClip }

constructor TRenderClip.Create;
begin
  inherited;

end;

destructor TRenderClip.Destroy;
begin

  inherited;
end;

end.
