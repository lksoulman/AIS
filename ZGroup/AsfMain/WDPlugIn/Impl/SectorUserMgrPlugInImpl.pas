unit SectorUserMgrPlugInImpl;

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
  SectorUserMgr;

type

  // 用户板块管理接口插件
  TSectorUserMgrPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 用户板块管理接口
    FSectorUserMgr: ISectorUserMgr;
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
  SectorUserMgrImpl;

{ TSectorUserMgrPlugInImpl }

constructor TSectorUserMgrPlugInImpl.Create;
begin
  inherited;
  FSectorUserMgr := TSectorUserMgrImpl.Create as ISectorUserMgr;
end;

destructor TSectorUserMgrPlugInImpl.Destroy;
begin
  FSectorUserMgr := nil;
  inherited;
end;

procedure TSectorUserMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FSectorUserMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ISectorUserMgr, FSectorUserMgr);
end;

procedure TSectorUserMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ISectorUserMgr);
  (FSectorUserMgr as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TSectorUserMgrPlugInImpl.SyncBlockExecute;
begin
  if FSectorUserMgr = nil then Exit;

  (FSectorUserMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TSectorUserMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FSectorUserMgr = nil then Exit;

  (FSectorUserMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function TSectorUserMgrPlugInImpl.Dependences: WideString;
begin
  Result := (FSectorUserMgr as ISyncAsync).Dependences;
end;

end.
