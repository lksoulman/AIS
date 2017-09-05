unit DownloadMgrPlugInImpl;

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
  DownloadMgr;

type

  TDownloadMgrPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 登录窗口接口
    FDownloadMgr: IDownloadMgr;
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
  DownloadMgrImpl;

{ TDownloadMgrPlugInImpl }

constructor TDownloadMgrPlugInImpl.Create;
begin
  inherited;
  FDownloadMgr := TDownloadMgrImpl.Create as IDownloadMgr;

end;

destructor TDownloadMgrPlugInImpl.Destroy;
begin

  FDownloadMgr := nil;
  inherited;
end;

procedure TDownloadMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FDownloadMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IDownloadMgr, FDownloadMgr);
end;

procedure TDownloadMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IDownloadMgr);
  (FDownloadMgr as ISyncAsync).UnInitialize;

  FAppContext := nil;
end;

procedure TDownloadMgrPlugInImpl.SyncBlockExecute;
begin
  if FDownloadMgr = nil then Exit;

  (FDownloadMgr as ISyncAsync).SyncBlockExecute;
end;

procedure TDownloadMgrPlugInImpl.AsyncNoBlockExecute;
begin
  if FDownloadMgr = nil then Exit;

  (FDownloadMgr as ISyncAsync).AsyncNoBlockExecute;
end;

function TDownloadMgrPlugInImpl.Dependences: WideString;
begin
  Result := (FDownloadMgr as ISyncAsync).Dependences;
end;

end.
