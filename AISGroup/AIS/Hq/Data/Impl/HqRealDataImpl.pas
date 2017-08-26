unit HqRealDataImpl;

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
  HqRealData,
  CommonRefCounter;

type

  // ʵʱ����
  THqRealDataImpl = class(TAutoInterfacedObject, IHqRealData)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqRealData }

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

{ THqRealDataImpl }

constructor THqRealDataImpl.Create;
begin
  inherited;

end;

destructor THqRealDataImpl.Destroy;
begin

  inherited;
end;

function THqRealDataImpl.GetCode: string;
begin

end;

function THqRealDataImpl.GetIsSuspend: Boolean;
begin

end;

function THqRealDataImpl.GetValue(AName: string): Double;
begin

end;

function THqRealDataImpl.GetStrValue(AName: string): string;
begin

end;

end.
