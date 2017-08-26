unit HqSubcribeData;

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
  Generics.Collections;

type

  IHqSubcribeData = Interface(IInterface)
    ['{35BE4334-D24C-47D3-AB87-AF9A37FBDF55}']
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

end.
