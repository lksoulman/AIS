unit HqServerTypeInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-28
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  AppContext,
  QuoteMngr_TLB,
  HqServerTypeInfo,
  CommonRefCounter,
  Generics.Collections;

type

  // 行情服务器类型信息接口实现
  THqServerTypeInfoImpl = class(TAutoInterfacedObject, IHqServerTypeInfo)
  private
    // 线程共享锁
    FLock: TCSLock;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 行情服务器类型列表
    FHqServerTypeItems: TList<PHqServerTypeItem>;
  protected
    // 释放数据
    procedure DoClearServerTypeItem;
    // Int 转 ServerTypeEnum
    function IntToServerTypeEnum(AInt: Integer): ServerTypeEnum;
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IHqServerTypeInfo }
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载数据
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // 加锁
    procedure Lock; safecall;
    // 解锁
    procedure UnLock; safecall;
    // 获取行情服务器类型个数
    function GetHqServerTypeItemCount: Integer; safecall;
    // 获取行情服务器类型指针
    function GetHqServerTypeItem(AIndex: Integer): PHqServerTypeItem; safecall;
    // 获取行情服务器类型指针通过枚举
    function GetHqServerTypeNameByEnum(AEnum: ServerTypeEnum): WideString; safecall;
    // 获取行情服务器类型指针通过枚举
    function GetHqServerTypeItemByEnum(AEnum: ServerTypeEnum): PHqServerTypeItem; safecall;
  end;

implementation

uses
  Utils,
  NativeXml;

{ THqServerTypeInfoImpl }

constructor THqServerTypeInfoImpl.Create;
begin
  inherited;
  FLock := TCSLock.Create;
  FHqServerTypeItems := TList<PHqServerTypeItem>.Create;
end;

destructor THqServerTypeInfoImpl.Destroy;
begin
  DoClearServerTypeItem;
  FHqServerTypeItems.Free;
  FLock.Free;
  inherited;
end;

procedure THqServerTypeInfoImpl.DoClearServerTypeItem;
var
  LIndex: Integer;
  LHqServerTypeItem: PHqServerTypeItem;
begin
  for LIndex := 0 to FHqServerTypeItems.Count - 1 do begin
    LHqServerTypeItem := FHqServerTypeItems.Items[LIndex];
    if LHqServerTypeItem <> nil then begin
      Dispose(LHqServerTypeItem);
    end;
  end;
  FHqServerTypeItems.Clear;
end;

function THqServerTypeInfoImpl.IntToServerTypeEnum(AInt: Integer): ServerTypeEnum;
begin
  case AInt of
    1:
      begin
        Result := stStockLevelI;
      end;
    2:
      begin
        Result := stStockLevelII;
      end;
    3:
      begin
        Result := stFutues;
      end;
    4:
      begin
        Result := stStockHK;
      end;
    5:
      begin
        Result := stForeign;
      end;
    6:
      begin
        Result := stHKDelay;
      end;
    7:
      begin
        Result := stDDE;
      end;
  else
      begin
        Result := stUSStock;
      end;
  end;
end;

procedure THqServerTypeInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;

end;

procedure THqServerTypeInfoImpl.UnInitialize;
begin

  FAppContext := nil;
end;

procedure THqServerTypeInfoImpl.LoadXmlNodes(ANodeList: TList);
var
  LIndex: Integer;
  LNode: TXmlNode;
  LHqServerTypeItem: PHqServerTypeItem;
begin
  if ANodeList = nil then Exit;
  
  for LIndex := 0 to ANodeList.Count - 1 do begin
    LNode := ANodeList.Items[LIndex];
    if LNode <> nil then begin
      New(LHqServerTypeItem);
      LHqServerTypeItem.FIsUsed := True;
      LHqServerTypeItem.FName := Utils.GetStringByChildNodeName(LNode, 'Name');
      LHqServerTypeItem.FTypeEnum := IntToServerTypeEnum(Utils.GetIntegerByChildNodeName(LNode, 'Type', 1));
      FHqServerTypeItems.Add(LHqServerTypeItem);
      LHqServerTypeItem.FServerStatus := ssInit;
    end;
  end;
end;

procedure THqServerTypeInfoImpl.Lock;
begin
  FLock.Lock;
end;

procedure THqServerTypeInfoImpl.UnLock;
begin
  FLock.UnLock;
end;

function THqServerTypeInfoImpl.GetHqServerTypeItemCount: Integer;
begin
  Result := FHqServerTypeItems.Count;
end;

function THqServerTypeInfoImpl.GetHqServerTypeItem(AIndex: Integer): PHqServerTypeItem;
begin
  if (AIndex >= 0)
    and (AIndex < FHqServerTypeItems.Count)then begin
    Result := FHqServerTypeItems.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function THqServerTypeInfoImpl.GetHqServerTypeNameByEnum(AEnum: ServerTypeEnum): WideString;
var
  LHqServerTypeItem: PHqServerTypeItem;
begin
  Result := '';
  LHqServerTypeItem := GetHqServerTypeItemByEnum(AEnum);
  if LHqServerTypeItem <> nil then begin
    Result := LHqServerTypeItem.FName;
  end;
end;

function THqServerTypeInfoImpl.GetHqServerTypeItemByEnum(AEnum: ServerTypeEnum): PHqServerTypeItem;
var
  LIndex: Integer;
  LHqServerTypeItem: PHqServerTypeItem;
begin
  Result := nil;
  for LIndex := 0 to FHqServerTypeItems.Count - 1 do begin
    LHqServerTypeItem := FHqServerTypeItems.Items[LIndex];
    if (LHqServerTypeItem <> nil)
      and (LHqServerTypeItem.FTypeEnum = AEnum) then begin
      Result := LHqServerTypeItem;
      Break;
    end;
  end;
end;

end.
