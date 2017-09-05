unit HqAuthPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-30
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  HqAuth,
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext;

type

  // Hq Authority
  THqAuthPlugInImpl = class(TPlugInImpl)
  private
    // 权限管理接口
    FHqAuth: IHqAuth;
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
  HqAuthImpl;

{ THqAuthPlugInImpl }

constructor THqAuthPlugInImpl.Create;
begin
  inherited;
  FHqAuth := THqAuthImpl.Create as IHqAuth;
end;

destructor THqAuthPlugInImpl.Destroy;
begin
  FHqAuth := nil;
  inherited;
end;

procedure THqAuthPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FHqAuth as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IHqAuth, FHqAuth);
end;

procedure THqAuthPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IHqAuth);
  (FHqAuth as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure THqAuthPlugInImpl.SyncBlockExecute;
begin
  if FHqAuth = nil then Exit;

  (FHqAuth as ISyncAsync).SyncBlockExecute;
end;

procedure THqAuthPlugInImpl.AsyncNoBlockExecute;
begin
  if FHqAuth = nil then Exit;

  (FHqAuth as ISyncAsync).AsyncNoBlockExecute;
end;

function THqAuthPlugInImpl.Dependences: WideString;
begin
  Result := (FHqAuth as ISyncAsync).Dependences;
end;

end.
