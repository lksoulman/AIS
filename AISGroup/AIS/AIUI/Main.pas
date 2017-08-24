unit Main;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-14
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  AppContext,
  PlugInMgr;

type
  TfrmMain = class(TForm)
    // 窗口创建
    procedure FormCreate(Sender: TObject);
    // 窗口释放
    procedure FormDestroy(Sender: TObject);
  private
    // 当屏幕激活窗口改变的时候
    procedure ActiveFormChange(Sender: TObject);
  protected
    // 插件管理对象
    FPlugInMgr: TPlugInMgr;
    // 应用程序上下文接口
    FAppContext: IAppContext;


    // 初始化事件
    procedure InitEvent;
    // 初始化配置文件
    procedure InitConfig;
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  AppContextImpl;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FPlugInMgr := TPlugInMgr.Create;
  FAppContext := TAppContextImpl.Create as IAppContext;
  FPlugInMgr.Initialize(FAppContext);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FPlugInMgr.UnInitialize;
  FAppContext := nil;
  FPlugInMgr.Free;
end;

procedure TfrmMain.ActiveFormChange(Sender: TObject);
begin

end;

procedure TfrmMain.InitEvent;
begin
  Screen.OnActiveFormChange := ActiveFormChange;
end;

procedure TfrmMain.InitConfig;
begin


end;

end.
