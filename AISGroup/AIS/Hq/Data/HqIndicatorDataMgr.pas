unit HqIndicatorDataMgr;

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
  HqIndicatorData;

type

  // ָ�����ӿ�
  IHqIndicatorDataMgr = Interface(IInterface)
    ['{EEDFC46C-327A-44F6-9EFE-7420C0EFD5C1}']
    // ��ȡָ������
    function GetIndicatorData(AName: string): IHqIndicatorData;

    // ָ������
    property IndicatorDatas[AName: string]: IHqIndicatorData read GetIndicatorData;
  end;

implementation

end.
