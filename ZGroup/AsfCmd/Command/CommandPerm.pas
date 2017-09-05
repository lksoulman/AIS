unit CommandPerm;

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommandImpl,
  CommonRefCounter;

type

  // ����Ȩ��
  TCommandPerm = class(TAutoObject)
  private
    // Ȩ�ޱ��
    FPermNo: Integer;
    // Ȩ������
    FPermMask: Integer;
    // ���� ID
    FCommandID: Integer;
    // ����������
    FCommandClass: TCommandImplClass;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    property PermNo: Integer read FPermNo write FPermNo;
    property PermMask: Integer read FPermMask write FPermMask;
    property CommandID: Integer read FCommandID write FCommandID;
    property CommandClass: TCommandImplClass read FCommandClass write FCommandClass;
  end;

implementation

{ TCommandPerm }

constructor TCommandPerm.Create;
begin
  inherited;

end;

destructor TCommandPerm.Destroy;
begin

  inherited;
end;

end.
