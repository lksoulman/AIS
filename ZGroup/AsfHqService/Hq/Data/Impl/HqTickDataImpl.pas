unit HqTickDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
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

  // �ֱ����ݽӿ�ʵ��
  THqTickDataImpl = class(TAutoInterfacedObject, IHqTickData)
  private
    // �ֱ�������
    FHqTickItems: TList<PHqTickItem>;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqTickData }

    //��ȡ֤ȯ����
    function GetCode: string;
    //��ȡ�ֱ�������
    function GetItemCount: Integer;
    //������Ż�ȡ�ֱ���
    function GetItem(AIndex: Integer): PHqTickItem;

    //֤ȯ����
    property Code: string read GetCode;
    //�ֱ�������
    property ItemCount: Integer read GetItemCount;
    //�ֱ�������
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
