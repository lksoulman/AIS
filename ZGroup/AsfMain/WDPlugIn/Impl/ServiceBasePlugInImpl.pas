unit ServiceBasePlugInImpl;

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
  ServiceBase;

type

  // 资产GF数据服务插件
  TServiceBasePlugInImpl = class(TPlugInImpl)
  private
    // 资产服务接口
    FServiceBase: IServiceBase;
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
  ServiceBaseImpl;

{ TServiceBasePlugInImpl }

constructor TServiceBasePlugInImpl.Create;
begin
  inherited;
  FServiceBase := TServiceBaseImpl.Create as IServiceBase;
end;

destructor TServiceBasePlugInImpl.Destroy;
begin
  FServiceBase := nil;
  inherited;
end;

procedure TServiceBasePlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FServiceBase as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IServiceBase, FServiceBase);
end;

procedure TServiceBasePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IServiceBase);
  (FServiceBase as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TServiceBasePlugInImpl.SyncBlockExecute;
begin

end;

procedure TServiceBasePlugInImpl.AsyncNoBlockExecute;
begin

end;

function TServiceBasePlugInImpl.Dependences: WideString;
begin

end;

end.
