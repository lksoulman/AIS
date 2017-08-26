unit HqSubcribeAdapter;

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
  AppContext,
  HqSubscribeData;

type


  // ���鶩������
  IHqSubcribeAdapter = Interface(IInterface)
    ['{680B94C1-C877-4674-9C75-BB7394201B3B}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
  end;

implementation

end.
