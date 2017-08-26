unit HqIndicatorImpl;

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
  HqIndicator,
  CommonObject,
  CommonRefCounter;

type

  // ָ��ӿ�ʵ��
  THqIndicatorImpl = class(TAutoInterfacedObject, IHqIndicator)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqIndicator }

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

{ THqIndicatorImpl }

constructor THqIndicatorImpl.Create;
begin
  inherited;

end;

destructor THqIndicatorImpl.Destroy;
begin

  inherited;
end;

function THqIndicatorImpl.GetCaption: string;
begin

end;

function THqIndicatorImpl.GetId: Integer;
begin

end;

function THqIndicatorImpl.GetDataType: THqDataType;
begin

end;

function THqIndicatorImpl.GetName: string;
begin

end;

function THqIndicatorImpl.GetRelateIndex: TIntegerDynArray;
begin

end;

end.
