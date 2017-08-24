unit SecuUpdate;

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
  SysUtils;

type

  // 证券信息修改接口
  ISecuUpdate = Interface(IInterface)
    ['{EEBD75BE-39CF-4DBB-B3B3-4719A3E4B867}']
    // 更新数据
    procedure UpdateSecurityData; safecall;
    // 设置内码
    procedure SetInnerCode(AInnerCode: Integer); safecall;
    // 设置证券代码
    procedure SetSecuCode(ASecuCode: string); safecall;
    // 设置代码证券后缀
    procedure SetSuffic(ASuffix: string); safecall;
    // 设置证券简称
    procedure SetSecuAbbr(ASecuAbbr: string); safecall;
    // 设置证券拼音
    procedure SetSecuSpell(ASecuSpell: string); safecall;
    // 设置证券曾用名简称
    procedure SetFormerAbbr(AFormerAbbr: string); safecall;
    // 设置证券曾用名拼音
    procedure SetFormerSpell(AFormerSpell: string); safecall;
    // 设置证券市场
    procedure SetSecuMarket(ASecuMarket: Byte); safecall;
    // 设置上市状态
    procedure SetListedState(AListedState: Byte); safecall;
    // 设置证券类型
    procedure SetSecuCategory(ASecuCategory: Byte); safecall;
    // 设置融资融券、通类型
    procedure SetSecuCategoryI(ASecuCategoryI: Byte); safecall;
  end;

implementation

end.
