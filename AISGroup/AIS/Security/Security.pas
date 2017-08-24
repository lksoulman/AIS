unit Security;

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
  SecurityType;

type

  // 证券信息接口
  ISecurity = Interface(IInterface)
    ['{8008149C-3763-4996-A849-828A7DA5A043}']
    // 获取证券内部编码
    function GetInnerCode: Integer; safecall;
    // 获取证券代码
    function GetSecuCode: WideString; safecall;
    // 获取证券后缀
    function GetSuffix: WideString; safecall;
    // 获取证券市场
    function GetSecuMarket: Integer; safecall;
    // 获取证券证券类别
    function GetSecuCategory: Integer; safecall;
    // 获取证券简称
    function GetSecuAbbr: WideString; safecall;
    // 获取证券拼音
    function GetSecuSpell: WideString; safecall;
    // 获取曾用名简称
    function GetFormerAbbr: WideString; safecall;
    // 获取曾用名拼音
    function GetFormerSpell: WideString; safecall;
    // 证券类型
    function GetSecurityType: TSecurityType; safecall;
    // 上市状态
    function GetListedStateType: TListedStateType; safecall;
    // 融资融券类型
    function GetSecuMarginType: TMarginType; safecall;
    // 通类型
    function GetSecuThroughType: TThroughType; safecall;
  end;

  TSecuritys = array of ISecurity;

implementation

end.
