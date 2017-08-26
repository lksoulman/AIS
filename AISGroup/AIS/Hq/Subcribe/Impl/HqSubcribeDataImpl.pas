unit HqSubcribeDataImpl;

/// /////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-26
// Comments��
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
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqSubscribeData }

    // ��ȡ���Ķ���ID
    function GetId: Integer;
    // ��ȡ���Ĵ����б�
    function GetCodeList: TStringList;
    // ��ȡ����ָ���б�
    function GetIndexList: TList<Integer>;

    // ID(������������������ID�Ͳ�����������ID�ظ�)
    property Id: Integer read GetId;
    // ���Ĵ����б�
    property CodeList: TStringList read GetCodeList;
    // ����ָ���б�
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
