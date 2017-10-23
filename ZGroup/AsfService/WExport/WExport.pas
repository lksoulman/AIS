unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Export AsfService Factory Interface
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
  FactoryAsfServiceImpl;

  // Get factory funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;

end.
