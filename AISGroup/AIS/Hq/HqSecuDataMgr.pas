unit HqSecuDataMgr;

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
  AppContext;

type

  // ����֤ȯ��Ϣ����
  IHqSecuDataMgr = Interface(IInterface)
    ['{694F6863-9800-4FC2-BEE5-A710E8E81F9C}']
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
  end;

implementation

end.
