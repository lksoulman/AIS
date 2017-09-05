unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Export function
// Author£º      lksoulman
// Date£º        2017-8-31
// Comments£º    AsfCache project export function.
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
  FactoryAsfCacheImpl;

  // Get factory interface funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;

end.
