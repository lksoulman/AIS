unit MainFrameUIPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MainFrameUI PlugIn Inteface Implementation
// Author£º      lksoulman
// Date£º        2017-10-12
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
  MainFrameUI;

type

  // MainFrameUI PlugIn Inteface Implementation
  TMainFrameUIPlugInImpl = class(TPlugInImpl)
  private
    // MainFrameUI
    FMainFrameUI: IMainFrameUI;
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
  MainFrameUIImpl;

{ TMainFrameUIPlugInImpl }

constructor TMainFrameUIPlugInImpl.Create;
begin
  inherited;
  FMainFrameUI := TMainFrameUIImpl.Create as IMainFrameUI;
end;

destructor TMainFrameUIPlugInImpl.Destroy;
begin
  FMainFrameUI := nil;
  inherited;
end;

procedure TMainFrameUIPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FMainFrameUI as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IMainFrameUI, FMainFrameUI);
end;

procedure TMainFrameUIPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IMainFrameUI);
  (FMainFrameUI as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TMainFrameUIPlugInImpl.SyncBlockExecute;
begin
  if FMainFrameUI = nil then Exit;

  (FMainFrameUI as ISyncAsync).SyncBlockExecute;
end;

procedure TMainFrameUIPlugInImpl.AsyncNoBlockExecute;
begin
  if FMainFrameUI = nil then Exit;

  (FMainFrameUI as ISyncAsync).AsyncNoBlockExecute;
end;

function TMainFrameUIPlugInImpl.Dependences: WideString;
begin
  Result := (FMainFrameUI as ISyncAsync).Dependences;
end;

end.
