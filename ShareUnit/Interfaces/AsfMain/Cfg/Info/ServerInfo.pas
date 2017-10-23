unit ServerInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Server Info Interface
// Author£º      lksoulman
// Date£º        2017-7-21
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  // Server Info Interface
  IServerInfo = Interface(IInterface)
    ['{2BE2468A-C419-4BCB-9905-4B8CF5509689}']
    // Init
    procedure Initialize(AContext: IInterface); safecall;
    // Un Init
    procedure UnInitialize; safecall;
    // Save Cache
    procedure SaveCache; safecall;
    // Load File
    procedure LoadFile(AFile: TIniFile); safecall;
    // Next
    procedure NextServer; safecall;
    // First
    procedure FirstServer; safecall;
    // Is EOF
    function IsEOF: boolean; safecall;
    // Get Server Index
    function GetServerIndex: Integer; safecall;
    // Get Server Url
    function GetServerUrl: WideString; safecall;
    // Get Server Urls
    function GetServerUrls: WideString; safecall;
    // Get Server Name
    function GetServerName: WideString; safecall;
  end;

implementation

end.
