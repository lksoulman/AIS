unit UserAssetCache;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� User asset cache interface
// Author��      lksoulman
// Date��        2017-8-11
// Comments��    User asset cache interface
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNDataSetInf;

type

  // User asset cache interface
  IUserAssetCache = Interface(IInterface)
    ['{5E5F4CBC-73E3-45FF-9C1D-FECE2D9BA039}']
    //  Synchronous query data
    function SyncQuery(ASql: WideString): IWNDataSet; safecall;
    // Asynchronous query data
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

end.
