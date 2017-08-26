unit HqRealDataImpl;

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
  HqRealData,
  CommonRefCounter;

type

  // 实时数据
  THqRealDataImpl = class(TAutoInterfacedObject, IHqRealData)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqRealData }

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

{ THqRealDataImpl }

constructor THqRealDataImpl.Create;
begin
  inherited;

end;

destructor THqRealDataImpl.Destroy;
begin

  inherited;
end;

function THqRealDataImpl.GetCode: string;
begin

end;

function THqRealDataImpl.GetIsSuspend: Boolean;
begin

end;

function THqRealDataImpl.GetValue(AName: string): Double;
begin

end;

function THqRealDataImpl.GetStrValue(AName: string): string;
begin

end;

end.
