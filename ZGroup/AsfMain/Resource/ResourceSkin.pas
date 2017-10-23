unit ResourceSkin;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Resource Skin Interface
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Graphics;

type

  // Resource Skin Interface
  IResourceSkin = interface(IInterface)
    ['{9BB7760F-2A08-4D6F-A021-73E2C27B4AC8}']
    // Init
    procedure Initialize(AContext: IInterface);
    // Un Init
    procedure UnInitialize;
    // Change Skin
    function ChangeSkin: Boolean;
    // Get Instance
    function GetInstance: HMODULE;
    // Get Color
    function GetColor(AKey: string): TColor;
    // Get Color String
    function GetColorString(AKey: string): string;
    // Get Stream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

end.
