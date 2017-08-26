unit HqMinuteDataImpl;

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
  HqAuction,
  HqMinuteData,
  CommonRefCounter,
  Generics.Collections;

type

  // ��ʱ���ݽӿ�ʵ��
  THqMinuteDataImpl = class(TAutoInterfacedObject, IHqMinuteData)
  private
    // ���շ�ʱ����
    FHqMinuteCount: Integer;
    // ���շ�ʱ�б�
    FHqMinutes: TList<IHqMinute>;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqMinuteData }

    //��ȡ֤ȯ����
    function GetCode: string;
    //��ȡ���Ͼ�������
    function GetHqAuction: IHqAuction;
    //�������ڻ�ȡ���շ�ʱ����
    function GetHqMinute(ADate: Integer): IHqMinute;
    //��ȡ���շ�ʱ����(����Ϊ0����ǰ�ݼ�-1,-2...)
    function GetMultiHqMinute(AIndex: Integer): IHqMinute;

    //֤ȯ����
    property Code: string read GetCode;
    //���Ͼ�������
    property HqAuction: IHqAuction read GetHqAuction;
    //��ʱ����������
    property HqMinutes[ADate: Integer]: IHqMinute read GetHqMinute;
    //��ʱ����������(����ţ�����Ϊ0����ǰ�ݼ�-1,-2...)
    property MultiHqMinutes[AIndex: Integer]: IHqMinute read GetMultiHqMinute;
  end;

implementation

{ THqMinuteDataImpl }

constructor THqMinuteDataImpl.Create;
begin
  inherited;
  FHqMinutes := TList<IHqMinute>.Create;
end;

destructor THqMinuteDataImpl.Destroy;
begin
  FHqMinutes.Free;
  inherited;
end;

function THqMinuteDataImpl.GetCode: string;
begin

end;

function THqMinuteDataImpl.GetHqAuction: IHqAuction;
begin

end;

function THqMinuteDataImpl.GetHqMinute(ADate: Integer): IHqMinute;
begin

end;

function THqMinuteDataImpl.GetMultiHqMinute(AIndex: Integer): IHqMinute;
begin

end;

end.

