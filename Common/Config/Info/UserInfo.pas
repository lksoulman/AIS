unit UserInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  // 登录类型
  TLoginType = (ltUFX,          // UFX 登录类型
                ltGIL,      // 聚源登录类型
                ltPBOX);        // PBox 登录类型

  // 用户信息接口
  IUserInfo = Interface(IInterface)
    ['{D1DB6423-8030-4125-9EFF-D63DF03957FC}']
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 保存缓存
    procedure SaveCache; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 重置绑定信息
    procedure ResetBindInfo; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // 机构编号
    function GetProNo: WideString; safecall;
    // 机构编号
    procedure SetProNo(AProNo: WideString); safecall;
    // 产品编号
    function GetOrgNo: WideString; safecall;
    // 产品编号
    procedure SetOrgNo(AOrgNo: WideString); safecall;
    // 资产编号
    function GetAssetNo: WideString; safecall;
    // 资产编号
    procedure SetAssetNo(AAssetNo: WideString); safecall;
    // 获取是不是保存密码
    function GetSavePassword: Boolean; safecall;
    // 设置是不是保存密码
    procedure SetSavePassword(ASavePassword: boolean); safecall;
    // 聚源用户名称
    function GetUserName: WideString; safecall;
    // 聚源用户名称
    procedure SetUserName(AUserName: WideString); safecall;
    // 聚源用户密码
    function GetUserPassword: WideString; safecall;
    // 获取密文的用户密码
    function GetCiperUserPassword: WideString; safecall;
    // 聚源用户密码
    procedure SetUserPassword(APassword: WideString); safecall;
    // 资产用户名称
    function GetAssetUserName: WideString; safecall;
    // 资产用户名称
    procedure SetAssetUserName(AUserName: WideString); safecall;
    // 资产用户密码
    function GetAssetUserPassword: WideString; safecall;
    // 获取密文的资产用户密码
    function GetCiperAssetUserPassword: WideString; safecall;
    // 用户密码
    procedure SetAssetUserPassword(APassword: WideString); safecall;
    // 绑定后的 License
    function GetBindLicense: WideString; safecall;
    // 绑定后的 License
    procedure SetBindLicense(ABindLicense: WideString); safecall;
    // 用户所属机构所属标记
    function GetBindOrgSign: WideString; safecall;
    // 用户所属机构所属标记
    procedure SetBindOrgSign(ABindOrgSign: WideString); safecall;
    // 获取是不是需要 N 天后修改密码
    function GetPasswordExpire: boolean; safecall;
    // 获取设置是不是需要 N 天后修改密码
    procedure SetPasswordExpire(APasswordExpire: boolean); safecall;
    // 获取密码过期天数
    function GetPasswordExpireDays: Integer; safecall;
    // 设置密码过期天数
    procedure SetPasswordExpireDays(ADay: Integer); safecall;
    // 设置服务端返回的密码信息 Json 字符串
    procedure SetPasswordInfo(APasswordInfo: string); safecall;
    // 登录类型
    function GetLoginType: TLoginType; safecall;
    // 登录类型
    procedure SetLoginType(ALoginType: TLoginType); safecall;
  end;

implementation

end.
