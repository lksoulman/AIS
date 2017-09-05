unit MsgServicePlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message Service Inteface implementation
// Author£º      lksoulman
// Date£º        2017-8-31
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgService,
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext;

type

  //  Message Service Interface implementation
  TMsgServicePlugInImpl = class(TPlugInImpl)
  private
    // Message Service Interface
    FMsgService: IMsgService;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
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
  MsgServiceImpl;

{ TMsgServicePlugInImpl }

constructor TMsgServicePlugInImpl.Create;
begin
  inherited;
  FMsgService := TMsgServiceImpl.Create as IMsgService;
end;

destructor TMsgServicePlugInImpl.Destroy;
begin
  FMsgService := nil;
  inherited;
end;

procedure TMsgServicePlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FMsgService as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IMsgService, FMsgService);
end;

procedure TMsgServicePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IMsgService);
  (FMsgService as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TMsgServicePlugInImpl.SyncBlockExecute;
begin
  if FMsgService = nil then Exit;

  (FMsgService as ISyncAsync).SyncBlockExecute;
end;

procedure TMsgServicePlugInImpl.AsyncNoBlockExecute;
begin
  if FMsgService = nil then Exit;

  (FMsgService as ISyncAsync).AsyncNoBlockExecute;
end;

function TMsgServicePlugInImpl.Dependences: WideString;
begin
  Result := (FMsgService as ISyncAsync).Dependences;
end;

end.
