unit ProxyInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-21
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  GFDataMngr_TLB;

type

  TProxyType = (ptNoProxy =   $00000001,
                ptHTTPProxy = $00000002,
                ptSocks4 =    $00000003,
                ptSocks5 =    $00000004);

  IProxyInfo = Interface(IInterface)
    ['{32F1B998-39F2-4411-87B3-763A1EE39A9A}']
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 保存缓存
    procedure SaveCache; safecall;
    // 加载缓存
    procedure LoadCache; safecall;
    // 恢复默认
    procedure RestoreDefault; safecall;
    // 通过Ini对象加载
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // 是不是启用
    function GetUse: boolean; safecall;
    // 设置是不是启用
    procedure SetUse(AUse: Boolean); safecall;
    // 代理 IP
    function GetIP: WideString; safecall;
    // 代理 IP
    procedure SetIP(AIP: WideString); safecall;
    // 端口号
    function GetPort: Integer; safecall;
    // 端口号
    procedure SetPort(APort: Integer); safecall;
    // 用户名
    function GetUserName: WideString; safecall;
    // 用户名
    procedure SetUserName(AUserName: WideString); safecall;
    // 密码
    function GetPassword: WideString; safecall;
    // 密码
    procedure SetPassword(APassword: WideString); safecall;
    // 是不是设置域名
    function GetNTLM: Boolean; safecall;
    // 是不是设置域名
    procedure SetNTLM(ANTLM: Boolean); safecall;
    // 域名
    function GetDomain: WideString; safecall;
    // 域名
    procedure SetDomain(ADomain: WideString); safecall;
    // 代理类型
    function GetProxyType: TProxyType; safecall;
    // 代理类型
    procedure SetProxyType(AProxyType: TProxyType); safecall;
    // 获取 ProxyKind
    function GetProxyKindEnum: ProxyKindEnum; safecall;
  end;

implementation

end.
