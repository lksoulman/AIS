unit AppMainFormUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Form UI
// Author：      lksoulman
// Date：        2017-10-16
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Variants,
  Graphics,
  Controls,
  Dialogs,
  Vcl.Forms,
  Vcl.ExtCtrls,
  GDIPOBJ,
  RenderGDI,
  RenderUtil,
  AppMenuUI,
  AppStatus,
  AppContext,
  BaseFormUI,
  AppStatusUI,
  AppSuperTabUI;

type

  // Click App Menu
  TOnClickAppItem = procedure (AMainForm: TObject; AItem: TObject) of object;

  // App Main Form UI
  TAppMainFormUI = class(TBaseFormUI)
    PnlAppSuperTab: TPanel;
    PnlClient: TPanel;
  private
    // App Status
    FAppStatus: IAppStatus;
    // App Menu UI
    FAppMenuUI: TAppMenuUI;
    // App Status UI
    FAppStatusUI: TAppStatusUI;
    // App Super Tab UI
    FAppSuperTabUI: TAppSuperTabUI;
    // Click App Menu
    FOnClickAppMenu: TOnClickAppItem;
    //
    FOnClickAppSuperTab: TOnClickAppItem;

    // Application Context
    FAppContext: IAppContext;
  protected
    // Click Status Item
    procedure DoClickStatusItem(AObject: TObject);
    // Click Super Tab Item
    procedure DoClickSuperTabItem(AObject: TObject);

    // Paint Caption App Icon
    procedure PaintCaptionAppIcon(ADC: HDC; AInvalidateRect: TRect); override;
    // Paint Caption App Menu
    procedure PaintCaptionAppMenu(ADC: HDC; AInvalidateRect: TRect); override;
    // App Menu Hit Test
    function NCAppMenuHitTest(var Msg: TMessage; ANCRect: TRect): Boolean; override;
    // Update Hit test
    procedure UpdateHitTest(AHitTest: Integer; AHitMenu: Integer = -1); override;

    // NC Left Button Up
    procedure WMNCLButtonUp(var Message: TWMNCLButtonUp); message WM_NCLBUTTONUP;
    // NC Left Button Down
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
  public
    // Constructor
    constructor Create(AStatus: IAppStatus); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;

    property OnClickAppMenu: TOnClickAppItem read FOnClickAppMenu write FOnClickAppMenu;
    property OnClickAppSuperTab: TOnClickAppItem read FOnClickAppSuperTab write FOnClickAppSuperTab;
  end;

implementation

{$R *.dfm}

{ TAppMainFormUI }

constructor TAppMainFormUI.Create(AStatus: IAppStatus);
begin
  inherited Create(nil);
  FAppStatus := AStatus;
  FIsAppMainForm := True;
  FAppMenuUI := TAppMenuUI.Create;

  FAppStatusUI := TAppStatusUI.Create(FAppStatus);
  FAppStatusUI.Align := alBottom;
  FAppStatusUI.Parent := PnlClient;
  FAppStatusUI.Height := 30;
  FAppStatusUI.OnClickItem := DoClickStatusItem;

  FAppSuperTabUI := TAppSuperTabUI.Create(nil);
  FAppSuperTabUI.Align := alClient;
  FAppSuperTabUI.Parent := PnlAppSuperTab;
  FAppSuperTabUI.Width := 60;
  FAppSuperTabUI.OnClickItem := DoClickSuperTabItem;
end;

destructor TAppMainFormUI.Destroy;
begin
  FAppStatusUI.Free;
  FAppSuperTabUI.Free;
  FAppMenuUI.Free;
  FAppStatus := nil;
  inherited;
end;

procedure TAppMainFormUI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FAppMenuUI.Initialize(AContext);
  FAppSuperTabUI.Initialize(AContext);
  FAppStatusUI.Initialize(AContext);
end;

procedure TAppMainFormUI.UnInitialize;
begin
  FAppStatusUI.UnInitialize;
  FAppSuperTabUI.UnInitialize;
  FAppMenuUI.UnInitialize;
  FAppContext := nil;
end;

procedure TAppMainFormUI.DoClickStatusItem(AObject: TObject);
begin
  if Assigned(FOnClickAppMenu) then begin
    FOnClickAppMenu(Self, AObject);
  end;
end;

procedure TAppMainFormUI.DoClickSuperTabItem(AObject: TObject);
begin
  if Assigned(FOnClickAppSuperTab) then begin
    FOnClickAppSuperTab(Self, AObject);
  end;
end;

procedure TAppMainFormUI.PaintCaptionAppIcon(ADC: HDC; AInvalidateRect: TRect);
var
  LGPImage: TGPImage;
  LSrcRect, LDesRect: TRect;
begin
  if APPIMG_CAPTION_LOGO = nil then Exit;

  LGPImage := ResourceStreamToGPImage(APPIMG_CAPTION_LOGO);
  if LGPImage = nil then Exit;

  LSrcRect := Rect(0, 0, LGPImage.GetWidth, LGPImage.GetHeight);
  LDesRect := AInvalidateRect;
  LDesRect.Inflate(-6, -5);
  DrawImageX(FNCRenderDC.GPGraphics, LGPImage, LDesRect, LSrcRect);
  LGPImage.Free;
end;

procedure TAppMainFormUI.PaintCaptionAppMenu(ADC: HDC; AInvalidateRect: TRect);
begin
  if FAppMenuUI = nil then Exit;

  FAppMenuUI.PaintMenu(FNCRenderDC, AInvalidateRect);
end;

procedure TAppMainFormUI.UpdateHitTest(AHitTest: Integer; AHitMenu: Integer = -1);
begin
  if FAppMenuUI <> nil then begin
    if (FHitTest <> AHitTest)
      or (FAppMenuUI.HitId <> AHitMenu) then begin
      FHitTest := AHitTest;
      FAppMenuUI.HitId := AHitMenu;
      if FAppMenuUI.DownHitId <> AHitMenu then begin
        FAppMenuUI.DownHitId := -1;
      end;
      SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
    end;
  end else begin
    inherited;
  end;
end;

function TAppMainFormUI.NCAppMenuHitTest(var Msg: TMessage; ANCRect: TRect): Boolean;
var
  LId: Integer;
  LMousePt: TPoint;
  LAppMenuItem: TAppMenuItem;
begin
  Result := False;
  if FAppMenuUI = nil then Exit;

  LMousePt.X := SmallInt(Msg.LParamLo);
  LMousePt.Y := SmallInt(Msg.LParamHi);
  if FAppMenuUI.GetMenuItemByPt(ANCRect, LMousePt, LAppMenuItem) then begin
    Result := True;
    Msg.Result := HTMENU;
    UpdateHitTest(Msg.Result, LAppMenuItem.Id);
  end;
end;

procedure TAppMainFormUI.WMNCLButtonDown(var Message: TWMNCLButtonDown);
begin
  // 保存按下时鼠标位置
  FMouseLeavePt.X := Message.XCursor;
  FMouseLeavePt.Y := Message.YCursor;
  // 保存按下是鼠标的点击位置类型
  FDownHitTest := Message.HitTest;
  if FAppMenuUI <> nil then begin
    FAppMenuUI.DownHitId := FAppMenuUI.HitId;
  end;
  SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
  // 点击激活
  if not Self.IsActivate then begin
    PostMessage(Self.Handle, WM_ACTIVATE, 1, 0);
  end;
  // 调用inherited会导致 WMNCLButtonUp 不响应,所以屏蔽一些，但窗体大小拖动还需要 Inherited
  if (Message.HitTest <> HTCAPTION)
    and (Message.HitTest <> HTCLOSE)
    and (Message.HitTest <> HTMENU)
    and (Message.HitTest <> HTMAXBUTTON)
    and (Message.HitTest <> HTMINBUTTON)
    and (WindowState <> wsMaximized) then begin
    inherited;
  end;
end;

//非客户去左键抬起消息响应
procedure TAppMainFormUI.WMNCLButtonUp(var Message: TWMNCLButtonUp);
var
  LAppMenuItem: TAppMenuItem;
begin
  // 如果抬起时和按下时位置一致
  if Message.HitTest = FDownHitTest then begin
    case Message.HitTest of
      HTMENU:
        begin
          if FAppMenuUI <> nil then begin
            if FAppMenuUI.HitId = FAppMenuUI.DownHitId then begin
              LAppMenuItem := FAppMenuUI.GetMenuItemById(FAppMenuUI.HitId);
              if Assigned(FOnClickAppMenu) then begin
                FOnClickAppMenu(Self, LAppMenuItem);
              end;
            end;
            FAppMenuUI.DownHitId := -1;
            SendMessage(Self.Handle, WM_NCPAINT, 0, 0);
          end;
        end;
      HTCLOSE:
        Self.Close;
      HTMAXBUTTON:
        begin
          FHitTest := HTNOWHERE;
          if Self.WindowState = wsNormal then begin
            Self.WindowState := wsMaximized
          end else begin
            self.WindowState := wsNormal;
          end;
        end;
      HTMINBUTTON:
        Self.WindowState := wsMinimized;
    end;
  end;
  FDownHitTest := HTNOWHERE;
  inherited;
end;

end.
