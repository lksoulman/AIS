unit HqTickDataImpl;

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
  HqTickData,
  CommonRefCounter,
  Generics.Collections;

type

  // 分笔数据接口实现
  THqTickDataImpl = class(TAutoInterfacedObject, IHqTickData)
  private
    // 分笔数据项
    FHqTickItems: TList<PHqTickItem>;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqTickData }

    //获取证券代码
    function GetCode: string;
    //获取分笔项数量
    function GetItemCount: Integer;
    //根据序号获取分笔项
    function GetItem(AIndex: Integer): PHqTickItem;

    //证券代码
    property Code: string read GetCode;
    //分笔项数量
    property ItemCount: Integer read GetItemCount;
    //分笔项索引
    property Items[AIndex: Integer]: PHqTickItem read GetItem;
  end;


implementation

{ THqTickDataImpl }

constructor THqTickDataImpl.Create;
begin
  inherited;
  FHqTickItems := TList<PHqTickItem>.Create;
end;

destructor THqTickDataImpl.Destroy;
begin
  FHqTickItems.Free;
  inherited;
end;

function THqTickDataImpl.GetCode: string;
begin

end;

function THqTickDataImpl.GetItemCount: Integer;
begin
  Result := FHqTickItems.Count;
end;

function THqTickDataImpl.GetItem(AIndex: Integer): PHqTickItem;
begin
  if (AIndex >= 0) and (AIndex < FHqTickItems.Count) then begin
    Result := FHqTickItems.Items[AIndex];
  end;
end;

end.
