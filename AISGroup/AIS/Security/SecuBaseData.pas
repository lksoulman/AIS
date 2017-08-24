unit SecuBaseData;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-23
// Comments：
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
    // 通过证券内码获取证券信息
    function QuerySecurity(AInnerCode: Integer): ISecurity; safecall;
    // 通过多个证券内码获取多个获取证券信息
    function QuerySecuritys(AInnerCodes: TIntegerDynArray; var ASecuritys: TSecuritys): Boolean; safecall;
  end;

implementation

end.
