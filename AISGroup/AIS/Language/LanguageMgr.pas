unit LanguageMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-21
// Comments£º
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
    // ÇÐ»»ÓïÑÔ°ü
    procedure ChangeLanguage; safecall;
  end;

implementation

end.
