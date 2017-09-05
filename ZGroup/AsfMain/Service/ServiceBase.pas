unit ServiceBase;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-10
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  UserInfo,
  Service;

type

  IServiceBase = Interface(IService)
    ['{0D5B1F4D-6189-4568-B6DF-88C535DF8A53}']
    // ¾ÛÔ´°ó¶¨
    function GilUserBind(AServerUrl, AUserName, AAssetUserName, AOrgNo, AAssetNo: WideString; var ABindLicense, ABindOrgSign, AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
    // ¾ÛÔ´µÇÂ¼
    function GilUserLogin(AccountType: TAccountType; AServerUrl, ABindLicense, AAssetUserName, AOrgNo, AAssetNo: WideString; var AErrorMsg: WideString; var AErrorCode: Integer): Boolean; safecall;
  end;

implementation

end.
