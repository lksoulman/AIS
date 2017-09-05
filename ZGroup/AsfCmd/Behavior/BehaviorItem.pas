unit BehaviorItem;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // ��Ϊ�������
  TBehaviorItem = packed record
    FScreenID: string;      // ��Ϊ��������Ļ
    FModuleID: string;      // ��Ϊģ��ID
    FDateTime: TDateTime;   // ��Ϊ������ʱ��
    procedure ResetValue;   // ��������
  end;

  // ��Ϊ�������ָ��
  PBehaviorItem = ^TBehaviorItem;

implementation

{ TBehaviorItem }

procedure TBehaviorItem.ResetValue;
begin
  FScreenID := '';
  FModuleID := '';
end;

end.
