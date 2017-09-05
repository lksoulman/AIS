unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Export function
// Author£º      lksoulman
// Date£º        2017-9-1
// Comments£º    AsfAUI project export function.
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
  FactoryAsfAUIImpl;

  // Get factory interface funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;

end.
