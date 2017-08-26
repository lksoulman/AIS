unit HqRealData;

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
  SysUtils;

type

  IHqRealData = Interface(IInterface)
    ['{3C08E88E-B639-4389-8E82-8585B0B5B6AF}']
    // ��ȡ֤ȯ����
    function GetCode: string;
    // ��ȡ֤ȯ�����Ƿ�ͣ��
    function GetIsSuspend: Boolean;
    // ����ָ�����ƻ�ȡDouble����
    function GetValue(AName: string): Double;
    // ����ָ�����ƻ�ȡstring����
    function GetStrValue(AName: string): string;

    // ֤ȯ����
    property Code: string read GetCode;
    // �Ƿ�ͣ��
    property IsSuspend: Boolean read GetIsSuspend;
    // ����������
    property Values[Name: string]: Double read GetValue;
    // �ַ�������������
    property StrValues[Name: string]: string read GetStrValue;
  end;

implementation

end.
