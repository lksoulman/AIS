unit BehaviorItem;

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
  TBehaviorItem = packed record
    FScreenID: string;      // 行为产生的屏幕
    FModuleID: string;      // 行为模块ID
    FDateTime: TDateTime;   // 行为产生的时间
    procedure ResetValue;   // 重置数据
  end;

  // 行为保存对象指针
  PBehaviorItem = ^TBehaviorItem;

implementation

{ TBehaviorItem }

procedure TBehaviorItem.ResetValue;
begin
  FScreenID := '';
  FModuleID := '';
end;

end.
