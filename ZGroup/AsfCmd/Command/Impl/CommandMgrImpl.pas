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
  AppContext,
  CommandMgr,
  CommandPerm,
  PermissionMgr,
  SyncAsyncImpl,
  CommonRefCounter,
  Generics.Collections,
  CommandRegisterClassMgr;

type

  // 命令管理
  TCommandMgrImpl = class(TSyncAsyncImpl, ICommandMgr)
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
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;

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
  inherited Initialize(AContext);
  FPermissionMgr := FAppContext.GetPermissionMgr as IPermissionMgr;
end;

procedure TCommandMgrImpl.UnInitialize;
begin
  FPermissionMgr := nil;
  inherited UnInitialize;
end;

procedure TCommandMgrImpl.SyncBlockExecute;
begin

end;

procedure TCommandMgrImpl.AsyncNoBlockExecute;
begin

end;

function TCommandMgrImpl.Dependences: WideString;
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
