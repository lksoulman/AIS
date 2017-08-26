library HqService;

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
  HqCoreMgr in 'Hq\HqCoreMgr.pas',
  HqCoreMgrImpl in 'Hq\Impl\HqCoreMgrImpl.pas',
  HqDataCenter in 'Hq\HqDataCenter.pas',
  HqDataCenterImpl in 'Hq\Impl\HqDataCenterImpl.pas',
  HqSubcribeAdapter in 'Hq\HqSubcribeAdapter.pas',
  HqSubcribeAdapterImpl in 'Hq\Impl\HqSubcribeAdapterImpl.pas',
  HqRealData in 'Hq\Data\HqRealData.pas',
  HqTickData in 'Hq\Data\HqTickData.pas',
  HqKLineData in 'Hq\Data\HqKLineData.pas',
  HqMinuteData in 'Hq\Data\HqMinuteData.pas',
  HqKLinePeriod in 'Hq\Data\HqKLinePeriod.pas',
  HqMinute in 'Hq\Data\HqMinute.pas',
  HqAuction in 'Hq\Data\HqAuction.pas',
  HqMinuteImpl in 'Hq\Data\Impl\HqMinuteImpl.pas',
  HqAuctionImpl in 'Hq\Data\Impl\HqAuctionImpl.pas',
  HqRealDataImpl in 'Hq\Data\Impl\HqRealDataImpl.pas',
  HqTickDataImpl in 'Hq\Data\Impl\HqTickDataImpl.pas',
  HqKLineDataImpl in 'Hq\Data\Impl\HqKLineDataImpl.pas',
  HqMinuteDataImpl in 'Hq\Data\Impl\HqMinuteDataImpl.pas',
  HqIndicator in 'Hq\Indicator\HqIndicator.pas',
  HqIndicatorMgr in 'Hq\Indicator\HqIndicatorMgr.pas',
  HqIndicatorData in 'Hq\Indicator\HqIndicatorData.pas',
  HqIndicatorDataMgr in 'Hq\Indicator\HqIndicatorDataMgr.pas',
  HqIndicatorImpl in 'Hq\Indicator\Impl\HqIndicatorImpl.pas',
  HqIndicatorMgrImpl in 'Hq\Indicator\Impl\HqIndicatorMgrImpl.pas',
  HqIndicatorDataImpl in 'Hq\Indicator\Impl\HqIndicatorDataImpl.pas',
  HqIndicatorDataMgrImpl in 'Hq\Indicator\Impl\HqIndicatorDataMgrImpl.pas',
  HqSubcribeData in 'Hq\Subcribe\HqSubcribeData.pas',
  HqSubcribeDataImpl in 'Hq\Subcribe\Impl\HqSubcribeDataImpl.pas';

{$R *.res}

begin


end.
