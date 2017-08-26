unit KeyFairy;

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
  CommonRefCounter;

type

  TKeyFairy = class(TAutoObject)
  private
    // ���� ID
    FCommandID: Integer;
    // ��������
    FCommandName: string;
    // �������
    FCommandParams: string;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    property CommandID: Integer read FCommandID write FCommandID;
    property CommandName: string read FCommandName write FCommandName;
    property CommandParams: string read FCommandParams write FCommandParams;
  end;

implementation

{ TKeyFairy }

constructor TKeyFairy.Create;
begin
  inherited;

end;

destructor TKeyFairy.Destroy;
begin

  inherited;
end;

end.
