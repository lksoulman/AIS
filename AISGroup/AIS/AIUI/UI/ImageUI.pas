unit ImageUI;

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

  TImageUI = class(TControlUI)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
  end;

implementation

{ TImageUI }

constructor TImageUI.Create;
begin
  inherited;

end;

destructor TImageUI.Destroy;
begin

  inherited;
end;

end.
