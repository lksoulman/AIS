unit SecurityMgrPlugInImpl;

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
  SecurityMgr;

type

  // 实现主表基础数据插件
  TSecurityMgrPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 证券数据接口
    FSecurityMgr: ISecurityMgr;
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
  SecurityMgrImpl;

{ TSecurityMgrPlugInImpl }

constructor TSecurityMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TSecurityMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TSecurityMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FSecurityMgr := TSecurityMgrImpl.Create as ISecurityMgr;
  (FSecurityMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ISecurityMgr, FSecurityMgr);
end;

procedure TSecurityMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ISecurityMgr);
  (FSecurityMgr as ISyncAsync).UnInitialize;
  FSecurityMgr := nil;
  FAppContext := nil;
end;

procedure TSecurityMgrPlugInImpl.SyncBlockExecute;
begin
  if FSecurityMgr = nil then Exit;

  (FSecurityMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TSecurityMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FSecurityMgr = nil then Exit;

  (FSecurityMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function TSecurityMgrPlugInImpl.Dependences: WideString;
begin
  Result := (FSecurityMgr as ISyncAsync).Dependences;
end;

end.
