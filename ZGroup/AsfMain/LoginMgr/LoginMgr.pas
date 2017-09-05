unit LoginMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-19
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LoginGFType;

type

  // ��¼�������
  ILoginMgr = Interface(IInterface)
    ['{0EB26223-1CCC-4FF6-B4B7-4CD5AB77C55D}']
    // �ǲ��ǵ�¼ GF ����
    function IsLoginGF(AGFType: TLoginGFType): Boolean; safecall;
    // �����������µ�¼
    procedure BaseGFUserLogin(AErrorCode: Integer; const AValue: WideString); safecall;
    // �ʲ��������µ�¼
    procedure AssetGFUserLogin(AErrorCode: Integer; const AValue: WideString); safecall;
  end;

implementation

end.
