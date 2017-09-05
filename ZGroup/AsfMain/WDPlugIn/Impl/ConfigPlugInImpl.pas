unit ConfigPlugInImpl;

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
  Config,
  PlugInImpl,
  AppContext;

type

  // Config Inteface ²å¼þ
  TConfigPlugInImpl = class(TPlugInImpl)
  private
    // Config Inteface
    FConfig: IConfig;
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
  end;

implementation

uses
  SyncAsync,
  ConfigImpl;

{ TConfigPlugInImpl }

constructor TConfigPlugInImpl.Create;
begin
  inherited;
  FConfig := TConfigImpl.Create as IConfig;
end;

destructor TConfigPlugInImpl.Destroy;
begin
  FConfig := nil;
  inherited;
end;

procedure TConfigPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  (FConfig as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IConfig, FConfig);
end;

procedure TConfigPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IConfig);
  (FConfig as ISyncAsync).UnInitialize;
  inherited UnInitialize;
end;

procedure TConfigPlugInImpl.SyncBlockExecute;
begin
  if FConfig = nil then Exit;
  
  (FConfig as ISyncAsync).SyncBlockExecute;
end;

procedure TConfigPlugInImpl.AsyncNoBlockExecute;
begin
  if FConfig = nil then Exit;

  (FConfig as ISyncAsync).AsyncNoBlockExecute;
end;

end.
