unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Export function
// Author��      lksoulman
// Date��        2017-8-31
// Comments��    AsfHqCore project export function.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  SysUtils;

  // Get factory funciton
  function GetWFactory: IInterface; stdcall;

exports

  GetWFactory           name 'GetWFactory';

implementation

uses
  FactoryAsfHqCoreImpl;

  // Get factory interface funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;

end.