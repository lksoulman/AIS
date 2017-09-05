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
  HqAuth in 'HqAuth\HqAuth.pas',
  HqAuthImpl in 'HqAuth\Impl\HqAuthImpl.pas',
  HqAuthPlugInImpl in 'WDPlugIn\Impl\HqAuthPlugInImpl.pas',
  ProductAuth in 'ProductAuth\ProductAuth.pas',
  ProductAuthImpl in 'ProductAuth\Impl\ProductAuthImpl.pas',
  ProductAuthPlugInImpl in 'WDPlugIn\Impl\ProductAuthPlugInImpl.pas';

{$R *.res}

begin
end.
