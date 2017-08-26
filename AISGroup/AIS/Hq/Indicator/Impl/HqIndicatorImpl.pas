unit HqIndicatorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HqIndicator,
  CommonObject,
  CommonRefCounter;

type

  // 指标接口实现
  THqIndicatorImpl = class(TAutoInterfacedObject, IHqIndicator)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqIndicator }

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

{ THqIndicatorImpl }

constructor THqIndicatorImpl.Create;
begin
  inherited;

end;

destructor THqIndicatorImpl.Destroy;
begin

  inherited;
end;

function THqIndicatorImpl.GetCaption: string;
begin

end;

function THqIndicatorImpl.GetId: Integer;
begin

end;

function THqIndicatorImpl.GetDataType: THqDataType;
begin

end;

function THqIndicatorImpl.GetName: string;
begin

end;

function THqIndicatorImpl.GetRelateIndex: TIntegerDynArray;
begin

end;

end.
