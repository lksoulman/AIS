unit KeyFairy;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-24
// Comments：
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
    // 命令 ID
    FCommandID: Integer;
    // 命令名称
    FCommandName: string;
    // 命令参数
    FCommandParams: string;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
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
