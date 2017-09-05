unit WFactory;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Factory Interface
// Author��      lksoulman
// Date��        2017-8-29
// Comments��    A dynamic library has only one factory��
//               A factory class is a singleton.
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Factory Interface
  IWFactory = Interface(IInterface)
    ['{CFA161C6-0B19-4C7F-A7B8-9FF027D7DB26}']
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface); safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; safecall;
    // Get PlugIn
    function GetPlugInById(APlugInId: Integer): IInterface; safecall;
    // Create interface
    function CreatePlugInById(APlugInId: Integer): IInterface; safecall;
  end;

implementation

end.
