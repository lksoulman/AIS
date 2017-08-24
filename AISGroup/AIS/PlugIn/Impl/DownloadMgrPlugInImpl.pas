unit DownloadMgrPlugInImpl;

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
  DownloadMgr;

type

  TDownloadMgrPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ��¼���ڽӿ�
    FDownloadMgr: IDownloadMgr;
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
  DownloadMgrImpl;

{ TDownloadMgrPlugInImpl }

constructor TDownloadMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TDownloadMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TDownloadMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FDownloadMgr := TDownloadMgrImpl.Create as IDownloadMgr;
  (FDownloadMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IDownloadMgr, FDownloadMgr);
end;

procedure TDownloadMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IDownloadMgr);
  (FDownloadMgr as ISyncAsync).UnInitialize;
  FDownloadMgr := nil;
  FAppContext := nil;
end;

function TDownloadMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FDownloadMgr = nil then Exit;

  Result := (FDownloadMgr as ISyncAsync).IsNeedSync;
end;

procedure TDownloadMgrPlugInImpl.SyncExecuteOperate;
begin
  if FDownloadMgr = nil then Exit;

  (FDownloadMgr as ISyncAsync).SyncExecute;
end;

procedure TDownloadMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FDownloadMgr = nil then Exit;

  (FDownloadMgr as ISyncAsync).AsyncExecute;
end;

end.
