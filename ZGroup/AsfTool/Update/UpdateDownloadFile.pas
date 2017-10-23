unit UpdateDownloadFile;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Update Download File
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
  UpdateInfo,
  UpdateAppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // Update Download File
  TUpdateDownloadFile = class(TAutoObject)
  private
    // Application Context
    FUpdateAppContext: IUpdateAppContext;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Init
    procedure Initialize(AContext: IUpdateAppContext);
    // UnInit
    procedure UnInitialize(AContext: IUpdateAppContext);
  end;

implementation

{ TUpdateDownloadFile }

constructor TUpdateDownloadFile.Create;
begin
  inherited;

end;

destructor TUpdateDownloadFile.Destroy;
begin

  inherited;
end;

procedure TUpdateDownloadFile.Initialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := AContext;
end;

procedure TUpdateDownloadFile.UnInitialize(AContext: IUpdateAppContext);
begin
  FUpdateAppContext := nil;
end;

end.
