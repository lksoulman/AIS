unit WebInfo;

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
  UrlInfo,
  Windows,
  Classes,
  SysUtils;

type


  // 用户信息接口
  IWebInfo = Interface(IInterface)
    ['{2BEFE464-BC6A-4C8A-A2F3-610EFBD3AE4B}']
    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 加载数据
    procedure LoadXmlNodes(ANodeList: TList); safecall;
    // 获取 url
    function GetUrl(AWebID: Integer): WideString; safecall;
    // 获取 UrlInfo
    function GetUrlInfo(AWebID: Integer): IUrlInfo; safecall;
  end;

implementation

end.
