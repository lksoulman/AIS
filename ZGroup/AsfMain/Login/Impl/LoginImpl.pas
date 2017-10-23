unit LoginImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Login Interface Implementation
// Author£º      lksoulman
// Date£º        2017-9-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Login,
  Windows,
  Classes,
  SysUtils,
  Controls,
  AppContext,
  ServiceType,
  SyncAsyncImpl,
  AbstractLogin;

type

  // Login Interface Implementation
  TLoginImpl = class(TSyncAsyncImpl, ILogin)
  private
    // Login
    FLogin: TAbstractLogin;
  protected
    // Init Login
    procedure DoInitLogin;
    // Un Init Login
    procedure DoUnInitLogin;
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

    { ILogin }

    // Is Login Service
    function IsLoginService(AServiceType: TServiceType): Boolean; safecall;
  end;

implementation

uses
  Cfg,
  SysCfg,
  UserInfo,
  UFXAccountLogin,
  GilAccountLogin,
  PBoxAccountLogin;

{ TLoginImpl }

constructor TLoginImpl.Create;
begin
  inherited;

end;

destructor TLoginImpl.Destroy;
begin

  inherited;
end;

procedure TLoginImpl.DoInitLogin;
begin
  if FAppContext <> nil then begin
    if FLogin = nil then begin
      case FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetAccountType of
        atUFX:
          begin
            FLogin := TUFXAccountLogin.Create;
          end;
        atGIL:
          begin
            FLogin := TGilAccountLogin.Create;
          end;
        atPBOX:
          begin
            FLogin := TPBoxAccountLogin.Create;
          end;
      end;
      FLogin.Initialize(FAppContext);
    end;
  end;
end;

procedure TLoginImpl.DoUnInitLogin;
begin
  if FLogin <> nil then begin
    FLogin.UnInitialize;
    FLogin.Free;
  end;
end;

procedure TLoginImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  DoInitLogin;
end;

procedure TLoginImpl.UnInitialize;
begin
  DoUnInitLogin;
  inherited UnInitialize;
end;

procedure TLoginImpl.SyncBlockExecute;
begin
  if FLogin <> nil then begin
    if FLogin.ShowLoginMainUI = mrOk then begin
      if FAppContext.GetCfg.GetSysCfg.GetUserInfo.GetSavePassword then begin
        FAppContext.GetCfg.GetSysCfg.GetUserInfo.SaveCache;
      end;
    end else begin
      FAppContext.ExitApp;
    end;
  end;
end;

procedure TLoginImpl.AsyncNoBlockExecute;
begin

end;

function TLoginImpl.Dependences: WideString;
begin

end;

function TLoginImpl.IsLoginService(AServiceType: TServiceType): Boolean;
begin
  if FLogin <> nil then begin
    Result := FLogin.IsLoginService(AServiceType);
  end else begin
    Result := False;
  end;
end;

end.
