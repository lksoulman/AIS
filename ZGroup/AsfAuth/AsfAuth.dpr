library AsfAuth;

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
  FactoryAsfAuthImpl in 'WExport\Impl\FactoryAsfAuthImpl.pas',
  HqAuthImpl in 'HqAuth\Impl\HqAuthImpl.pas',
  ProAuthImpl in 'ProAuth\Impl\ProAuthImpl.pas',
  HqAuthPlugInImpl in 'WDPlugIn\Impl\HqAuthPlugInImpl.pas',
  ProAuthPlugInImpl in 'WDPlugIn\Impl\ProAuthPlugInImpl.pas';

{$R *.res}

begin
end.
