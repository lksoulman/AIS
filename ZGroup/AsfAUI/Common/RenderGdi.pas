unit RenderGdi;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Render Engine
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

  // Render Gdi
  TRenderGdi = class(TAutoObject)
  private
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{ TRenderGdi }

constructor TRenderGdi.Create;
begin
  inherited;

end;

destructor TRenderGdi.Destroy;
begin

  inherited;
end;

end.
