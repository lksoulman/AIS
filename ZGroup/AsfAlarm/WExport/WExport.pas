unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Export function
// Author��      lksoulman
// Date��        2017-9-8
// Comments��    AsfAlarm project export function.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  SysUtils;

  // Get factory funciton
  function GetWFactory: IInterface; stdcall;

exports

  GetWFactory            name 'GetWFactory';

implementation

uses
  FactoryAsfAlarmImpl;

  // Get factory interface funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;

end.
