unit Main;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Main Form
// Author：      lksoulman
// Date：        2017-8-14
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Forms,
  Dialogs,
  Windows,
  Classes,
  SysUtils,
  Messages,
  Variants,
  Graphics,
  Controls,
  AppContext, Vcl.StdCtrls;

type

  //
  TfrmMain = class(TForm)
    BtnServiceExplorer: TButton;
    BtnProAuth: TButton;
    BtnHqAuth: TButton;
    BtnBaseCache: TButton;
    BtnSecuMain: TButton;
    BtnUpdate: TButton;
    BtnMainFrameUI: TButton;
    // Form Create
    procedure FormCreate(Sender: TObject);
    // Form Destroy
    procedure FormDestroy(Sender: TObject);
    procedure BtnServiceExplorerClick(Sender: TObject);
    procedure BtnProAuthClick(Sender: TObject);
    procedure BtnHqAuthClick(Sender: TObject);
    procedure BtnBaseCacheClick(Sender: TObject);
    procedure BtnSecuMainClick(Sender: TObject);
    procedure BtnUpdateClick(Sender: TObject);
    procedure BtnMainFrameUIClick(Sender: TObject);
  private
    // Active Form Change
    procedure ActiveFormChange(Sender: TObject);
  protected
    // Application Context
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
  ServiceType,
  PlugInConst,
  AppContextImpl;

{$R *.dfm}

procedure TfrmMain.BtnHqAuthClick(Sender: TObject);
begin
  FAppContext.CreatePlugInById(PLUGIN_ID_HQAUTH);
end;

procedure TfrmMain.BtnMainFrameUIClick(Sender: TObject);
begin
  FAppContext.CreatePlugInById(PLUGIN_ID_MAINFRAMEUI);
end;

procedure TfrmMain.BtnProAuthClick(Sender: TObject);
begin
  FAppContext.CreatePlugInById(PLUGIN_ID_PROAUTH);
end;

procedure TfrmMain.BtnBaseCacheClick(Sender: TObject);
begin
  FAppContext.CreatePlugInById(PLUGIN_ID_BASECACHE);
end;

procedure TfrmMain.BtnSecuMainClick(Sender: TObject);
begin
  FAppContext.CreatePlugInById(PLUGIN_ID_SECUMAIN);
end;

procedure TfrmMain.BtnServiceExplorerClick(Sender: TObject);
begin
  if (FAppContext.GetLogin <> nil)
    and FAppContext.GetLogin.IsLoginService(stAll) then begin
    FAppContext.CreatePlugInById(LIB_PLUGIN_ID_SERVICEEXPLORER);
  end;
end;

procedure TfrmMain.BtnUpdateClick(Sender: TObject);
begin
  FAppContext.CreatePlugInById(LIB_PLUGIN_ID_UPDATEEXPLORER);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FAppContext := TAppContextImpl.Create as IAppContext;
  FAppContext.Initialize;
  FAppContext.CreatePlugInById(LIB_PLUGIN_ID_BASICSERVICE);
  FAppContext.CreatePlugInById(LIB_PLUGIN_ID_ASSETSERVICE);
  FAppContext.CreatePlugInById(LIB_PLUGIN_ID_LOGIN);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FAppContext.UnInitialize;
  FAppContext := nil;
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
