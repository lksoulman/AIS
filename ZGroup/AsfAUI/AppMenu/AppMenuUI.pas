unit AppMenuUI;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms,
  FrameUI,
  ControlUI,
  AppContext,
  AppMenuButtonUI,
  Generics.Collections;

const
  APP_BUTTON_CLOSE       = -1;  // Close
  APP_BUTTON_RESTORE     = -2;  // Restore
  APP_BUTTON_MAXIMIZE    = -3;  // Maximize
  APP_BUTTON_MINIMIZE    = -4;  // Minimize
  APP_BUTTON_SKIN        = -5;  // SKIN

  SKIN_APP_SKIN          = 'SKIN_APP_SKIN';
  SKIN_APP_CLOSE         = 'SKIN_APP_CLOSE';
  SKIN_APP_RESTORE       = 'SKIN_APP_RESTORE';
  SKIN_APP_MAXIMIZE      = 'SKIN_APP_MAXIMIZE';
  SKIN_APP_MINIMIZE      = 'SKIN_APP_MINIMIZE';

type

  // App Menu UI
  TAppMenuUI = class(TFrameUI)
  private
    // App Form
    FAppForm: TForm;
    // Button
    FButtonUIs: TList<TControlUI>;

    procedure SetAppForm(AForm: TForm);
  protected
    // Add Control UI
    procedure AddControlUIs; virtual;
    // Delete Control UI
    procedure DelControlUIs; virtual;
    // Calc Control Rect
    procedure CalcControlUIRect; virtual;
  public
    // Constructor
    constructor Create(AOwner: TComponent); override;
    // Destructor
    destructor Destroy; override;

    property AppForm: TForm read FAppForm write SetAppForm;
  end;

implementation

{ TAppMenuUI }

constructor TAppMenuUI.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TAppMenuUI.Destroy;
begin

  inherited;
end;

procedure TAppMenuUI.AddControlUIs;
var
  LAppMenuButtonUI: TAppMenuButtonUI;
begin
  FButtonUIs := TList<TControlUI>.Create;

  LAppMenuButtonUI := TAppMenuButtonUI.Create(Self);
  LAppMenuButtonUI.Tag := APP_BUTTON_CLOSE;
  LAppMenuButtonUI.ResourceName := SKIN_APP_CLOSE;
  FButtonUIs.Add(LAppMenuButtonUI);

  LAppMenuButtonUI := TAppMenuButtonUI.Create(Self);
  LAppMenuButtonUI.Tag := APP_BUTTON_RESTORE;
  LAppMenuButtonUI.ResourceName := SKIN_APP_RESTORE;
  FButtonUIs.Add(LAppMenuButtonUI);

  LAppMenuButtonUI := TAppMenuButtonUI.Create(Self);
  LAppMenuButtonUI.Tag := APP_BUTTON_MAXIMIZE;
  LAppMenuButtonUI.ResourceName := SKIN_APP_MAXIMIZE;
  FButtonUIs.Add(LAppMenuButtonUI);

  LAppMenuButtonUI := TAppMenuButtonUI.Create(Self);
  LAppMenuButtonUI.Tag := APP_BUTTON_MINIMIZE;
  LAppMenuButtonUI.ResourceName := SKIN_APP_MINIMIZE;
  FButtonUIs.Add(LAppMenuButtonUI);
end;

procedure TAppMenuUI.DelControlUIs;
var
  LIndex: Integer;
  LAppMenuButtonUI: TAppMenuButtonUI;
begin
  for LIndex := 0 to FButtonUIs.Count - 1 do begin
    LAppMenuButtonUI := TAppMenuButtonUI(FButtonUIs.Items[LIndex]);
    if LAppMenuButtonUI <> nil then begin
      LAppMenuButtonUI.Free;
    end;
  end;
  FButtonUIs.Free;
end;

procedure TAppMenuUI.CalcControlUIRect;
var
  LIndex: Integer;
  LControlUI: TControlUI;
begin
  for LIndex := 0 to FControlUIs.Count - 1 do begin
    LControlUI := FControlUIs.Items[LIndex];
    if (LControlUI <> nil)
      and (LControlUI.Visible) then begin
      LControlUI.Paint(FRenderDC.MemDC, FMemRenderEngine);
    end;
  end;
end;

procedure TAppMenuUI.SetAppForm(AForm: TForm);
begin
  FAppForm := AForm;
end;

end.
