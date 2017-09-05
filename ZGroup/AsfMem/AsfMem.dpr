library AsfMem;

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
  FactoryAsfMemImpl in 'WExport\Impl\FactoryAsfMemImpl.pas',
  CommonDynArray in 'Common\CommonDynArray.pas',
  SecuMainConst in 'WCMemTable\SecuMain\SecuMainConst.pas',
  SecuMainImpl in 'WCMemTable\SecuMain\Impl\SecuMainImpl.pas',
  SectorMain in 'WCMemTable\SectorMain\SectorMain.pas',
  SectorMainImpl in 'WCMemTable\SectorMain\Impl\SectorMainImpl.pas',
  UserFundMain in 'WCMemTable\UserFundMain\UserFundMain.pas',
  UserFundMainImpl in 'WCMemTable\UserFundMain\Impl\UserFundMainImpl.pas',
  KeyFairy in 'KeyFairy\KeyFairy.pas',
  KeyFairyItemPool in 'KeyFairy\KeyFairyItemPool.pas',
  KeyFairyMgr in 'KeyFairyMgr\KeyFairyMgr.pas',
  KeyFairyMgrImpl in 'KeyFairyMgr\Impl\KeyFairyMgrImpl.pas',
  KeyFairyType in 'KeyFairy\KeyFairyType.pas',
  KeyFairyItem in 'KeyFairy\KeyFairyItem.pas',
  KeyFairyImpl in 'KeyFairy\Impl\KeyFairyImpl.pas',
  Sector in 'Sector\Sector.pas',
  SectorImpl in 'Sector\Impl\SectorImpl.pas',
  SectorMgrImpl in 'SectorMgr\Impl\SectorMgrImpl.pas',
  SysSectorMgr in 'SysSectorMgr\SysSectorMgr.pas',
  SysSectorMgrImpl in 'SysSectorMgr\Impl\SysSectorMgrImpl.pas',
  UserSectorMgr in 'UserSectorMgr\UserSectorMgr.pas',
  UserSectorMgrImpl in 'UserSectorMgr\Impl\UserSectorMgrImpl.pas';

{$R *.res}

begin

end.
