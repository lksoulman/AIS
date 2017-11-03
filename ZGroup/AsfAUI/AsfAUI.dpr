library AsfAUI;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  Forms,
  Windows,
  WExport in 'WExport\WExport.pas',
  FactoryAsfAUIImpl in 'WExport\Impl\FactoryAsfAUIImpl.pas',
  MDIChild in 'MDIChild\MDIChild.pas' {MDIChildForm},
  MainFrameUI in 'MainFrameUI\MainFrameUI.pas',
  MainFrameUIImpl in 'MainFrameUI\Impl\MainFrameUIImpl.pas',
  MainFrameUIPlugInImpl in 'WDPlugIn\Impl\MainFrameUIPlugInImpl.pas',
  RenderDC in 'UI\Render\RenderDC.pas',
  RenderGDI in 'UI\Render\RenderGDI.pas',
  RenderUtil in 'UI\Render\RenderUtil.pas',
  FrameUI in 'UI\Frame\FrameUI.pas',
  BaseFormUI in 'UI\Form\BaseFormUI.pas',
  ComponentUI in 'UI\Component\ComponentUI.pas',
  AppMainFormUI in 'AppMainForm\AppMainFormUI.pas' {AppMainFormUI},
  AppMenu in 'AppMainForm\Menu\AppMenu.pas',
  AppMenuUI in 'AppMainForm\Menu\AppMenuUI.pas',
  AppSuperTabUI in 'AppMainForm\SuperTab\AppSuperTabUI.pas',
  AppStatusUI in 'AppMainForm\StatusBar\AppStatusUI.pas',
  AppStatus in 'AppMainForm\StatusBar\AppStatus.pas',
  AppStatusImpl in 'AppMainForm\StatusBar\AppStatusImpl.pas';

{$R *.res}

var
  DLLApp: TApplication;

procedure DLLUnloadProc(dwReason: DWORD);
begin
  if dwReason = DLL_PROCESS_DETACH then
    Application := DLLApp; //恢复
end;

begin
  DLLApp := Application;     //保存 DLL 中初始的 Application 对象
  DLLProc := @DLLUnloadProc; //保证 DLL 卸载时恢复原来的 Application
end.
