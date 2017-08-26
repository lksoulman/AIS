unit CommandMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-6
// Comments��
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

  // �������
  TCommandMgrImpl = class(TAutoInterfacedObject, ISyncAsync, ICommandMgr)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // Ȩ�޹���ӿ�
    FPermissionMgr: IPermissionMgr;
    // �����Ѵ���������
    FCommandDic: TDictionary<Integer, ICommand>;
    // ����ע�������
    FCommandRegisterClassMgr: ICommandRegisterClassMgr;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { ISyncAsync }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; safecall;
    // ͬ��ִ�з���
    procedure SyncExecute; safecall;
    // �첽ִ�з���
    procedure AsyncExecute; safecall;

    { ICommandMgr }

    // ����ִ�з���
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
