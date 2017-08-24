unit SectorUserMgrPlugInImpl;

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
  SectorUserMgr;

type

  // �û�������ӿڲ��
  TSectorUserMgrPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // �û�������ӿ�
    FSectorUserMgr: ISectorUserMgr;
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
  SectorUserMgrImpl;

{ TSectorUserMgrPlugInImpl }

constructor TSectorUserMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TSectorUserMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TSectorUserMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FSectorUserMgr := TSectorUserMgrImpl.Create as ISectorUserMgr;
  (FSectorUserMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ISectorUserMgr, FSectorUserMgr);
end;

procedure TSectorUserMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ISectorUserMgr);
  (FSectorUserMgr as ISyncAsync).UnInitialize;
  FSectorUserMgr := nil;
  FAppContext := nil;
end;

function TSectorUserMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TSectorUserMgrPlugInImpl.SyncExecuteOperate;
begin
  if FSectorUserMgr = nil then Exit;

  (FSectorUserMgr as ISyncAsync).SyncExecute;
end;

procedure TSectorUserMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FSectorUserMgr = nil then Exit;

  (FSectorUserMgr as ISyncAsync).AsyncExecute;
end;

end.
