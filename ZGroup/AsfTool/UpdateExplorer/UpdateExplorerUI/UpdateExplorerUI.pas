unit UpdateExplorerUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Explorer UI Interface Implementation
// Author£º      lksoulman
// Date£º        2017-10-12
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
  Vcl.StdCtrls;

type

  // Update Explorer UI Interface Implementation
  TUpdateExplorerUI = class(TForm)
    btnUpdateGenerate: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
  end;

implementation

//uses
//  UpdateImpl;

{$R *.dfm}

procedure TUpdateExplorerUI.FormCreate(Sender: TObject);
begin
//  FUpdate := TUpdateImpl.Create as IUpdate;
end;

procedure TUpdateExplorerUI.FormDestroy(Sender: TObject);
begin
//  FUpdate := nil;
end;

end.
