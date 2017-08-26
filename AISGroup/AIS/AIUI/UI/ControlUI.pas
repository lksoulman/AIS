unit ControlUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-24
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  ActiveX,
  SysUtils,
  Controls,
  Messages,
  CommCtrl,
  CommonRefCounter;


type

  TControlUI = class(TAutoObject)
  protected
    // �ؼ�����
    FRect: TRect;
    // �ؼ��Ķ���
    FTop: Integer;
    // �ؼ۵���
    FLeft: Integer;
    // �ؼ��Ŀ��
    FWidth: Integer;
    // �ؼ��Ŀ��
    FHeight: Integer;
    // �ؼ� ID
    FCombID: Integer;
    // �ؼ� Caption
    FCaption: string;
    // �ǲ���ѡ��
    FChecked: Boolean;
    // �ǲ��������ͣ
    FHovered: Boolean;
    // �ǲ��ǰ���
    FPressed: Boolean;
    // �ؼ��Ƿ����
    FDisable: Boolean;
    // �ؼ��Ƿ���ʾ
    FVisible: Boolean;
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    property Rect: TRect read FRect write FRect;
    property Top: Integer read FTop write FTop;
    property Left: Integer read FLeft write FLeft;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property CombID: Integer read FCombID write FCombID;
    property Caption: string read FCaption write FCaption;
    property Checked: Boolean read FChecked write FChecked;
    property Hovered: Boolean read FHovered write FHovered;
    property Pressed: Boolean read FPressed write FPressed;
    property Disable: Boolean read FDisable write FDisable;
  end;

  TControlUIDynArray = array of TControlUI;


implementation

{ TControlUI }

constructor TControlUI.Create;
begin
  FTop := 0;
  FLeft := 0;
  FWidth := 0;
  FHeight := 0;
  FCombID := 0;
  FCaption := '';
  FChecked := False;
  FHovered := False;
  FPressed := False;
  FDisable := False;
  FVisible := True;
end;

destructor TControlUI.Destroy;
begin

  inherited;
end;


end.
