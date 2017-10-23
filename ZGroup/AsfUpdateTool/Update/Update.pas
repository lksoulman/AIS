unit Update;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Interface
// Author£º      lksoulman
// Date£º        2017-10-12
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Update Interface
  IUpdate = interface(IInterface)
    ['{72ABCA73-EEDF-446A-97CE-BB41B7FB485E}']
    // Backup
    procedure Backup; safecall;
    // UpgradeFile
    procedure UpgradeFile; safecall;
    // Generate Need Update List
    procedure GenerateNeedUpdateList; safecall;
    // Compress Server Update List
    procedure CompressServerUpdateList; safecall;
    // Generate Server Update List
    procedure GenerateServerUpdateList; safecall;
    // Uncompress Server Update List
    procedure UncompresServerUpdateList; safecall;
    // Set Handle
    procedure SetHandle(AHandle: THandle); safecall;
  end;

implementation

end.
