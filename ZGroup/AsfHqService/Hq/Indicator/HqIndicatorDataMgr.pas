unit HqIndicatorDataMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-26
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HqIndicatorData;

type

  // 指标管理接口
  IHqIndicatorDataMgr = Interface(IInterface)
    ['{EEDFC46C-327A-44F6-9EFE-7420C0EFD5C1}']
    // 获取指标数据
    function GetIndicatorData(AName: string): IHqIndicatorData;

    // 指标索引
    property IndicatorDatas[AName: string]: IHqIndicatorData read GetIndicatorData;
  end;

implementation

end.
