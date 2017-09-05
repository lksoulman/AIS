unit HqIndicatorDataImpl;

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
  CommonObject,
  HqIndicatorData,
  CommonRefCounter;

type

  THqIndicatorDataImpl = class(TAutoInterfacedObject, IHqIndicatorData)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqIndicatorData }

    //��ȡָ������
    function GetName: string;
    //��ȡָ��������
    function GetLineCount: Integer;
    //��ȡ���ݳ���
    function GetDataLen: Integer;
    //��ȡ����
    function GetData(ALineIndex, AIndex: Integer): Double;
    //��ȡ����
    function GetParams: TIntegerDynArray;
    //���ò���
    procedure SetParams(const Value: TIntegerDynArray);

    //���¼���
    procedure ReCalc;

    //ָ������
    property Name: string read GetName;
    //ָ�����
    property Params: TIntegerDynArray read GetParams write SetParams;
    //ָ��������
    property LineCount: Integer read GetLineCount;
    //���ݳ���
    property DataLen: Integer read GetDataLen;
    //ָ����������(ALineIndex:ָ������ţ�AIndex:�������)
    property Datas[ALineIndex, AIndex: Integer]: Double read GetData;
  end;

implementation

{ THqIndicatorDataImpl }

constructor THqIndicatorDataImpl.Create;
begin
  inherited;

end;

destructor THqIndicatorDataImpl.Destroy;
begin

  inherited;
end;

function THqIndicatorDataImpl.GetName: string;
begin

end;

function THqIndicatorDataImpl.GetLineCount: Integer;
begin

end;

function THqIndicatorDataImpl.GetDataLen: Integer;
begin

end;

function THqIndicatorDataImpl.GetData(ALineIndex, AIndex: Integer): Double;
begin

end;

function THqIndicatorDataImpl.GetParams: TIntegerDynArray;
begin

end;

procedure THqIndicatorDataImpl.SetParams(const Value: TIntegerDynArray);
begin

end;

procedure THqIndicatorDataImpl.ReCalc;
begin

end;

end.
