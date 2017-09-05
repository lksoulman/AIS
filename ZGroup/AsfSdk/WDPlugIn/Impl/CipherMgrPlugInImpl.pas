unit CipherMgrPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CipherMgr,
  PlugInImpl,
  AppContext;

type

  // CipherMgr PlugIn implementation
  TCipherMgrPlugInImpl = class(TPlugInImpl)
  private
    // Encryption and decryption management interface
    FCipherMgr: ICipherMgr;
  protected
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { IPlugIn }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Get dependency
    function Dependences: WideString; override;

    property CipherMgr: ICipherMgr read FCipherMgr;
  end;

implementation

uses
  SyncAsync,
  CipherMgrImpl;

{ TCipherMgrPlugInImpl }

constructor TCipherMgrPlugInImpl.Create;
begin
  inherited Create;
  FCipherMgr := TCipherMgrImpl.Create as ICipherMgr;

end;

destructor TCipherMgrPlugInImpl.Destroy;
begin

  FCipherMgr := nil;
  inherited;
end;

procedure TCipherMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FCipherMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICipherMgr, FCipherMgr);
end;

procedure TCipherMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICipherMgr);
  (FCipherMgr as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TCipherMgrPlugInImpl.SyncBlockExecute;
begin
  if FCipherMgr = nil then Exit;

  (FCipherMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TCipherMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FCipherMgr = nil then Exit;

  (FCipherMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function TCipherMgrPlugInImpl.Dependences: WideString;
begin
  Result := '';
  if FCipherMgr = nil then Exit;

  Result := (FCipherMgr as ISyncAsync).Dependences;
end;

end.
