unit HqCoreMgrPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
// Author£º      lksoulman
// Date£º        2017-8-32
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HqCoreMgr,
  PlugInImpl,
  AppContext;

type

  // Hq Authority
  THqCoreMgrPlugInImpl = class(TPlugInImpl)
  private
    // Hq core manager interface
    FHqCoreMgr: IHqCoreMgr;
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
  HqCoreMgrImpl;

{ THqCoreMgrPlugInImpl }

constructor THqCoreMgrPlugInImpl.Create;
begin
  inherited;
  FHqCoreMgr := THqCoreMgrImpl.Create as IHqCoreMgr;
end;

destructor THqCoreMgrPlugInImpl.Destroy;
begin
  FHqCoreMgr := nil;
  inherited;
end;

procedure THqCoreMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FHqCoreMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IHqCoreMgr, FHqCoreMgr);
end;

procedure THqCoreMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IHqCoreMgr);
  (FHqCoreMgr as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure THqCoreMgrPlugInImpl.SyncBlockExecute;
begin
  if FHqCoreMgr = nil then Exit;

  (FHqCoreMgr as ISyncAsync).SyncBlockExecute;
end;

procedure THqCoreMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FHqCoreMgr = nil then Exit;

  (FHqCoreMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function THqCoreMgrPlugInImpl.Dependences: WideString;
begin
  Result := (FHqCoreMgr as ISyncAsync).Dependences;
end;

end.
