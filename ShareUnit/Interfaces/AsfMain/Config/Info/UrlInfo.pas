unit UrlInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  NativeXml;

type


  // 用户信息接口
  IUrlInfo = Interface(IInterface)
    ['{2BEFE464-BC6A-4C8A-A2F3-610EFBD3AE4B}']
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 获取去 url 地址
    function GetUrl: WideString; safecall;
    // 设置 url
    procedure SetUrl(AUrl: WideString); safecall;
    // 获取 webID
    function GetWebID: Integer; safecall;
    // 设置 webID
    procedure SetWebID(AWebID: Integer); safecall;
    // 获取服务器名称
    function GetServerName: WideString; safecall;
    // 设置服务器名称
    procedure SetServerName(AServerName: WideString); safecall;
    // 获取描述
    function GetDescription: WideString; safecall;
    // 设置描述
    procedure SetDescription(ADescription: WideString); safecall;
  end;

implementation

end.
