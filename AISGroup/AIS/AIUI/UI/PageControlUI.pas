unit PageControlUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-24
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  ControlUI;

type

  TPageControlUI = class(TControlUI)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
  end;

implementation

{ TPageControlUI }

constructor TPageControlUI.Create;
begin
  inherited;

end;

destructor TPageControlUI.Destroy;
begin

  inherited;
end;

end.
