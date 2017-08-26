unit CommandMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-6
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Command,
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  AppContext,
  CommandMgr,
  CommandPerm,
  PermissionMgr,
  CommonRefCounter,
  Generics.Collections,
  CommandRegisterClassMgr;

type

  // 命令管理
  TCommandMgrImpl = class(TAutoInterfacedObject, ISyncAsync, ICommandMgr)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 权限管理接口
    FPermissionMgr: IPermissionMgr;
    // 命令已创建的命令
    FCommandDic: TDictionary<Integer, ICommand>;
    // 命令注册类管理
    FCommandRegisterClassMgr: ICommandRegisterClassMgr;
  protected
  public
    // 构造函数
    constructor Create; override;
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

    { ICommandMgr }

    // 命令执行方法
    procedure ExecCommand(ACommandID: Integer; ACommandParams: string); safecall;
  end;

implementation

uses
  CommandImpl;

{ TCommandMgrImpl }

constructor TCommandMgrImpl.Create;
begin
  inherited;
  FCommandDic := TDictionary<Integer, ICommand>.Create;
  FCommandRegisterClassMgr := G_CommandRegisterClassMgr;
end;

destructor TCommandMgrImpl.Destroy;
begin
  FCommandRegisterClassMgr := nil;
  FCommandDic.Free;
  inherited;
end;

procedure TCommandMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FPermissionMgr := FAppContext.GetPermissionMgr as IPermissionMgr;
end;

procedure TCommandMgrImpl.UnInitialize;
begin
  FPermissionMgr := nil;
  FAppContext := nil;
end;

function TCommandMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TCommandMgrImpl.SyncExecute;
begin

end;

procedure TCommandMgrImpl.AsyncExecute;
begin

end;

procedure TCommandMgrImpl.ExecCommand(ACommandID: Integer; ACommandParams: string);
var
  LCommand: ICommand;
  LCommandPerm: TCommandPerm;
begin
  if FCommandDic.TryGetValue(ACommandID, LCommand)
    and (LCommand <> nil) then begin


  end else begin
    if FCommandRegisterClassMgr.GetCommandClassByID(ACommandID,
      LCommandPerm) then begin
      if FPermissionMgr <> nil then begin
        if FPermissionMgr.IsHasPermission(LCommandPerm.PermNo) then begin
          LCommand := LCommandPerm.CommandClass.Create(LCommandPerm.CommandID,
            LCommandPerm.PermNo) as ICommand;
          LCommand.Initialize(FAppContext);
        end else begin

        end;
      end;
    end else begin

    end;
  end;
end;

end.
