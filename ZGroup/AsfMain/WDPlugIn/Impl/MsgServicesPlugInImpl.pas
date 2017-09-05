unit MsgServicesPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message service Inteface PlugIn
// Author£º      lksoulman
// Date£º        2017-8-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  MsgServices;

type

  // Message service Inteface PlugIn
  TMsgServicesPlugInImpl = class(TPlugInImpl)
  private
    // Message service Inteface
    FMsgServices: IMsgServices;
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
  MsgServicesImpl;

{ TMsgServicesPlugInImpl }

constructor TMsgServicesPlugInImpl.Create;
begin
  inherited;
  FMsgServices := TMsgServicesImpl.Create as IMsgServices;
end;

destructor TMsgServicesPlugInImpl.Destroy;
begin
  FMsgServices := nil;
  inherited;
end;

procedure TMsgServicesPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FMsgServices as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IMsgServices, FMsgServices);
end;

procedure TMsgServicesPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IMsgServices);
  (FMsgServices as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TMsgServicesPlugInImpl.SyncBlockExecute;
begin
  if FMsgServices = nil then Exit;

  (FMsgServices as ISyncAsync).SyncBlockExecute;
end;

procedure TMsgServicesPlugInImpl.AsyncNoBlockExecute;
begin
  if FMsgServices = nil then Exit;

  (FMsgServices as ISyncAsync).AsyncNoBlockExecute;
end;

function TMsgServicesPlugInImpl.Dependences: WideString;
begin
  Result := (FMsgServices as ISyncAsync).Dependences;
end;

end.
