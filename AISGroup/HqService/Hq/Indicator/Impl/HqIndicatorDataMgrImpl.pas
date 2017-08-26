unit HqIndicatorDataMgrImpl;

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
  HqIndicatorData,
  CommonRefCounter,
  HqIndicatorDataMgr;

type

  // ָ�����ӿ�
  THqIndicatorDataMgrImpl = class(TAutoInterfacedObject, IHqIndicatorDataMgr)
  private
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqIndicatorDataMgr }

    // ��ȡָ������
    function GetIndicatorData(AName: string): IHqIndicatorData;

    // ָ������
    property IndicatorDatas[AName: string]: IHqIndicatorData read GetIndicatorData;
  end;

implementation

{ THqIndicatorDataMgrImpl }

constructor THqIndicatorDataMgrImpl.Create;
begin
  inherited;

end;

destructor THqIndicatorDataMgrImpl.Destroy;
begin

  inherited;
end;

function THqIndicatorDataMgrImpl.GetIndicatorData(AName: string): IHqIndicatorData;
begin

end;

end.
