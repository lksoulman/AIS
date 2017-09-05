unit HqSubcribeData;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-26
// Comments��
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

end.
