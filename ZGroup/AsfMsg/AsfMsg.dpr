library AsfMsg;

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
  FactoryAsfMsgImpl in 'WExport\Impl\FactoryAsfMsgImpl.pas',
  MsgPool in 'Msg\MsgPool.pas',
  MsgExImpl in 'Msg\Impl\MsgExImpl.pas',
  MsgSubcribeMgr in 'Msg\MsgSubcribeMgr.pas',
  MsgDispachingDic in 'Msg\MsgDispachingDic.pas',
  MsgFactory in 'MsgFactory\MsgFactory.pas',
  MsgFactoryImpl in 'MsgFactory\Impl\MsgFactoryImpl.pas',
  MsgReceiverPend in 'MsgReceiver\MsgReceiverPend.pas',
  MsgReceiverImpl in 'MsgReceiver\Impl\MsgReceiverImpl.pas',
  MsgServiceImpl in 'MsgService\Impl\MsgServiceImpl.pas',
  MsgServicePlugInImpl in 'WDPlugIn\Impl\MsgServicePlugInImpl.pas';

{$R *.res}

begin
end.
