unit UserCachePlugInImpl;

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
  UserCache,
  PlugInImpl,
  AppContext;

type

  // User cache PlugIn
  TUserCachePlugInImpl = class(TPlugInImpl)
  private
    // User cache interface
    FUserCache: IUserCache;
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
  UserCacheImpl;

{ TUserCachePlugInImpl }

constructor TUserCachePlugInImpl.Create;
begin
  inherited;
  FUserCache := TUserCacheImpl.Create as IUserCache;
end;

destructor TUserCachePlugInImpl.Destroy;
begin
  FUserCache := nil;
  inherited;
end;

procedure TUserCachePlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FUserCache as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IUserCache, FUserCache);
end;

procedure TUserCachePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IUserCache);
  (FUserCache as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TUserCachePlugInImpl.SyncBlockExecute;
begin
  if FUserCache = nil then Exit;

  (FUserCache as ISyncAsync).SyncBlockExecute;
end;

procedure TUserCachePlugInImpl.AsyncNoBlockExecute;
begin
  if FUserCache = nil then Exit;

  (FUserCache as ISyncAsync).AsyncNoBlockExecute;
end;

function TUserCachePlugInImpl.Dependences: WideString;
begin
  if FUserCache = nil then Exit;

  (FUserCache as ISyncAsync).Dependences;
end;

end.
