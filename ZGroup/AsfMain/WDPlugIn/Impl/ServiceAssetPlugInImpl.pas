unit ServiceAssetPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-20
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
  ServiceAsset;

type

  // 资产GF数据服务插件
  TServiceAssetPlugInImpl = class(TPlugInImpl)
  private
    // 资产服务接口
    FServiceAsset: IServiceAsset;
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
  ServiceAssetImpl;

{ TServiceAssetPlugInImpl }

constructor TServiceAssetPlugInImpl.Create;
begin
  inherited;
  FServiceAsset := TServiceAssetImpl.Create as IServiceAsset;
end;

destructor TServiceAssetPlugInImpl.Destroy;
begin
  FServiceAsset := nil;
  inherited;
end;

procedure TServiceAssetPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FServiceAsset as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IServiceAsset, FServiceAsset);
end;

procedure TServiceAssetPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IServiceAsset);
  (FServiceAsset as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TServiceAssetPlugInImpl.SyncBlockExecute;
begin

end;

procedure TServiceAssetPlugInImpl.AsyncNoBlockExecute;
begin

end;

function TServiceAssetPlugInImpl.Dependences: WideString;
begin

end;

end.

