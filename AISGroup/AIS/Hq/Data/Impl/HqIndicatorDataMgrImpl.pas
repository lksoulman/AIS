unit HqIndicatorDataMgrImpl;

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
  HqIndicatorData,
  CommonRefCounter,
  HqIndicatorDataMgr;

type

  // 指标管理接口
  THqIndicatorDataMgrImpl = class(TAutoInterfacedObject, IHqIndicatorDataMgr)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqIndicatorDataMgr }

    // 获取指标数据
    function GetIndicatorData(AName: string): IHqIndicatorData;

    // 指标索引
    property IndicatorDatas[AName: string]: IHqIndicatorData read GetIndicatorData;
  end;

implementation

{ THqIndicatorDataMgrImpl }

constructor THqIndicatorDataMgrImpl.Create;
begin
  inherited;

end;

destructor THqIndicatorDataMgrImpl.Destroy;
begin

  inherited;
end;

function THqIndicatorDataMgrImpl.GetIndicatorData(AName: string): IHqIndicatorData;
begin

end;

end.
