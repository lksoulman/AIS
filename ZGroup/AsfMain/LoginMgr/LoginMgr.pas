unit LoginMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-19
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LoginGFType;

type

  // 登录管理对象
  ILoginMgr = Interface(IInterface)
    ['{0EB26223-1CCC-4FF6-B4B7-4CD5AB77C55D}']
    // 是不是登录 GF 服务
    function IsLoginGF(AGFType: TLoginGFType): Boolean; safecall;
    // 基础服务重新登录
    procedure BaseGFUserLogin(AErrorCode: Integer; const AValue: WideString); safecall;
    // 资产服务重新登录
    procedure AssetGFUserLogin(AErrorCode: Integer; const AValue: WideString); safecall;
  end;

implementation

end.
