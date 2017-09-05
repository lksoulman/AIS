unit MsgEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message Extend
// Author£º      lksoulman
// Date£º        2017-7-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgType,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter;

type

  // Message Extend
  TMsgEx = class(TAutoObject)
  private
  protected
  public
    // Get Id
    function GetId: UInt; virtual; abstract;
    // Get producer ID
    function GetProId: Integer; virtual; abstract;
    // Get Produce Time
    function GetProTime: TDateTime; virtual; abstract;
    // Get Message Type
    function GetMsgType: TMsgType; virtual; abstract;
    // Get Message Information
    function GetMsgInfo: WideString; virtual; abstract;
    // Get Operate Name
    function GetOperateName: WideString; virtual; abstract;
    // Invoke Operate Execute
    function InvokeOperateExecute: Boolean; virtual; abstract;
  end;

implementation

end.
