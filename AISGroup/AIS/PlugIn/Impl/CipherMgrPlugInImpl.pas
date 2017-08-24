unit CipherMgrPlugInImpl;

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
  CipherMgr,
  PlugInImpl,
  AppContext;

type

  TCipherMgrPlugInImpl = class(TPlugInImpl)
  private
    // 加密解密接口
    FCipherMgr: ICipherMgr;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IPlugIn }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); override;
    // 释放不需要的资源
    procedure UnInitialize; override;
    // 是不是需要同步加载操作
    function IsNeedSync: WordBool; override;
    // 同步实现
    procedure SyncExecuteOperate; override;
    // 异步实现操作
    procedure AsyncExecuteOperate; override;
  end;

implementation

uses
  SyncAsync,
  CipherMgrImpl;

{ TCipherMgrPlugInImpl }

constructor TCipherMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TCipherMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TCipherMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FCipherMgr := TCipherMgrImpl.Create as ICipherMgr;
  (FCipherMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICipherMgr, FCipherMgr);
end;

procedure TCipherMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICipherMgr);
  (FCipherMgr as ISyncAsync).UnInitialize;
  FCipherMgr := nil;
  FAppContext := nil;
end;

function TCipherMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FCipherMgr = nil then Exit;

  Result := (FCipherMgr as ISyncAsync).IsNeedSync;
end;

procedure TCipherMgrPlugInImpl.SyncExecuteOperate;
begin
  if FCipherMgr = nil then Exit;

  (FCipherMgr as ISyncAsync).SyncExecute;
end;

procedure TCipherMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FCipherMgr = nil then Exit;

  (FCipherMgr as ISyncAsync).AsyncExecute;
end;

end.
