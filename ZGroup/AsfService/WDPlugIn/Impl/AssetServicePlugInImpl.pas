unit AssetServicePlugInImpl;

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
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  AssetService;

type

  // Hq Authority
  TAssetServicePlugInImpl = class(TPlugInImpl)
  private
    // 权限管理接口
    FAssetService: IAssetService;
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
  AssetServiceImpl;

{ TAssetServicePlugInImpl }

constructor TAssetServicePlugInImpl.Create;
begin
  inherited;
  FAssetService := TAssetServiceImpl.Create as IAssetService;
end;

destructor TAssetServicePlugInImpl.Destroy;
begin
  FAssetService := nil;
  inherited;
end;

procedure TAssetServicePlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FAssetService as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IAssetService, FAssetService);
end;

procedure TAssetServicePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IAssetService);
  (FAssetService as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TAssetServicePlugInImpl.SyncBlockExecute;
begin
  if FAssetService = nil then Exit;

  (FAssetService as ISyncAsync).SyncBlockExecute;
end;

procedure TAssetServicePlugInImpl.AsyncNoBlockExecute;
begin
  if FAssetService = nil then Exit;

  (FAssetService as ISyncAsync).AsyncNoBlockExecute;
end;

function TAssetServicePlugInImpl.Dependences: WideString;
begin
  Result := (FAssetService as ISyncAsync).Dependences;
end;

end.
