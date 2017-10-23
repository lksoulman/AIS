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
  WExport in 'WExport\WExport.pas',
  FactoryAsfAUIImpl in 'WExport\Impl\FactoryAsfAUIImpl.pas',
  ImageUI in 'Common\ImageUI.pas',
  RenderEngine in 'Common\RenderEngine.pas',
  ButtonUI in 'Common\ButtonUI.pas',
  ControlUI in 'Common\ControlUI.pas',
  PageControlUI in 'Common\PageControlUI.pas',
  FormUI in 'FormUI\FormUI.pas' {FormUI},
  MDI in 'MDI\MDI.pas' {MDIForm},
  MDIChild in 'MDIChild\MDIChild.pas' {MDIChildForm},
  MainFrameUI in 'MainFrameUI\MainFrameUI.pas',
  MainFrameUIImpl in 'MainFrameUI\Impl\MainFrameUIImpl.pas',
  ImageButtonUI in 'Common\ImageButtonUI.pas',
  amMouseWheel in 'Common\amMouseWheel.pas',
  RenderClip in 'Common\RenderClip.pas',
  RenderGdi in 'Common\RenderGdi.pas',
  RenderDC in 'Common\RenderDC.pas',
  FrameUI in 'Common\FrameUI.pas',
  AppMenuUI in 'AppMenu\AppMenuUI.pas',
  AppMenuButtonUI in 'AppMenu\AppMenuButtonUI.pas',
  CommandInfo in 'Command\CommandInfo.pas',
  MainFrameUIPlugInImpl in 'WDPlugIn\Impl\MainFrameUIPlugInImpl.pas';

{$R *.res}

begin
end.
