unit ResourceCfg;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Resource Interface
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Resource Cfg Interface
  IResourceCfg = interface(IInterface)
    ['{9BB7760F-2A08-4D6F-A021-73E2C27B4AC8}']
    // Init
    procedure Initialize(AContext: IInterface);
    // Un Init
    procedure UnInitialize;
    // Get Instance
    function GetInstance: HMODULE;
    // Get Stream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

end.
