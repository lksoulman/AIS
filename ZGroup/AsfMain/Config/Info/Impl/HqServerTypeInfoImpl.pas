unit HqServerTypeInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-28
// Comments��
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

  // ���������������Ϣ�ӿ�ʵ��
  THqServerTypeInfoImpl = class(TAutoInterfacedObject, IHqServerTypeInfo)
  private
    // �̹߳�����
    FLock: TCSLock;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ��������������б�
    FHqServerTypeItems: TList<PHqServerTypeItem>;
  protected
    // �ͷ�����
    procedure DoClearServerTypeItem;
    // Int ת ServerTypeEnum
    function IntToServerTypeEnum(AInt: Integer): ServerTypeEnum;
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqServerTypeInfo }
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��������
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // ����
    procedure Lock; safecall;
    // ����
    procedure UnLock; safecall;
    // ��ȡ������������͸���
    function GetHqServerTypeItemCount: Integer; safecall;
    // ��ȡ�������������ָ��
    function GetHqServerTypeItem(AIndex: Integer): PHqServerTypeItem; safecall;
    // ��ȡ�������������ָ��ͨ��ö��
    function GetHqServerTypeNameByEnum(AEnum: ServerTypeEnum): WideString; safecall;
    // ��ȡ�������������ָ��ͨ��ö��
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
