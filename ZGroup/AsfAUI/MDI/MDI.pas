unit MDI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MDI Form
// Author£º      lksoulman
// Date£º        2017-10-16
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  amMouseWheel,
  Vcl.ExtCtrls,
  AppMenuUI,
  AppContext;

type

  // MDI Form
  TMDIForm = class(TamForm)
    pnlClient: TPanel;
    pnlAppMenu: TPanel;
    pnlSuperTab: TPanel;
    pnlStatusBar: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    // App Menu UI
    FAppMenuUI: TAppMenuUI;
    // Application Context
    FAppContext: IAppContext;
  public
    // Init
    procedure Initialize(AContext: IAppContext);
    // Un Init
    procedure UnInitialize;
  end;

implementation

{$R *.dfm}

procedure TMDIForm.FormCreate(Sender: TObject);
begin
//  FAppMenuUI := TAppMenuUI.Create(nil);
//  FAppMenuUI.Align := alClient;
//  FAppMenuUI.Parent := pnlAppMenu;
//  FAppMenuUI.AppForm := Self;
end;

procedure TMDIForm.FormDestroy(Sender: TObject);
begin
//  FAppMenuUI.Free;
end;

procedure TMDIForm.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
//  FAppMenuUI.Initialize(FAppContext);
end;

procedure TMDIForm.UnInitialize;
begin
//  FAppMenuUI.UnInitialize;
  FAppContext := nil;
end;

procedure TMDIForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//
end;

procedure TMDIForm.FormResize(Sender: TObject);
begin
//
end;

procedure TMDIForm.FormShow(Sender: TObject);
begin
//
end;


end.
