unit CacheUserDataPlugInImpl;

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
  CacheUserData;

type

  // 用户缓存数据插件
  TCacheUserDataPlugInImpl = class(TPlugInImpl)
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 用户缓冲数据接口
    FCacheUserData: ICacheUserData;
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
  CacheUserDataImpl;

{ TCacheUserDataPlugInImpl }

constructor TCacheUserDataPlugInImpl.Create;
begin
  inherited;
  FCacheUserData := TCacheUserDataImpl.Create as ICacheUserData;
end;

destructor TCacheUserDataPlugInImpl.Destroy;
begin
  FCacheUserData := nil;
  inherited;
end;

procedure TCacheUserDataPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FCacheUserData as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICacheUserData, FCacheUserData);
end;

procedure TCacheUserDataPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICacheUserData);
  (FCacheUserData as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TCacheUserDataPlugInImpl.SyncBlockExecute;
begin
  if FCacheUserData = nil then Exit;

  (FCacheUserData as ISyncAsync).SyncBlockExecute;
end;

procedure TCacheUserDataPlugInImpl.AsyncNoBlockExecute;
begin
  if FCacheUserData = nil then Exit;

  (FCacheUserData as ISyncAsync).AsyncNoBlockExecute;
end;

function TCacheUserDataPlugInImpl.Dependences: WideString;
begin

end;

end.
