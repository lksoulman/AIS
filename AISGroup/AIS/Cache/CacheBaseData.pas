unit CacheBaseData;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-11
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNDataSetInf;

type

  // 基础数据接口
  ICacheBaseData = Interface(IInterface)
    ['{D3E280F2-E5F1-4D74-818B-1F0BFC0016AE}']
    // 同步获取 Cache 数据
    function SyncCacheQueryData(ASql: WideString): IWNDataSet; safecall;
    // 异步获取 Cache 数据
    procedure AsyncCacheQueryData(ASql: WideString; ADataArrive: Int64; ATag: Int64); safecall;
  end;

implementation

end.
