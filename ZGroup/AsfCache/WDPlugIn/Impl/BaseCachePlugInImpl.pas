unit BaseCachePlugInImpl;

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
  BaseCache,
  PlugInImpl,
  AppContext;

type

  // Base Cache PlugIn
  TBaseCachePlugInImpl = class(TPlugInImpl)
  private
    // Base Cache interface
    FBaseCache: IBaseCache;
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
  BaseCacheImpl;

{ TBaseCachePlugInImpl }

constructor TBaseCachePlugInImpl.Create;
begin
  inherited;
  FBaseCache := TBaseCacheImpl.Create as IBaseCache;
end;

destructor TBaseCachePlugInImpl.Destroy;
begin
  FBaseCache := nil;
  inherited;
end;

procedure TBaseCachePlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FBaseCache as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IBaseCache, FBaseCache);
end;

procedure TBaseCachePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IBaseCache);
  (FBaseCache as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TBaseCachePlugInImpl.SyncBlockExecute;
begin
  if FBaseCache = nil then Exit;

  (FBaseCache as ISyncAsync).SyncBlockExecute;
end;

procedure TBaseCachePlugInImpl.AsyncNoBlockExecute;
begin
  if FBaseCache = nil then Exit;

  (FBaseCache as ISyncAsync).AsyncNoBlockExecute;
end;

function TBaseCachePlugInImpl.Dependences: WideString;
begin
  if FBaseCache = nil then Exit;

  (FBaseCache as ISyncAsync).Dependences;
end;

end.
