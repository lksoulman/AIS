unit UserCache;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º User cache interface
// Author£º      lksoulman
// Date£º        2017-8-11
// Comments£º    User cache interface
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNDataSetInf;

type

  // User cache interface
  IUserCache = Interface(IInterface)
    ['{D3E280F2-E5F1-4D74-818B-1F0BFC0016AE}']
    //  Synchronous query data
    function SyncQuery(ASql: WideString): IWNDataSet; safecall;
    // Asynchronous query data
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

end.
