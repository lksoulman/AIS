unit RenderGDI;

  ////////////////////////////////////////////////////////////////////////////////
//
// Description： Render Engine
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  GDIPOBJ,
  GDIPAPI,
  SysUtils,
  Graphics,
  ImgList,
  vcl.Imaging.pngimage,
  AppContext,
  CommonObject,
  CommonRefCounter,
  Generics.Collections;

type

  // Render GDI
  TRenderGDI = class(TAutoObject)
  private
    // Is Init
    FIsInit: Boolean;
    //
    FAppContext: IAppContext;
    // Pen
    FPenDic: TDictionary<string, HGDIOBJ>;
    // Font
    FFontDic: TDictionary<string, HGDIOBJ>;
    // Brush
    FBrushDic: TDictionary<string, HGDIOBJ>;
    // Color
    FColorDic: TDictionary<string, COLORREF>;
  protected
    // Init Pen
    procedure InitPen;
    // Un Init Pen
    procedure UnInitPen;
    // Init Font
    procedure InitFont;
    // Un Init Font
    procedure UnInitFont;
    // Init Color
    procedure InitColor;
    // Un Init Color
    procedure UnInitColor;
    // Init Brush
    procedure InitBrush;
    // Un Init Brush
    procedure UnInitBrush;
    // Init Image
    procedure InitImage;
    // UnInit Image
    procedure UnInitImage;
    // Load Image
    procedure LoadImage;
    // Get Font
    function GetFont(const AName: string): HFONT;
    // Get Pen
    function GetPen(const AName: string): HGDIOBJ;
    // Get Brush
    function GetBrush(const AName: string): HGDIOBJ;
    //Get Color
    function GetColor(const AName: string): COLORREF;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;

    property Pen[const AName: string]: HGDIOBJ read GetPen;
    property Font[const AName: string]: HFONT read GetFont;
    property Brush[const AName: string]: HGDIOBJ read GetBrush;
    property Color[const AName: string]: COLORREF read GetColor;
  end;

var
  // ColorRef
  APPC_MAINFORM_CAPTION_BACK: COLORREF;
  APPC_MAINFORM_SUPERTAB_BACK: COLORREF;
  APPC_MAINFORM_STATUSBAR_BACK: COLORREF;
  APPC_MAINFORM_BORDER: COLORREF;

  APPC_HQ_RED: COLORREF;
  APPC_HQ_GREEN: COLORREF;
  APPC_STATUS_TEXT: COLORREF;

var
  APPF_STATUS_TEXT: HGDIOBJ;

var
  APPP_MAINFORM_BORDER: HGDIOBJ;

var
  // Image
  APPIMG_CAPTION_SYSCLOSE: TResourceStream;   // System Close
  APPIMG_CAPTION_SYSMAX: TResourceStream;     // System Max
  APPIMG_CAPTION_SYSRES: TResourceStream;     // System Normal
  APPIMG_CAPTION_SYSMIN: TResourceStream;     // System Min

  APPIMG_CAPTION_LOGO: TResourceStream;       // Application Icon


implementation

uses
  ActiveX;

{ TRenderGDI }

constructor TRenderGDI.Create;
begin
  inherited;
  FIsInit := False;
  FPenDic := TDictionary<string, HGDIOBJ>.Create(200);
  FFontDic := TDictionary<string, HGDIOBJ>.Create(200);
  FBrushDic := TDictionary<string, HGDIOBJ>.Create(200);
  FColorDic := TDictionary<string, COLORREF>.Create(200);
  InitFont;
  InitColor;
  InitPen;
  InitBrush;
end;

destructor TRenderGDI.Destroy;
begin
  UnInitPen;
  UnInitFont;
  UnInitColor;
  UnInitBrush;
  UnInitImage;
  FColorDic.Free;
  FBrushDic.Free;
  FFontDic.Free;
  FPenDic.Free;
  inherited;
end;

procedure TRenderGDI.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  LoadImage;
end;

procedure TRenderGDI.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TRenderGDI.InitPen;
begin
  APPP_MAINFORM_BORDER := CreatePen(PS_SOLID, 1, APPC_MAINFORM_BORDER);
end;

procedure TRenderGDI.UnInitPen;
begin

end;

procedure TRenderGDI.InitFont;
var
  LFont: HGDIOBJ;
  LLogFont: LOGFONT;
begin
  //创建字体
  ZeroMemory(@LLogFont, Sizeof(LOGFONT));
  LFont := GetStockObject(DEFAULT_GUI_FONT);
  GetObject(LFont, SizeOf(LOGFONT), @LLogFont);
  LLogFont.lfCharSet := DEFAULT_CHARSET;
  lstrcpy(LLogFont.lfFaceName , PChar('微软雅黑'));
  LLogFont.lfHeight := 18;
  LLogFont.lfWeight := FW_BOLD;
  LLogFont.lfItalic := Byte(False);
  LLogFont.lfUnderline := Byte(False);
  APPF_STATUS_TEXT := CreateFontIndirect(LLogFont);

//  lstrcpy(LLogFont.lfFaceName , PChar('宋体'));
//  LLogFont.lfHeight := 14;
//  LLogFont.lfWeight := FW_NORMAL;
//  LLogFont.lfItalic := Byte(False);
//  LLogFont.lfUnderline := Byte(False);
//  APPF_MENU_TEXT := CreateFontIndirect(LLogFont);
//  lstrcpy(LLogFont.lfFaceName , PChar('宋体'));
//  LLogFont.lfHeight := 12;
//  LLogFont.lfWeight := FW_NORMAL;
//  LLogFont.lfItalic := Byte(False);
//  LLogFont.lfUnderline := Byte(False);
//  APPF_BUTTON_TEXT := CreateFontIndirect(LLogFont);
//  lstrcpy(LLogFont.lfFaceName , PChar('宋体'));
//  LLogFont.lfHeight := 12;
//  LLogFont.lfWeight := FW_BOLD;
//  LLogFont.lfItalic := Byte(False);
//  LLogFont.lfUnderline := Byte(False);
//  APPF_MAINMENU_GRID_TEXT := CreateFontIndirect(LLogFont);
//
//  FFontDic.Add('CAPTION_TEXT', APPF_CAPTION_TEXT);
//  FFontDic.Add('MENU_TEXT', APPF_MENU_TEXT);
//  FFontDic.Add('BUTTON_TEXT', APPF_BUTTON_TEXT);
//  FFontDic.Add('MAINMENU_GRID_TEXT', APPF_MAINMENU_GRID_TEXT);
end;

procedure TRenderGDI.UnInitFont;
begin

end;

procedure TRenderGDI.InitColor;
begin
  APPC_MAINFORM_CAPTION_BACK := RGB(35, 35, 35);
  APPC_MAINFORM_SUPERTAB_BACK := RGB(35, 35, 35);
  APPC_MAINFORM_STATUSBAR_BACK := RGB(35, 35, 35);
  APPC_MAINFORM_BORDER := RGB(24, 131, 215);
  APPC_STATUS_TEXT := RGB(200, 200, 200);
end;

procedure TRenderGDI.UnInitColor;
begin

end;

procedure TRenderGDI.InitBrush;
begin

end;

procedure TRenderGDI.UnInitBrush;
begin

end;

procedure TRenderGDI.InitImage;
begin

end;

procedure TRenderGDI.UnInitImage;
begin
  if APPIMG_CAPTION_SYSCLOSE <> nil then begin
    APPIMG_CAPTION_SYSCLOSE.Free;
    APPIMG_CAPTION_SYSCLOSE := nil;
  end;

  if APPIMG_CAPTION_SYSMAX <> nil then begin
    APPIMG_CAPTION_SYSMAX.Free;
    APPIMG_CAPTION_SYSMAX := nil;
  end;

  if APPIMG_CAPTION_SYSRES <> nil then begin
    APPIMG_CAPTION_SYSRES.Free;
    APPIMG_CAPTION_SYSRES := nil;
  end;

  if APPIMG_CAPTION_SYSMIN <> nil then begin
    APPIMG_CAPTION_SYSMIN.Free;
    APPIMG_CAPTION_SYSMIN := nil;
  end;

  if APPIMG_CAPTION_LOGO <> nil then begin
    APPIMG_CAPTION_LOGO.Free;
    APPIMG_CAPTION_LOGO := nil;
  end;
end;

procedure TRenderGDI.LoadImage;
var
  LStream: IStream;
  LResStream: TResourceStream;
begin
  if FAppContext = nil then Exit;

  LResStream := FAppContext.GetResourceSkin.GetStream('SKIN_APP_CLOSE');
  if LResStream <> nil then begin
    if APPIMG_CAPTION_SYSCLOSE= nil then begin
      APPIMG_CAPTION_SYSCLOSE := LResStream;
    end else begin
      APPIMG_CAPTION_SYSCLOSE.Position := 0;
      APPIMG_CAPTION_SYSCLOSE.CopyFrom(LResStream, LResStream.Size);
    end;
  end;

  LResStream := FAppContext.GetResourceSkin.GetStream('SKIN_APP_MAXIMIZE');
  if LResStream <> nil then begin
    if APPIMG_CAPTION_SYSMAX= nil then begin
      APPIMG_CAPTION_SYSMAX := LResStream;
    end else begin
      APPIMG_CAPTION_SYSMAX.Position := 0;
      APPIMG_CAPTION_SYSMAX.CopyFrom(LResStream, LResStream.Size);
    end;
  end;

  LResStream := FAppContext.GetResourceSkin.GetStream('SKIN_APP_RESTORE');
  if LResStream <> nil then begin
    if APPIMG_CAPTION_SYSRES= nil then begin
      APPIMG_CAPTION_SYSRES := LResStream;
    end else begin
      APPIMG_CAPTION_SYSRES.Position := 0;
      APPIMG_CAPTION_SYSRES.CopyFrom(LResStream, LResStream.Size);
    end;
  end;

  LResStream := FAppContext.GetResourceSkin.GetStream('SKIN_APP_MINIMIZE');
  if LResStream <> nil then begin
    if APPIMG_CAPTION_SYSMIN= nil then begin
      APPIMG_CAPTION_SYSMIN := LResStream;
    end else begin
      APPIMG_CAPTION_SYSMIN.Position := 0;
      APPIMG_CAPTION_SYSMIN.CopyFrom(LResStream, LResStream.Size);
    end;
  end;

  LResStream := FAppContext.GetResourceSkin.GetStream('SKIN_APP_LOGO');
  if LResStream <> nil then begin
    if APPIMG_CAPTION_LOGO= nil then begin
      APPIMG_CAPTION_LOGO := LResStream;
    end else begin
      APPIMG_CAPTION_LOGO.Position := 0;
      APPIMG_CAPTION_LOGO.CopyFrom(LResStream, LResStream.Size);
    end;
  end;
end;

function TRenderGDI.GetFont(const AName: string): HFONT;
begin
  if not FFontDic.TryGetValue(UpperCase(AName), HGDIOBJ(Result)) then begin
    Result := 0;
  end;
end;

function TRenderGDI.GetPen(const AName: string): HGDIOBJ;
begin
  if not FPenDic.TryGetValue(UpperCase(AName), Result) then begin
    Result := 0;
  end;
end;

function TRenderGDI.GetBrush(const AName: string): HGDIOBJ;
begin
  if not FBrushDic.TryGetValue(UpperCase(AName), Result) then begin
    Result := 0;
  end;
end;

function TRenderGDI.GetColor(const AName: string): COLORREF;
begin
  if FColorDic.TryGetValue(UpperCase(AName), Result) then begin
    Result := 0;
  end;
end;




end.
