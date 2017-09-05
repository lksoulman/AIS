unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Export function
// Author£º      lksoulman
// Date£º        2017-8-31
// Comments£º    AsfAuth project export function.
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
  FactoryAsfAuthImpl;

  // Get factory interface funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;

end.
