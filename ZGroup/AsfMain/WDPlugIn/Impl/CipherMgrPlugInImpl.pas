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
  protected
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { IPlugIn }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // Releasing resources(only execute once)
    procedure UnInitialize; virtual; safecall;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; virtual; safecall;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; virtual; safecall;
    // Get dependency
    function Dependences: WideString; virtual; safecall;
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
