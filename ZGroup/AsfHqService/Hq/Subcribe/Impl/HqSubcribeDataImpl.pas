unit HqSubcribeDataImpl;

/// /////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-26
// Comments：
//
/// /////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HqSubcribeData,
  CommonRefCounter,
  Generics.Collections;

type

  THqSubscribeDataImpl = class(TAutoInterfacedObject, IHqSubcribeData)
  private
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqSubscribeData }

    // 获取订阅对象ID
    function GetId: Integer;
    // 获取订阅代码列表
    function GetCodeList: TStringList;
    // 获取订阅指标列表
    function GetIndexList: TList<Integer>;

    // ID(负增长，这样产生的ID就不会和请求对象ID重复)
    property Id: Integer read GetId;
    // 订阅代码列表
    property CodeList: TStringList read GetCodeList;
    // 订阅指标列表
    property IndexList: TList<Integer> read GetIndexList;
  end;

implementation

{ THqSubscribeDataImpl }

constructor THqSubscribeDataImpl.Create;
begin
  inherited;

end;

destructor THqSubscribeDataImpl.Destroy;
begin

  inherited;
end;

function THqSubscribeDataImpl.GetId: Integer;
begin

end;

function THqSubscribeDataImpl.GetCodeList: TStringList;
begin

end;

function THqSubscribeDataImpl.GetIndexList: TList<Integer>;
begin

end;

end.
