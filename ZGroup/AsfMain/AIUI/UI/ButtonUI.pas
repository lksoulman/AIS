unit ButtonUI;

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

  TButtonUI = class(TControlUI)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
  end;

implementation

{ TButtonUI }

constructor TButtonUI.Create;
begin
  inherited;

end;

destructor TButtonUI.Destroy;
begin

  inherited;
end;

end.
