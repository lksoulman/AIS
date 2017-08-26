unit HqIndicatorDataImpl;

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
  CommonObject,
  HqIndicatorData,
  CommonRefCounter;

type

  THqIndicatorDataImpl = class(TAutoInterfacedObject, IHqIndicatorData)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqIndicatorData }

    //获取指标名称
    function GetName: string;
    //获取指标线数量
    function GetLineCount: Integer;
    //获取数据长度
    function GetDataLen: Integer;
    //获取数据
    function GetData(ALineIndex, AIndex: Integer): Double;
    //获取参数
    function GetParams: TIntegerDynArray;
    //设置参数
    procedure SetParams(const Value: TIntegerDynArray);

    //重新计算
    procedure ReCalc;

    //指标名称
    property Name: string read GetName;
    //指标参数
    property Params: TIntegerDynArray read GetParams write SetParams;
    //指标线数量
    property LineCount: Integer read GetLineCount;
    //数据长度
    property DataLen: Integer read GetDataLen;
    //指标数据索引(ALineIndex:指标线序号，AIndex:数据序号)
    property Datas[ALineIndex, AIndex: Integer]: Double read GetData;
  end;

implementation

{ THqIndicatorDataImpl }

constructor THqIndicatorDataImpl.Create;
begin
  inherited;

end;

destructor THqIndicatorDataImpl.Destroy;
begin

  inherited;
end;

function THqIndicatorDataImpl.GetName: string;
begin

end;

function THqIndicatorDataImpl.GetLineCount: Integer;
begin

end;

function THqIndicatorDataImpl.GetDataLen: Integer;
begin

end;

function THqIndicatorDataImpl.GetData(ALineIndex, AIndex: Integer): Double;
begin

end;

function THqIndicatorDataImpl.GetParams: TIntegerDynArray;
begin

end;

procedure THqIndicatorDataImpl.SetParams(const Value: TIntegerDynArray);
begin

end;

procedure THqIndicatorDataImpl.ReCalc;
begin

end;

end.
