unit ServiceAsset;

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
  SysUtils,
  Service;

type

  IServiceAsset = Interface(IService)
    ['{72B1683E-F608-4FAF-8893-B2125B0B3B66}']
    // ������������
    function PasswordReset(AUserName, AOldPassword, ANewPassword: WideString; var AErrorCode: Integer; var AErrorMsg: WideString): Boolean; safecall;
    // ��Դ�û���¼�ʲ����񷽷�
    function GilUserLogin(AServerUrl, AUserName, AUserPassword: WideString; var APasswordInfo, AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
    // UFX �û���¼�ʲ����񷽷�
    function UFXUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
    // PBox �û���¼�ʲ����񷽷�
    function PBoxUserLogin(AServerUrl, AAssetUserName, AOrgNo, AAssetNo, AAssetUserPassword: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
  end;

implementation

end.
