unit LanguageMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-21
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  ILanguageMgr = Interface(IInterface)
    ['{4A7236FF-F625-4DDA-B1DC-C57605419114}']
    // �л����԰�
    procedure ChangeLanguage; safecall;
  end;

implementation

end.
