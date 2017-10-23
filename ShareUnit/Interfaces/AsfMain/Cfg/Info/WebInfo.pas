unit WebInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Web Info Interface
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


  // Web Info Interface
  IWebInfo = Interface(IInterface)
    ['{2BEFE464-BC6A-4C8A-A2F3-610EFBD3AE4B}']
    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Get Url
    function GetUrl: WideString; safecall;
    // Set Url
    procedure SetUrl(AUrl: WideString); safecall;
    // Get WebID
    function GetWebID: Integer; safecall;
    // Set WebID
    procedure SetWebID(AWebID: Integer); safecall;
    // Get Server Name
    function GetServerName: WideString; safecall;
    // Set Server Name
    procedure SetServerName(AServerName: WideString); safecall;
    // Get Description
    function GetDescription: WideString; safecall;
    // Set Description
    procedure SetDescription(ADescription: WideString); safecall;
  end;

implementation

end.
