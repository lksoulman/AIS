unit QuoteCodeInfosEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-27
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // CodeInfo �ӿ�
  IQuoteCodeInfosEx = Interface
    ['{A7EE98C5-CFD6-4D54-BC8E-94508567DAD4}']
    // ��ȡ����
    function GetCount: Integer; safecall;
    // ��ȡ CodeInfo
    function GetCodeInfo(AIndex: Integer): Int64; safecall;
    // ��ȡ InnerCode
    function GetInnerCode(AIndex: Integer): Integer; safecall;
  end;

implementation

end.
