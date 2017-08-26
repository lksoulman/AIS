unit KeyFairyMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-24
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  AppContext,
  CommonLock,
  KeyFairyMgr,
  KeyFairyPool,
  CommonRefCounter;

type

  TKeyFairyMgrImpl = class(TAutoInterfacedObject, ISyncAsync, IKeyFairyMgr)
  private
    // �߳���
    FLock: TCSLock;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // �����
    FKeyFairyPool: TKeyFairyPool;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IKeyFairyMgr }

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
  end;

implementation

{ TKeyFairyMgrImpl }

constructor TKeyFairyMgrImpl.Create;
begin
  inherited;
  FLock := TCSLock.Create;
  FKeyFairyPool := TKeyFairyPool.Create;
end;

destructor TKeyFairyMgrImpl.Destroy;
begin
  FKeyFairyPool.Free;
  FLock.Free;
  inherited;
end;

procedure TKeyFairyMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TKeyFairyMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TKeyFairyMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TKeyFairyMgrImpl.SyncExecute;
begin
  
end;

procedure TKeyFairyMgrImpl.AsyncExecute;
begin

end;

end.
