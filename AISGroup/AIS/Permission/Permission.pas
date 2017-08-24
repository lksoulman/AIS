unit Permission;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-17
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  TPermission = class
  private
    // Ȩ�ޱ��
    FPermNo: Integer;
    // �����ļ�����
    FPermName: string;
    // Ȩ�޽���ʱ��
    FEndDate: TDateTime;
    // Ȩ�޿�ʼʱ��
    FStartDate: TDateTime;
  protected
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;

    property PermNo: Integer read FPermNo write FPermNo;
    property PermName: string read FPermName write FPermName;
    property EndDate: TDateTime read FEndDate write FEndDate;
    property StartDate: TDateTime read FStartDate write FStartDate;
  end;

implementation

{ TPermission }

constructor TPermission.Create;
begin
  inherited;

end;

destructor TPermission.Destroy;
begin

  inherited;
end;

end.
