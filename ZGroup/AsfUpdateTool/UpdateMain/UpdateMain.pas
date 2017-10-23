unit UpdateMain;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Main Form
// Author£º      lksoulman
// Date£º        2017-8-4
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
  Update, Vcl.StdCtrls;

type

  // Update Main Form
  TUpdateMainForm = class(TForm)
    BtnGenerateUpdateList: TButton;
    BtnBackup: TButton;
    BtnCompress: TButton;
    BtnUncompress: TButton;
    BtnGenerateNeedUpdateList: TButton;
    BtnUpgrade: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnGenerateUpdateListClick(Sender: TObject);
    procedure BtnBackupClick(Sender: TObject);
    procedure BtnCompressClick(Sender: TObject);
    procedure BtnUncompressClick(Sender: TObject);
    procedure BtnGenerateNeedUpdateListClick(Sender: TObject);
    procedure BtnUpgradeClick(Sender: TObject);
  private
    // Update
    FUpdate: IUpdate;
  public

  end;

var
  UpdateMainForm: TUpdateMainForm;

implementation

uses
  UpdateImpl;

{$R *.dfm}

procedure TUpdateMainForm.FormCreate(Sender: TObject);
begin
  FUpdate := TUpdateImpl.Create as IUpdate;
  FUpdate.SetHandle(self.Handle);
end;

procedure TUpdateMainForm.FormDestroy(Sender: TObject);
begin
  FUpdate := nil;
end;

procedure TUpdateMainForm.BtnBackupClick(Sender: TObject);
begin
  FUpdate.Backup;
end;

procedure TUpdateMainForm.BtnCompressClick(Sender: TObject);
begin
  FUpdate.CompressServerUpdateList;
end;

procedure TUpdateMainForm.BtnGenerateNeedUpdateListClick(Sender: TObject);
begin
  FUpdate.GenerateNeedUpdateList;
end;

procedure TUpdateMainForm.BtnGenerateUpdateListClick(Sender: TObject);
begin
  FUpdate.GenerateServerUpdateList;
end;

procedure TUpdateMainForm.BtnUncompressClick(Sender: TObject);
begin
  FUpdate.UncompresServerUpdateList;
end;

procedure TUpdateMainForm.BtnUpgradeClick(Sender: TObject);
begin
//  FUpdate.
end;

end.


