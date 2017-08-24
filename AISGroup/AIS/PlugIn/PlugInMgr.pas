unit PlugInMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-16
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugIn,
  AppContext,
  PlugInImpl,
  ExecutorThread,
  Generics.Collections;

type

  TPlugInMgr = class
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 插件接口
    FPlugIns: TList<IPlugIn>;
    // 插件创建类
    FPlugInClazzs: TList<TPlugInImplClass>;
    // 异步执行线程
    FASyncThread: TExecutorThread;
  protected
    // 初始化所有插件
    procedure DoInitializePlugIns;
    // 清空和释放插件
    procedure DoUnInitializePlugIns;
    // 异步执行线程方法
    procedure DoAsyncThreadExecute(AObject: TObject);
  public
    // 构造方法
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 同步执行插件
    procedure SyncExecutePlugIns;
    // 异步执行插件
    procedure AsyncExecutePlugIns;
  end;

implementation

uses
  ConfigPlugInImpl,
  LoginMgrPlugInImpl,
  CipherMgrPlugInImpl,
  MsgServicesPlugInImpl,
  ServiceBasePlugInImpl,
  ServiceAssetPlugInImpl,
  SecuBaseDataPlugInImpl,
  CacheBaseDataPlugInImpl,
  CacheUserDataPlugInImpl,
  PermissionMgrPlugInImpl;

{ TPlugInMgr }

constructor TPlugInMgr.Create;
begin
  inherited;
  FPlugIns := TList<IPlugIn>.Create;
  FASyncThread := TExecutorThread.Create;
  FPlugInClazzs := TList<TPlugInImplClass>.Create;

  FPlugInClazzs.Add(TCipherMgrPlugInImpl);
  FPlugInClazzs.Add(TConfigPlugInImpl);
  FPlugInClazzs.Add(TServiceBasePlugInImpl);
  FPlugInClazzs.Add(TServiceAssetPlugInImpl);
  FPlugInClazzs.Add(TLoginMgrPlugInImpl);
  FPlugInClazzs.Add(TPermissionMgrPlugInImpl);
  FPlugInClazzs.Add(TCacheBaseDataPlugInImpl);
  FPlugInClazzs.Add(TCacheUserDataPlugInImpl);
end;

destructor TPlugInMgr.Destroy;
begin
  FPlugInClazzs.Free;
  FPlugIns.Free;
  inherited;
end;

procedure TPlugInMgr.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  DoInitializePlugIns;
end;

procedure TPlugInMgr.UnInitialize;
begin
  DoUnInitializePlugIns;
  FAppContext := nil;
end;

procedure TPlugInMgr.DoInitializePlugIns;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FPlugInClazzs.Count - 1 do begin
    FPlugIns.Add(FPlugInClazzs[LIndex].Create as IPlugIn);
    FPlugIns.Items[LIndex].Initialize(FAppContext);
  end;

  for LIndex := 0 to FPlugInClazzs.Count - 1 do begin
    if FPlugIns.Items[LIndex].IsNeedSync then begin
      FPlugIns.Items[LIndex].SyncExecuteOperate;
    end;
  end;
end;

procedure TPlugInMgr.DoUnInitializePlugIns;
var
  LIndex: Integer;
  LPlugIn: IPlugIn;
begin
  for LIndex := FPlugIns.Count - 1 downto 0 do begin
    LPlugIn := FPlugIns.Items[LIndex];
    if LPlugIn <> nil then begin
      FPlugIns.Items[LIndex] := nil;
      LPlugIn.UnInitialize;
      LPlugIn := nil;
    end;
  end;
  FPlugIns.Clear;
end;

procedure TPlugInMgr.SyncExecutePlugIns;
begin

end;

procedure TPlugInMgr.AsyncExecutePlugIns;
begin

end;

procedure TPlugInMgr.DoAsyncThreadExecute(AObject: TObject);
begin

end;

end.
