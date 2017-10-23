unit SecuMainPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SecuMain PlugIn Inteface Implementation
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
  SecuMain,
  PlugInImpl,
  AppContext;

type

  // SecuMain PlugIn Inteface Implementation
  TSecuMainPlugInImpl = class(TPlugInImpl)
  private
    // SecuMain
    FSecuMain: ISecuMain;
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
  SecuMainImpl;

{ TSecuMainPlugInImpl }

constructor TSecuMainPlugInImpl.Create;
begin
  inherited;
  FSecuMain := TSecuMainImpl.Create as ISecuMain;
end;

destructor TSecuMainPlugInImpl.Destroy;
begin
  FSecuMain := nil;
  inherited;
end;

procedure TSecuMainPlugInImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

  (FSecuMain as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ISecuMain, FSecuMain);
end;

procedure TSecuMainPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ISecuMain);
  (FSecuMain as ISyncAsync).UnInitialize;

  inherited UnInitialize;
end;

procedure TSecuMainPlugInImpl.SyncBlockExecute;
begin
  if FSecuMain = nil then Exit;

  (FSecuMain as ISyncAsync).SyncBlockExecute;
end;

procedure TSecuMainPlugInImpl.AsyncNoBlockExecute;
begin
  if FSecuMain = nil then Exit;

  (FSecuMain as ISyncAsync).AsyncNoBlockExecute;
end;

function TSecuMainPlugInImpl.Dependences: WideString;
begin
  Result := (FSecuMain as ISyncAsync).Dependences;
end;

end.
