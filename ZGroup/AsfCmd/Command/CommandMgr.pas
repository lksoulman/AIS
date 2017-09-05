unit CommandMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£∫
// Author£∫      lksoulman
// Date£∫        2017-8-6
// Comments£∫
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  ICommandMgr = Interface(IInterface)
    ['{A9E3235B-AA29-4812-BD9B-6FCCE303488A}']
    // √¸¡Ó÷¥––∑Ω∑®
    procedure ExecCommand(ACommandID: Integer; ACommandParams: string); safecall;
  end;

implementation

end.
