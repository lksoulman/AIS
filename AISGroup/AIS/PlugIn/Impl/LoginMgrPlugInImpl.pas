unit LoginMgrPlugInImpl;

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
  LoginMgr,
  PlugInImpl,
  AppContext;

type

  TLoginMgrPlugInImpl = class(TPlugInImpl)
  private
    // ��¼���ڽӿ�
    FLoginMgr: ILoginMgr;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
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
  LoginMgrImpl;

{ TLoginMgrPlugInImpl }

constructor TLoginMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TLoginMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TLoginMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FLoginMgr := TLoginMgrImpl.Create as ILoginMgr;
  (FLoginMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ILoginMgr, FLoginMgr);
end;

procedure TLoginMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ILoginMgr);
  (FLoginMgr as ISyncAsync).UnInitialize;
  FLoginMgr := nil;
  FAppContext := nil;
end;

function TLoginMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FLoginMgr = nil then Exit;

  Result := (FLoginMgr as ISyncAsync).IsNeedSync;
end;

procedure TLoginMgrPlugInImpl.SyncExecuteOperate;
begin
  if FLoginMgr = nil then Exit;

  (FLoginMgr as ISyncAsync).SyncExecute;
end;

procedure TLoginMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FLoginMgr = nil then Exit;

  (FLoginMgr as ISyncAsync).AsyncExecute;
end;

end.
