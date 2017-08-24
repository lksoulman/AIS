unit SecuBaseData;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-23
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Security,
  AppContext,
  CommonObject;

type

  ISecuBaseData = Interface(IInterface)
    ['{69D7EFF9-C62E-49EB-BDED-8523E2273A8C}']
    // ͨ��֤ȯ�����ȡ֤ȯ��Ϣ
    function QuerySecurity(AInnerCode: Integer): ISecurity; safecall;
    // ͨ�����֤ȯ�����ȡ�����ȡ֤ȯ��Ϣ
    function QuerySecuritys(AInnerCodes: TIntegerDynArray; var ASecuritys: TSecuritys): Boolean; safecall;
  end;

implementation

end.
