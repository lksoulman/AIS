unit SectorMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-23
// Comments：
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

  // 板块管理
  TSectorMgr = class(TAutoInterfacedObject)
  private
  protected
    // 用户根结点板块
    FRootSector: ISector;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 读写锁
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  public
    // 构造方法
    constructor Create; override;
    // 析构函数
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
