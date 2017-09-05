unit UserAssetCachePlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º  Base cache PlugIn
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
  UserAssetCache,
  PlugInImpl,
  AppContext;

type

  // User cache PlugIn
  TUserAssetCachePlugInImpl = class(TPlugInImpl)
  private
    // User cache interface
    FUserAssetCache: IUserAssetCache;
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
  end;

implementation

uses
  SyncAsync,
  UserAssetCacheImpl;

{ TUserAssetCachePlugInImpl }

constructor TUserAssetCachePlugInImpl.Create;
begin
  inherited;
  FUserAssetCache := TUserAssetCacheImpl.Create as IUserAssetCache;
end;

destructor TUserAssetCachePlugInImpl.Destroy;
begin
  FUserAssetCache := nil;
  inherited;
end;

procedure TUserAssetCachePlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FUserAssetCache as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IUserAssetCache, FUserAssetCache);
end;

procedure TUserAssetCachePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IUserAssetCache);
  (FUserAssetCache as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TUserAssetCachePlugInImpl.SyncBlockExecute;
begin
  if FUserAssetCache = nil then Exit;

  (FUserAssetCache as ISyncAsync).SyncBlockExecute;
end;

procedure TUserAssetCachePlugInImpl.AsyncNoBlockExecute;
begin
  if FUserAssetCache = nil then Exit;

  (FUserAssetCache as ISyncAsync).AsyncNoBlockExecute;
end;

function TUserAssetCachePlugInImpl.Dependences: WideString;
begin
  if FUserAssetCache = nil then Exit;

  (FUserAssetCache as ISyncAsync).Dependences;
end;

end.
