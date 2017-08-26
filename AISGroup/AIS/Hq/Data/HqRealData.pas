unit HqRealData;

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
  SysUtils;

type

  IHqRealData = Interface(IInterface)
    ['{3C08E88E-B639-4389-8E82-8585B0B5B6AF}']
    // 获取证券代码
    function GetCode: string;
    // 获取证券当日是否停牌
    function GetIsSuspend: Boolean;
    // 根据指标名称获取Double数据
    function GetValue(AName: string): Double;
    // 根据指标名称获取string数据
    function GetStrValue(AName: string): string;

    // 证券代码
    property Code: string read GetCode;
    // 是否停牌
    property IsSuspend: Boolean read GetIsSuspend;
    // 数据索引器
    property Values[Name: string]: Double read GetValue;
    // 字符串数据索引器
    property StrValues[Name: string]: string read GetStrValue;
  end;

implementation

end.
