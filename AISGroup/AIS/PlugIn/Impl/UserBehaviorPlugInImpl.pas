unit UserBehaviorPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-20
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  UserBehavior;

type

  TUserBehaviorPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // �û���Ϊ�ӿ��ϴ��ӿ�
    FUserBehavior: IUserBehavior;
  protected
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { IPlugIn }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); override;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; override;
    // �ǲ�����Ҫͬ�����ز���
    function IsNeedSync: WordBool; override;
    // ͬ��ʵ��
    procedure SyncExecuteOperate; override;
    // �첽ʵ�ֲ���
    procedure AsyncExecuteOperate; override;
  end;

implementation

uses
  SyncAsync,
  UserBehaviorImpl;

{ TUserBehaviorPlugInImpl }

constructor TUserBehaviorPlugInImpl.Create;
begin
  inherited;

end;

destructor TUserBehaviorPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TUserBehaviorPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FUserBehavior := TUserBehaviorImpl.Create as IUserBehavior;
  (FUserBehavior as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IUserBehavior, FUserBehavior);
end;

procedure TUserBehaviorPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IUserBehavior);
  (FUserBehavior as ISyncAsync).UnInitialize;
  FUserBehavior := nil;
  FAppContext := nil;
end;

function TUserBehaviorPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FUserBehavior = nil then Exit;

  Result := (FUserBehavior as ISyncAsync).IsNeedSync;
end;

procedure TUserBehaviorPlugInImpl.SyncExecuteOperate;
begin
  if FUserBehavior = nil then Exit;

  (FUserBehavior as ISyncAsync).SyncExecute;
end;

procedure TUserBehaviorPlugInImpl.AsyncExecuteOperate;
begin
  if FUserBehavior = nil then Exit;

  (FUserBehavior as ISyncAsync).AsyncExecute;
end;

end.
