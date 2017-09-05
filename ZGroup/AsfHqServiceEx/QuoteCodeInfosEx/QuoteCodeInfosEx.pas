unit QuoteCodeInfosEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-27
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // CodeInfo 接口
  IQuoteCodeInfosEx = Interface
    ['{A7EE98C5-CFD6-4D54-BC8E-94508567DAD4}']
    // 获取个数
    function GetCount: Integer; safecall;
    // 获取 CodeInfo
    function GetCodeInfo(AIndex: Integer): Int64; safecall;
    // 获取 InnerCode
    function GetInnerCode(AIndex: Integer): Integer; safecall;
  end;

implementation

end.
