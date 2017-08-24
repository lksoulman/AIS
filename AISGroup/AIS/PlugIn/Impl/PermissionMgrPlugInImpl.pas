unit PermissionMgrPlugInImpl;

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
  PermissionMgr;

type

  TPermissionMgrPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // Ȩ�޹���ӿ�
    FPermissionMgr: IPermissionMgr;
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
  PermissionMgrImpl;

{ TPermissionMgrPlugInImpl }

constructor TPermissionMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TPermissionMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TPermissionMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FPermissionMgr := TPermissionMgrImpl.Create as IPermissionMgr;
  (FPermissionMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IPermissionMgr, FPermissionMgr);
end;

procedure TPermissionMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IPermissionMgr);
  (FPermissionMgr as ISyncAsync).UnInitialize;
  FPermissionMgr := nil;
  FAppContext := nil;
end;

function TPermissionMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FPermissionMgr = nil then Exit;

  Result := (FPermissionMgr as ISyncAsync).IsNeedSync;
end;

procedure TPermissionMgrPlugInImpl.SyncExecuteOperate;
begin
  if FPermissionMgr = nil then Exit;

  (FPermissionMgr as ISyncAsync).SyncExecute;
end;

procedure TPermissionMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FPermissionMgr = nil then Exit;

  (FPermissionMgr as ISyncAsync).AsyncExecute;
end;

end.
