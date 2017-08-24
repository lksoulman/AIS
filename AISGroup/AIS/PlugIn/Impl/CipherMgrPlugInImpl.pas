unit CipherMgrPlugInImpl;

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
  CipherMgr,
  PlugInImpl,
  AppContext;

type

  TCipherMgrPlugInImpl = class(TPlugInImpl)
  private
    // ���ܽ��ܽӿ�
    FCipherMgr: ICipherMgr;
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
  CipherMgrImpl;

{ TCipherMgrPlugInImpl }

constructor TCipherMgrPlugInImpl.Create;
begin
  inherited;

end;

destructor TCipherMgrPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TCipherMgrPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FCipherMgr := TCipherMgrImpl.Create as ICipherMgr;
  (FCipherMgr as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICipherMgr, FCipherMgr);
end;

procedure TCipherMgrPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICipherMgr);
  (FCipherMgr as ISyncAsync).UnInitialize;
  FCipherMgr := nil;
  FAppContext := nil;
end;

function TCipherMgrPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FCipherMgr = nil then Exit;

  Result := (FCipherMgr as ISyncAsync).IsNeedSync;
end;

procedure TCipherMgrPlugInImpl.SyncExecuteOperate;
begin
  if FCipherMgr = nil then Exit;

  (FCipherMgr as ISyncAsync).SyncExecute;
end;

procedure TCipherMgrPlugInImpl.AsyncExecuteOperate;
begin
  if FCipherMgr = nil then Exit;

  (FCipherMgr as ISyncAsync).AsyncExecute;
end;

end.
