unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Export AsfCmd Factory Interface
// Author��      lksoulman
// Date��        2017-8-29
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

  // Get factory funciton
  function GetWFactory: IInterface; stdcall;

exports

  GetWFactory            name 'GetWFactory';

implementation

uses
  FactoryAsfCmdImpl;

  // Get factory funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;

end.
