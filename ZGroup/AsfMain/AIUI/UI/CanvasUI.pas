unit CanvasUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
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
  RenderUI,
  CommonRefCounter;

type

  // 画板
  TCanvasUI = class(TAutoObject)
  private
  protected
    // 窗口句柄
    FHWnd: HWND;
    // 背景 DC
    FBackDC: HDC;
    // 背景 DC 的兼容位图
    FBackBitmap: HBITMAP;
    // 背景 DC 上次的位图
    FOldBackBitmap: HBITMAP;
    // 内存 DC
    FMemDC: HDC;
    // 内存 DC 的兼容位图
    FMemBitmap: HBITMAP;
    // 内存 DC 上次的位图
    FOldMemBitmap: HBITMAP;
    // 画布宽
    FWidth: Integer;
    // 画布高
    FHeight: Integer;
    // 画板整个区域
    FDrawRect: TRect;
    // 画板客户区域
    FClientRect: TRect;
    // 绘画渲染工具
    FRenderUI: TRenderUI;

    // 清理 DC
    procedure DoClearDC;
    // 刷新 DC
    procedure DoRefreshDC;
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;
    // 初始化窗口句柄
    procedure InitWindowHWND(AHWnd: HWND);
    // 设置背景模式
    procedure SetBkModeX(ABkMode: Integer);
    // 设置画板长宽
    procedure SetSize(AWidth, AHeight: Integer);
    // 设置画板客户区
    procedure SetClientRect(AClientRect: TRect);
    // 将内存 DC 绘制到目标 DC
    procedure BitBltX(ADC: HDC); overload;
    // 将内存 DC 绘制到目标 DC 的指定区域上(要保证 AInvalidateRect 和 m_rcBounds 在一个坐标系上)
    procedure BitBltX(ADC: HDC; AInvalidateRect: TRect); overload;
  end;

implementation

{ TCanvasUI }

constructor TCanvasUI.Create;
begin
  inherited;
  FHWnd := 0;
  FBackDC := 0;
  FBackBitmap := 0;
  FOldBackBitmap := 0;
  FMemDC := 0;
  FMemBitmap := 0;
  FOldMemBitmap := 0;
  FWidth := 0;
  FHeight := 0;
end;

destructor TCanvasUI.Destroy;
begin

  inherited;
end;

procedure TCanvasUI.DoClearDC;
begin
  if FMemDC <> 0 then begin
    SelectObject(FMemDC, FOldMemBitmap);
    DeleteObject(FMemBitmap);
    DeleteDC(FMemDC);
    FMemBitmap := 0;
    FMemDC := 0;
  end;

  if FBackDC <> 0 then begin
    SelectObject(FBackDC, FOldBackBitmap);
    DeleteObject(FBackBitmap);
    DeleteDC(FBackDC);
    FBackBitmap := 0;
    FBackDC := 0;
  end;
end;

procedure TCanvasUI.DoRefreshDC;
var
  LDC: HDC;
begin
  DoClearDC;
  if FHWnd <> 0 then begin
    LDC := GetDC(FHWnd);
    try
      FBackDC := CreateCompatibleDC(LDC);
      // 创建 LDC 的背景位图
      FBackBitmap := CreateCompatibleBitmap(LDC, FWidth, FHeight);
      // 把背景位图选择 到 背景兼容 DC
      FOldBackBitmap := SelectObject(FBackDC, FBackBitmap);
      // 设置背景兼容 DC 透明
      SetBkMode(FBackDC, TRANSPARENT);

      // 创建 LDC 的缓冲兼容 DC
      FMemDC := CreateCompatibleDC(LDC);
      // 创建 LDC 的缓冲位图
      FMemBitmap := CreateCompatibleBitmap(LDC, FWidth, FHeight);
      // 把缓冲位图选择 到 缓冲兼容 DC
      FOldMemBitmap := SelectObject(FMemDC, FMemBitmap);
      // 设置缓冲兼容 DC 透明
      SetBkMode(FMemDC, TRANSPARENT);

      // 刷新绘画渲染工具
      FRenderUI.RefreshGraphics(FMemDC);
    finally
      // 释放
      ReleaseDC(FHWnd, LDC);
    end;
  end;
end;

procedure TCanvasUI.InitWindowHWND(AHWnd: HWND);
begin
  FHWnd := AHWnd;
end;

procedure TCanvasUI.SetBkModeX(ABkMode: Integer);
begin
  SetBkMode(FMemDC, ABkMode);
end;

procedure TCanvasUI.SetSize(AWidth, AHeight: Integer);
begin
  if (AWidth <= 0) or (AHeight <= 0) then Exit;


  if (AWidth <> FWidth) or (AHeight <> FHeight) then begin
    FWidth := AWidth;
    FHeight := AHeight;
    FDrawRect := Rect(0, 0, FWidth, FHeight);
    DoRefreshDC;
  end;
end;

procedure TCanvasUI.SetClientRect(AClientRect: TRect);
begin
  FClientRect := AClientRect;
end;

procedure TCanvasUI.BitBltX(ADC: HDC);
begin
  BitBlt(ADC,
    FDrawRect.Left,
    FDrawRect.Top,
    FDrawRect.Width,
    FDrawRect.Height,
    FMemDC,
    0,
    0,
    SRCCOPY);
end;

procedure TCanvasUI.BitBltX(ADC: HDC; AInvalidateRect: TRect);
begin
  BitBlt(ADC,
    AInvalidateRect.Left,
    AInvalidateRect.Top,
    AInvalidateRect.Width,
    AInvalidateRect.Height,
    FMemDC,
    AInvalidateRect.Left - FDrawRect.Left,
    AInvalidateRect.Top - FDrawRect.Top,
    SRCCOPY);
end;

end.
