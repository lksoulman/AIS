unit BasicServicePlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Basic Service PlugIn Implementation
// Author£º      lksoulman
// Date£º        2017-8-30
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  BasicService;

type

  // Basic Service PlugIn Implementation
  TBasicServicePlugInImpl = class(TPlugInImpl)
  private
    // Basic Service
    FBasicService: IBasicService;
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
  BasicServiceImpl;

{ TBasicServicePlugInImpl }

constructor TBasicServicePlugInImpl.Create;
begin
  inherited;
  FBasicService := TBasicServiceImpl.Create as IBasicService;
end;

destructor TBasicServicePlugInImpl.Destroy;
begin
  FBasicService := nil;
  inherited;
end;

procedure TBasicServicePlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FBasicService as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IBasicService, FBasicService);
end;

procedure TBasicServicePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IBasicService);
  (FBasicService as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TBasicServicePlugInImpl.SyncBlockExecute;
begin
  if FBasicService = nil then Exit;

  (FBasicService as ISyncAsync).SyncBlockExecute;
end;

procedure TBasicServicePlugInImpl.AsyncNoBlockExecute;
begin
  if FBasicService = nil then Exit;

  (FBasicService as ISyncAsync).AsyncNoBlockExecute;
end;

function TBasicServicePlugInImpl.Dependences: WideString;
begin
  Result := (FBasicService as ISyncAsync).Dependences;
end;

end.
