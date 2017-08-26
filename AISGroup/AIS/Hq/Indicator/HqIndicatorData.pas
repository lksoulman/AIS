unit HqIndicatorData;

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

  IHqIndicatorData = Interface(IInterface)
    ['{F322BA0B-CD46-4C14-A349-7E4F3B98C3F9}']
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

end.
