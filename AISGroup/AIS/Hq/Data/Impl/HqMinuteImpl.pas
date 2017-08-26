unit HqMinuteImpl;

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
  CommonRefCounter,
  Generics.Collections;

type

  // 单日分时数据接口
  THqMinuteImpl = class(TAutoInterfacedObject, IHqMinute)
  private
    // 日期
    FDate: Integer;
    // 前收盘
    FPrevClose: Double;
    // 最高价
    FPriceHigh: Double;
    // 最低价
    FPriceLow: Double;
    // 最大成交量
    FMaxVolume: Double;
    // 最大成交额
    FMaxTurnover: Double;
    // 分钟数据项
    FHqMinuteItems: TList<PHqMinuteItem>;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqMinute }

    // 获取日期
    function GetDate: Integer;
    // 获取前收价
    function GetPrevClose: Double;
    // 获取今日最高价
    function GetPriceHigh: Double;
    // 获取今日最低价
    function GetPriceLow: Double;
    // 获取最大成交量(每分钟)
    function GetMaxVolume: Double;
    // 获取最大成交金额(每分钟)
    function GetMaxTurnover: Double;
    // 获取数据项数量
    function GetItemCount: Integer;
    // 根据下标获取数据项
    function GetItem(AIndex: Integer): PHqMinuteItem;
  end;

implementation

{ THqMinuteImpl }

constructor THqMinuteImpl.Create;
begin
  inherited;
  FHqMinuteItems := TList<PHqMinuteItem>.Create;
end;

destructor THqMinuteImpl.Destroy;
begin
  FHqMinuteItems.Free;
  inherited;
end;

function THqMinuteImpl.GetDate: Integer;
begin
  Result := FDate;
end;

function THqMinuteImpl.GetPrevClose: Double;
begin
  Result := FPrevClose;
end;

function THqMinuteImpl.GetPriceHigh: Double;
begin
  Result := FPriceHigh;
end;

function THqMinuteImpl.GetPriceLow: Double;
begin
  Result := FPriceLow;
end;

function THqMinuteImpl.GetMaxVolume: Double;
begin
  Result := FMaxVolume;
end;

function THqMinuteImpl.GetMaxTurnover: Double;
begin
  Result := FMaxTurnover;
end;

function THqMinuteImpl.GetItemCount: Integer;
begin
  Result := FHqMinuteItems.Count;
end;

function THqMinuteImpl.GetItem(AIndex: Integer): PHqMinuteItem;
begin
  if (AIndex >= 0) and (AIndex < FHqMinuteItems.Count) then begin
    Result := FHqMinuteItems.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

end.
