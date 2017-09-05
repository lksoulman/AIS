unit UserFundMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserFundMain Memory Table Interface implementation
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
  UserFundMain,
  SyncAsyncImpl;

type

  TUserFundMainImpl = class(TSyncAsyncImpl, IUserFundMain)
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

{ TUserFundMainImpl }

constructor TUserFundMainImpl.Create;
begin
  inherited;

end;

destructor TUserFundMainImpl.Destroy;
begin

  inherited;
end;

procedure TUserFundMainImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
end;

procedure TUserFundMainImpl.UnInitialize;
begin
  inherited UnInitialize;
end;

procedure TUserFundMainImpl.SyncBlockExecute;
begin

end;

procedure TUserFundMainImpl.AsyncNoBlockExecute;
begin

end;

function TUserFundMainImpl.Dependences: WideString;
begin
  Result := '';
end;

end.
