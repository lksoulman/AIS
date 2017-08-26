unit HqIndicatorData;

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

  IHqIndicatorData = Interface(IInterface)
    ['{F322BA0B-CD46-4C14-A349-7E4F3B98C3F9}']
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

end.
