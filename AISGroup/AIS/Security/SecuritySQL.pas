unit SecuritySQL;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-23
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

const

  SQL_SECUMAIN = 'SELECT NBBM as InnerCode, '
               + '        GPDM as SecuCode, '
               + '                  Suffix, '
               + '        ZQJC as SecuAbbr, '
               + '       PYDM as SecuSpell, '
               + '      ZQSC as SecuMarket, '
               + '     SSZT as ListedState, '
               + '   oZQLB as SecuCategory, '
               + 'FormerName as FormerAbbr, '
               + 'FormerNameCode as FormerSpell, '
               + ' targetCategory as Margin, '
               + '           ggt as Through  '
               + ' FROM ZQZB';

implementation

end.
