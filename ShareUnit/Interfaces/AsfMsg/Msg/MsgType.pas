unit MsgType;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message Type
// Author£º      lksoulman
// Date£º        2017-7-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Message Type
  TMsgType = (mtNone,                       //
              mtSecuMainUpdate,             // SecuMain Table
              mtSecuMainMemUpdate,             // SecuMain Table
              mtSecurityDataUpdate,         // Security Data Update
              mtUserSectorDataUpdate        // User Sector Data Update
              );

  // Message Type Dynamic Array
  TMsgTypeDynArray = Array Of TMsgType;

implementation

end.
