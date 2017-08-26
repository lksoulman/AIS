unit HqIndicator;

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
  CommonObject;

type

  // ָ����������
  THqDataType = (dtInt8,
                 dtInt16,
                 dtInt32,
                 dtInt64,
                 dtDouble,
                 dtString,
                 dtSequence);

  // ָ��ӿ�
  IHqIndicator = Interface(IInterface)
    ['{FD9CE26A-349B-4503-96D2-1BC115D42A08}']
    // ��ȡָ�����
    function GetCaption: string;
    // ��ȡָ�� Id
    function GetId: Integer;
    // ��ȡָ����������
    function GetDataType: THqDataType;
    // ��ȡָ������
    function GetName: string;
    //
    function GetRelateIndex: TIntegerDynArray;

    // ָ��ID (>0 ����ָ��, =0 ����ָ��, <0 �Զ���ָ��)
    property Id : Integer read GetId;
    // ����
    property Name : string read GetName;
    // ����
    property Caption : string read GetCaption;
    // ����
    property DataType : THqDataType read GetDataType;
    // ���ָ��(�纯���еĲ���ָ�ꡢ��ʽ������ıȽ�ָ�꣬����ָ��һͬ���ġ���������ʹ�����ָ������һ��ָ��)
    property RelateIndex : TIntegerDynArray read GetRelateIndex;
  end;

implementation

end.
