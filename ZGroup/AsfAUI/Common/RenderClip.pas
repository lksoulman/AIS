unit RenderClip;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Render Clip
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
