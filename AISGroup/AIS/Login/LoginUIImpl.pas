unit LoginUIImpl;

interface

uses
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  LoginUI,
  AppContext,
  LoginMainUI;

type

  TLoginUIImpl = class(TInterfacedObject, ISyncAsync, ILoginUI)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 登录主窗口
    FLoginMainUI: TLoginMainUI;
  protected

  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;

    { ISyncAsync }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; safecall;
    // 同步执行方法
    procedure SyncExecute; safecall;
    // 异步执行方法
    procedure AsyncExecute; safecall;

    { ILoginUI }

    // 展示登录主窗口
    procedure ShowLoginMainUI; safecall;
    // 展示绑定窗口
    procedure ShowLoginBindUI; safecall;
    // 展示登录信息
    procedure ShowLoginInfo(AMsg: WideString); safecall;
    // 设置登录回调方法
    procedure SetLoginFunc(ALoginFunc: TCallBackLoginFunc); safecall;
  end;

implementation

{ TLoginUIImpl }

constructor TLoginUIImpl.Create;
begin
  inherited;
  FLoginMainUI := TLoginMainUI.Create(nil);
end;

destructor TLoginUIImpl.Destroy;
begin
  FLoginMainUI.Free;
  inherited;
end;

procedure TLoginUIImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FLoginMainUI.Initialize(FAppContext);
end;

procedure TLoginUIImpl.UnInitialize;
begin
  FLoginMainUI.UnInitialize;
  FAppContext := nil;
end;

function TLoginUIImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TLoginUIImpl.SyncExecute;
begin
  ShowLoginMainUI;
end;

procedure TLoginUIImpl.AsyncExecute;
begin

end;

procedure TLoginUIImpl.ShowLoginMainUI;
begin
  FLoginMainUI.ShowLogin;
end;

procedure TLoginUIImpl.ShowLoginBindUI;
begin
  FLoginMainUI.ShowLoginBindUI(True);
end;

procedure TLoginUIImpl.ShowLoginInfo(AMsg: WideString);
begin
  FLoginMainUI.ShowLoginInfo(AMsg);
end;

procedure TLoginUIImpl.SetLoginFunc(ALoginFunc: TCallBackLoginFunc);
begin
  FLoginMainUI.SetLoginFunc(ALoginFunc);
end;

end.
