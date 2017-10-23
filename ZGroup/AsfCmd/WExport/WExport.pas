unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Export AsfCmd Factory Interface
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º
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
