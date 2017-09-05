unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfLanguage export function
// Author£º      lksoulman
// Date£º        2017-8-21
// Comments£º
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
  FactoryAsfLanguageImpl;

  // Get factory interface funciton
  function GetWFactory: IInterface;
  begin
    Result := G_WFactory;
  end;

end.

