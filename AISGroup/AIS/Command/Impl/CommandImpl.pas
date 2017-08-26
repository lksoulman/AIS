unit CommandImpl;

interface

uses
  Command,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter;

type

  // 命令接口基类实现
  TCommandImpl = class(TAutoInterfacedObject, ICommand)
  private
  protected
    // 权限掩码
    FPermMask: Integer;
    // 命令 ID
    FCommandID: Integer;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  public
    // 构造函数
    constructor Create(ACommandID, APermMask: Integer); virtual;
    // 析构函数
    destructor Destroy; override;

    { ICommand }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // 释放不需要的资源
    procedure UnInitialize; virtual; safecall;
    // 设置激活
    procedure SetActive; virtual; safecall;
    // 设置非激活
    procedure SetNoActive; virtual; safecall;
    // 命令执行方法
    procedure ExecCommand(APermMask: Integer; AParams: WideString); virtual; safecall;
  end;

  // 命令接口基类类型
  TCommandImplClass = class of TCommandImpl;

implementation

{ TCommandImpl }

constructor TCommandImpl.Create(ACommandID, APermMask: Integer);
begin
  inherited Create;
  FPermMask := APermMask;
  FCommandID := ACommandID;
end;

destructor TCommandImpl.Destroy;
begin

  inherited;
end;

procedure TCommandImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TCommandImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TCommandImpl.SetActive;
begin

end;

procedure TCommandImpl.SetNoActive;
begin

end;

procedure TCommandImpl.ExecCommand(APermMask: Integer; AParams: WideString);
begin

end;

end.
