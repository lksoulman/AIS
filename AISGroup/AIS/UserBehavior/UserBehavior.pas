unit UserBehavior;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // �û���Ϊ�ϴ��ӿ�
  IUserBehavior = Interface(IInterface)
    ['{45E8FE12-B9DA-4370-BFBD-FB91CDC3E407}']
    // ����û���Ϊ����
    procedure AddBehavior(ABehavior: WideString); safecall;
  end;

implementation

end.
