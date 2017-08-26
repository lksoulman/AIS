unit PanelUI;

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

  TPanelUI = class(TControlUI)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;
  end;

implementation

{ TPanelUI }

constructor TPanelUI.Create;
begin
  inherited;

end;

destructor TPanelUI.Destroy;
begin

  inherited;
end;

end.
