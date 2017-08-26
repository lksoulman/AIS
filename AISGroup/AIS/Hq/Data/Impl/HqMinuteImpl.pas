unit HqMinuteImpl;

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
  HqMinute,
  CommonRefCounter,
  Generics.Collections;

type

  // ���շ�ʱ���ݽӿ�
  THqMinuteImpl = class(TAutoInterfacedObject, IHqMinute)
  private
    // ����
    FDate: Integer;
    // ǰ����
    FPrevClose: Double;
    // ��߼�
    FPriceHigh: Double;
    // ��ͼ�
    FPriceLow: Double;
    // ���ɽ���
    FMaxVolume: Double;
    // ���ɽ���
    FMaxTurnover: Double;
    // ����������
    FHqMinuteItems: TList<PHqMinuteItem>;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqMinute }

    // ��ȡ����
    function GetDate: Integer;
    // ��ȡǰ�ռ�
    function GetPrevClose: Double;
    // ��ȡ������߼�
    function GetPriceHigh: Double;
    // ��ȡ������ͼ�
    function GetPriceLow: Double;
    // ��ȡ���ɽ���(ÿ����)
    function GetMaxVolume: Double;
    // ��ȡ���ɽ����(ÿ����)
    function GetMaxTurnover: Double;
    // ��ȡ����������
    function GetItemCount: Integer;
    // �����±��ȡ������
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
