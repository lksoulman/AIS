unit Behavior;

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
  TBehavior = class
  private
    // ��Ϊ��������Ļ
    FScreenID: string;
    // ��Ϊģ��ID
    FModuleID: string;
    // ��Ϊ������ʱ��
    FDateTime: TDateTime;
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ��������
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
