unit UpdateAppContext;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Application Context Interface
// Author£º      lksoulman
// Date£º        2017-10-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  UpdateInfoPool;

type

  // Update Application Context Interface
  IUpdateAppContext = interface(IInterface)
    ['{059D4F3C-3967-48A3-BE1A-1333ABE156AB}']
    // Get Handle
    function GetHandle: THandle; safecall;
    // Get Application Name
    function GetAppName: string; safecall;
    // Get Application Path
    function GetAppPath: string; safecall;
    // Get Update Path
    function GetUpdatePath: string; safecall;
    // Get BackUp Path
    function GetBackupPath: string; safecall;
    // Get Download Path
    function GetDownloadPath: string; safecall;
    // Get Download Compress Path
    function GetDownCompressPath: string; safecall;
    // Get Download Uncompress Path
    function GetDownUncompressPath: string; safecall;
    // Get UpdateInfoPool
    function GetUpdateInfoPool: TUpdateInfoPool; safecall;
    // Set Handle
    procedure SetHandle(AHandle: THandle); safecall;
    // Log
    procedure Log(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

end.
