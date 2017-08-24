unit Behavior;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // 行为保存对象
  TBehavior = class
  private
    // 行为产生的屏幕
    FScreenID: string;
    // 行为模块ID
    FModuleID: string;
    // 行为产生的时间
    FDateTime: TDateTime;
  protected
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 重置数据
    procedure ResetValue;

    property ScreenID: string read FScreenID write FScreenID;
    property ModuleID: string read FModuleID write FModuleID;
    property DateTime: TDateTime read FDateTime write FDateTime;
  end;


implementation

{ TBehavior }

constructor TBehavior.Create;
begin
  inherited;
  ResetValue;
end;

destructor TBehavior.Destroy;
begin

  inherited;
end;

procedure TBehavior.ResetValue;
begin
  FScreenID := '';
  FModuleID := '';
end;

end.
