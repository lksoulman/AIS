unit HqMinuteData;

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
  HqAuction;

type

  // ��ʱ���ݽӿ�
  IHqMinuteData = Interface(IInterface)
    ['{0116AD98-9408-44F7-B12C-E90BCF9929FA}']
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

end.
