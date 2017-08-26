unit HqIndicator;

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
  CommonObject;

type

  // 指标数据类型
  THqDataType = (dtInt8,
                 dtInt16,
                 dtInt32,
                 dtInt64,
                 dtDouble,
                 dtString,
                 dtSequence);

  // 指标接口
  IHqIndicator = Interface(IInterface)
    ['{FD9CE26A-349B-4503-96D2-1BC115D42A08}']
    // 获取指标标题
    function GetCaption: string;
    // 获取指标 Id
    function GetId: Integer;
    // 获取指标数据类型
    function GetDataType: THqDataType;
    // 获取指标名称
    function GetName: string;
    //
    function GetRelateIndex: TIntegerDynArray;

    // 指标ID (>0 基础指标, =0 函数指标, <0 自定义指标)
    property Id : Integer read GetId;
    // 名称
    property Name : string read GetName;
    // 标题
    property Caption : string read GetCaption;
    // 类型
    property DataType : THqDataType read GetDataType;
    // 相关指标(如函数中的参数指标、格式化对象的比较指标，和主指标一同订阅。报价排序使用相关指标的最后一个指标)
    property RelateIndex : TIntegerDynArray read GetRelateIndex;
  end;

implementation

end.
