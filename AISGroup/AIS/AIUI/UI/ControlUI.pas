unit ControlUI;

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
  ActiveX,
  SysUtils,
  Controls,
  Messages,
  CommCtrl,
  CommonRefCounter;


type

  TControlUI = class(TAutoObject)
  protected
    // 控件区域
    FRect: TRect;
    // 控件的顶部
    FTop: Integer;
    // 控价的左部
    FLeft: Integer;
    // 控件的宽度
    FWidth: Integer;
    // 控件的宽度
    FHeight: Integer;
    // 控件 ID
    FCombID: Integer;
    // 控件 Caption
    FCaption: string;
    // 是不是选中
    FChecked: Boolean;
    // 是不是鼠标悬停
    FHovered: Boolean;
    // 是不是按下
    FPressed: Boolean;
    // 控件是否可用
    FDisable: Boolean;
    // 控价是否显示
    FVisible: Boolean;
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
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
