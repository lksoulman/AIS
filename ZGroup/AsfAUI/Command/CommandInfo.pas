unit CommandInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Command Info
// Author��      lksoulman
// Date��        2017-10-18
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

  // Command Info
  TCommandInfo = class(TAutoObject)
  private
    // Command Id
    FCommandId: Integer;
    // Command Params
    FCommandParams: string;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    property CommandId: Integer read FCommandId write FCommandId;
    property CommandParams: string read FCommandParams write FCommandParams;
  end;

implementation

{ TCommandInfo }

constructor TCommandInfo.Create;
begin
  inherited;
  FCommandId := 0;
end;

destructor TCommandInfo.Destroy;
begin

  inherited;
end;

end.
