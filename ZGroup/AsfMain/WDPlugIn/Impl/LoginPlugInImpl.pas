unit LoginPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Login PlugIn Implementation
// Author£º      lksoulman
// Date£º        2017-8-30
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Login,
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext;

type

  // Login PlugIn Implementation
  TLoginPlugInImpl = class(TPlugInImpl)
  private
    // Login
    FLogin: ILogin;
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
  LoginImpl;

{ TLoginPlugInImpl }

constructor TLoginPlugInImpl.Create;
begin
  inherited;
  FLogin := TLoginImpl.Create as ILogin;
end;

destructor TLoginPlugInImpl.Destroy;
begin
  FLogin := nil;
  inherited;
end;

procedure TLoginPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FLogin as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ILogin, FLogin);
end;

procedure TLoginPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ILogin);
  (FLogin as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TLoginPlugInImpl.SyncBlockExecute;
begin
  if FLogin = nil then Exit;

  (FLogin as ISyncAsync).SyncBlockExecute;
end;

procedure TLoginPlugInImpl.AsyncNoBlockExecute;
begin
  if FLogin = nil then Exit;

  (FLogin as ISyncAsync).AsyncNoBlockExecute;
end;

function TLoginPlugInImpl.Dependences: WideString;
begin
  Result := (FLogin as ISyncAsync).Dependences;
end;

end.
