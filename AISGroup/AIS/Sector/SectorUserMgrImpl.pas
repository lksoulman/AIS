unit SectorUserMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-23
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils,
  SectorMgr,
  SyncAsync,
  AppContext,
  SectorUserMgr;

type

  TSectorUserMgrImpl = class(TSectorMgr, ISyncAsync, ISectorUserMgr)
  private
  protected
    // ͬ�������û��������
    procedure DoSyncLoadUserSectorData;
  public
    // ���췽��
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

    { ISectorUserMgr }

    // ������
    procedure BeginRead; safecall;
    // ������
    procedure EndRead; safecall;
    // д����
    procedure BeginWrite; safecall;
    // д����
    procedure EndWrite; safecall;
    // ��ȡ�������
    function GetRootSector: ISector; safecall;
  end;

implementation

{ TSectorUserMgrImpl }

constructor TSectorUserMgrImpl.Create;
begin
  inherited;

end;

destructor TSectorUserMgrImpl.Destroy;
begin

  inherited;
end;

procedure TSectorUserMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TSectorUserMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TSectorUserMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TSectorUserMgrImpl.SyncExecute;
begin
  DoSyncLoadUserSectorData;
end;

procedure TSectorUserMgrImpl.AsyncExecute;
begin

end;

procedure TSectorUserMgrImpl.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

procedure TSectorUserMgrImpl.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TSectorUserMgrImpl.BeginWrite;
begin
  FReadWriteLock.BeginWrite;
end;

procedure TSectorUserMgrImpl.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

function TSectorUserMgrImpl.GetRootSector: ISector;
begin
  Result := FRootSector;
end;

procedure TSectorUserMgrImpl.DoSyncLoadUserSectorData;
begin

end;

end.
