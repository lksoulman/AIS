unit SectorMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorMain Memory Table Interface implementation
// Author£º      lksoulman
// Date£º        2017-9-2
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  SectorMain,
  SyncAsyncImpl;

type

  TSectorMainImpl = class(TSyncAsyncImpl, ISectorMain)
  private
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize Resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing Resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Dependency Interface
    function Dependences: WideString; override;
  end;

implementation

{ TSectorMainImpl }

constructor TSectorMainImpl.Create;
begin
  inherited;

end;

destructor TSectorMainImpl.Destroy;
begin

  inherited;
end;

procedure TSectorMainImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
end;

procedure TSectorMainImpl.UnInitialize;
begin
  inherited UnInitialize;
end;

procedure TSectorMainImpl.SyncBlockExecute;
begin

end;

procedure TSectorMainImpl.AsyncNoBlockExecute;
begin

end;

function TSectorMainImpl.Dependences: WideString;
begin
  Result := '';
end;

end.
