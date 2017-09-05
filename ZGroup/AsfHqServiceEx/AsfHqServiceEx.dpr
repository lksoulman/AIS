library AsfHqServiceEx;

uses
  ComServ,
  Manager in 'pas\Manager.pas' {QuoteManager: CoClass},
  IOCPClient in 'IOCP\IOCPClient.pas',
  IOCPLibrary in 'IOCP\IOCPLibrary.pas',
  IOCPMemory in 'IOCP\IOCPMemory.pas',
  IOCPUtil in 'IOCP\IOCPUtil.pas',
  QuoteService in 'Quote\QuoteService.pas',
  QuoteSubscribe in 'Quote\QuoteSubscribe.pas',
  QuoteLibrary in 'Quote\QuoteLibrary.pas',
  QuoteBusiness in 'Quote\QuoteBusiness.pas',
  QuoteDataObject in 'Quote\QuoteDataObject.pas',
  QuoteDataMngr in 'Quote\QuoteDataMngr.pas',
  BizPacket in 'Quote\BizPacket.pas',
  BizPacket2Impl in 'Quote\BizPacket2Impl.pas',
  U_Des in 'pas\U_Des.pas',
  U_SerialUtils in 'pas\U_SerialUtils.pas',
  md5 in 'pas\md5.pas',
  QuoteManagerEvents in 'pas\QuoteManagerEvents.pas',
  QDOMarketMonitor in 'Quote\QuoteDataObjects\QDOMarketMonitor.pas',
  QDOBase in 'Quote\QuoteDataObjects\QDOBase.pas',
  QDOSingleColValue in 'Quote\QuoteDataObjects\QDOSingleColValue.pas',
  QDODDERealTime in 'Quote\QuoteDataObjects\QDODDERealTime.pas',
  QuoteColumnDefinex in 'Quote\QuoteColumnDefinex.pas',
  QuoteManagerExImpl in 'QuoteManagerEx\QuoteManagerExImpl.pas',
  QuoteManagerEx in 'QuoteManagerEx\QuoteManagerEx.pas',
  QuoteCodeInfosEx in 'QuoteCodeInfosEx\QuoteCodeInfosEx.pas',
  QuoteCodeInfosExImpl in 'QuoteCodeInfosEx\Impl\QuoteCodeInfosExImpl.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
