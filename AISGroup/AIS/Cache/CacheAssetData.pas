unit CacheAssetData;

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNDataSetInf;

type

  ICacheAssetData = Interface(IInterface)
    ['{5E5F4CBC-73E3-45FF-9C1D-FECE2D9BA039}']
    // ͬ����ȡ Cache ����
    function SyncCacheQueryData(ASql: WideString): IWNDataSet; safecall;
    // �첽��ȡ Cache ����
    procedure AsyncCacheQueryData(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

end.
