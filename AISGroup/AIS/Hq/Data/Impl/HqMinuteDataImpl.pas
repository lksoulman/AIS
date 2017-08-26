unit HqMinuteDataImpl;

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
  HqMinute,
  HqAuction,
  HqMinuteData,
  CommonRefCounter,
  Generics.Collections;

type

  // 分时数据接口实现
  THqMinuteDataImpl = class(TAutoInterfacedObject, IHqMinuteData)
  private
    // 单日分时个数
    FHqMinuteCount: Integer;
    // 单日分时列表
    FHqMinutes: TList<IHqMinute>;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqMinuteData }

    //获取证券代码
    function GetCode: string;
    //获取集合竞价数据
    function GetHqAuction: IHqAuction;
    //根据日期获取当日分时数据
    function GetHqMinute(ADate: Integer): IHqMinute;
    //获取多日分时数据(当日为0，向前递减-1,-2...)
    function GetMultiHqMinute(AIndex: Integer): IHqMinute;

    //证券代码
    property Code: string read GetCode;
    //集合竞价数据
    property HqAuction: IHqAuction read GetHqAuction;
    //分时数据索引器
    property HqMinutes[ADate: Integer]: IHqMinute read GetHqMinute;
    //分时数据索引器(按序号，当日为0，向前递减-1,-2...)
    property MultiHqMinutes[AIndex: Integer]: IHqMinute read GetMultiHqMinute;
  end;

implementation

{ THqMinuteDataImpl }

constructor THqMinuteDataImpl.Create;
begin
  inherited;
  FHqMinutes := TList<IHqMinute>.Create;
end;

destructor THqMinuteDataImpl.Destroy;
begin
  FHqMinutes.Free;
  inherited;
end;

function THqMinuteDataImpl.GetCode: string;
begin

end;

function THqMinuteDataImpl.GetHqAuction: IHqAuction;
begin

end;

function THqMinuteDataImpl.GetHqMinute(ADate: Integer): IHqMinute;
begin

end;

function THqMinuteDataImpl.GetMultiHqMinute(AIndex: Integer): IHqMinute;
begin

end;

end.

