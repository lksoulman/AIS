unit PageControlUI;

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
  ControlUI;

type

  TPageControlUI = class(TControlUI)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
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
