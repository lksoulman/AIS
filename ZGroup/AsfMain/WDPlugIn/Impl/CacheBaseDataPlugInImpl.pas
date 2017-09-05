unit CacheBaseDataPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-20
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  CacheBaseData;

type

  // 实现基础数据插件
  TCacheBaseDataPlugInImpl = class(TPlugInImpl)
  private
    // 证券数据接口
    FCacheBaseData: ICacheBaseData;
  protected
  public
     // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { IPlugIn }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Get dependency
    function Dependences: WideString; override;
  end;

implementation

uses
  SyncAsync,
  CacheBaseDataImpl;

{ TCacheBaseDataPlugInImpl }

constructor TCacheBaseDataPlugInImpl.Create;
begin
  inherited;

end;

destructor TCacheBaseDataPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TCacheBaseDataPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FCacheBaseData := TCacheBaseDataImpl.Create as ICacheBaseData;
  (FCacheBaseData as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICacheBaseData, FCacheBaseData);
end;

procedure TCacheBaseDataPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICacheBaseData);
  (FCacheBaseData as ISyncAsync).UnInitialize;
  FCacheBaseData := nil;
  FAppContext := nil;
end;

procedure TCacheBaseDataPlugInImpl.SyncBlockExecute;
begin
  if FCacheBaseData = nil then Exit;

  (FCacheBaseData as ISyncAsync).SyncBlockExecute;
end;

procedure TCacheBaseDataPlugInImpl.AsyncNoBlockExecute;
begin
  if FCacheBaseData = nil then Exit;

  (FCacheBaseData as ISyncAsync).AsyncNoBlockExecute;
end;

function TCacheBaseDataPlugInImpl.Dependences: WideString;
begin
  if FCacheBaseData = nil then Exit;

  (FCacheBaseData as ISyncAsync).Dependences;
end;

end.
