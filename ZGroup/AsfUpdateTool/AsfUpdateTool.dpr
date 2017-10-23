program AsfUpdateTool;

uses
  Vcl.Forms,
  Update in 'Update\Update.pas',
  UpdateAppContext in 'Update\UpdateAppContext.pas',
  UpdateAppContextImpl in 'Update\UpdateAppContextImpl.pas',
  UpdateBackup in 'Update\UpdateBackup.pas',
  UpdateCheck in 'Update\UpdateCheck.pas',
  UpdateDownloadFile in 'Update\UpdateDownloadFile.pas',
  UpdateGenerate in 'Update\UpdateGenerate.pas',
  UpdateInfo in 'Update\UpdateInfo.pas',
  UpdateInfoPool in 'Update\UpdateInfoPool.pas',
  UpdateLog in 'Update\UpdateLog.pas',
  UpdateReadWrite in 'Update\UpdateReadWrite.pas',
  UpdateImpl in 'Update\Impl\UpdateImpl.pas',
  UpdateMain in 'UpdateMain\UpdateMain.pas' {UpdateMainForm},
  UpdateCompress in 'Update\UpdateCompress.pas',
  UpdateUncompress in 'Update\UpdateUncompress.pas',
  UpdateUpgradeFile in 'Update\UpdateUpgradeFile.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TUpdateMainForm, UpdateMainForm);
  Application.Run;
end.
