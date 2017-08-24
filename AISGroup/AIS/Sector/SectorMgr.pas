unit SectorMgr;

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
  AppContext,
  CommonLock,
  CommonRefCounter;

type

  // ������
  TSectorMgr = class(TAutoInterfacedObject)
  private
  protected
    // �û��������
    FRootSector: ISector;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ��д��
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  public
    // ���췽��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
  end;

implementation

uses
  SectorImpl;

{ TSectorMgr }

constructor TSectorMgr.Create;
begin
  inherited;
  FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FRootSector := TSectorImpl.Create as ISector;
end;

destructor TSectorMgr.Destroy;
begin
  FRootSector := nil;
  FReadWriteLock.Free;
  inherited;
end;

end.
