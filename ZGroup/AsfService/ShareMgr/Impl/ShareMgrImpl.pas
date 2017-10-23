unit ShareMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Share Manager Interface implementation
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Math,
  ElAES,
  Proxy,
  GFData,
  Windows,
  Classes,
  SysUtils,
  ShareMgr,
  AppContext,
  HttpContextPool,
  CommonRefCounter;

type

  // Share Manager Interface implementation
  TShareMgrImpl = class(TAutoInterfacedObject, IShareMgr)
  private
    // Url
    FUrl: string;
    // Seesion Id
    FSessionId: string;
    // Proxy
    FProxy: TProxy;
    // Is Logined
    FIsLogined: Boolean;
    // HardDiskId MD5
    FHardDiskIdMD5: string;
    // AES Key 128
    FAESKey128: TAESKey128;
    // Application Context
    FAppContext: IAppContext;
    // Re Login Event
    FReLoginEvent: TReLoginEvent;
    // Http Context Pool
    FHttpContextPool: THttpContextPool;
  protected
    // Init AES Key 128
    procedure DoInitAESKey128;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IShareMgr }

    // Init
    procedure Initialize(AContext: IAppContext); safecall;
    // Un Init
    procedure UnInitialize; safecall;
    // Get Url
    function GetUrl: string; safecall;
    // Get Proxy
    function GetProxy: PProxy; safecall;
    // Get Session Id
    function GetSessionId: string; safecall;
    // Get Is Logined
    function GetIsLogined: Boolean; safecall;
    // Get AES Key 128
    function GetAESKey128: TAESKey128; safecall;
    // Get Hard Disk Id MD5
    function GetHardDiskIdMD5: string; safecall;
    // Get AppContext
    function GetAppContext: IAppContext; safecall;
    // Get Re Login Event
    function GetReLoginEvent: TReLoginEvent; safecall;
    // Get Handler Pool
    function GetHttpContextPool: THttpContextPool; safecall;
    // Set Url
    procedure SetUrl(AUrl: string); safecall;
    // Set Proxy
    procedure SetProxy(APProxy: PProxy); safecall;
    // Set Session Id
    procedure SetSessionId(ASessionId: string); safecall;
    // Get Is Logined
    procedure SetIsLogined(AIsLogined: Boolean); safecall;
    // Set HardDiskId MD5
    procedure SetHardDiskIdMD5(AHardDiskIdMD5: string); safecall;
    // Set Re Login Event
    procedure SetReLoginEvent(AReLoginEvent: TReLoginEvent); safecall;
  end;

implementation

{ TShareMgrImpl }

constructor TShareMgrImpl.Create;
begin
  inherited;
  FUrl := '';
  FSessionId := '';
  FIsLogined := False;
  FHttpContextPool := THttpContextPool.Create(20);
  DoInitAESKey128;
end;

destructor TShareMgrImpl.Destroy;
begin
  FHttpContextPool.Free;
  inherited;
end;

procedure TShareMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TShareMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TShareMgrImpl.GetUrl: string;
begin
  Result := FUrl;
end;

function TShareMgrImpl.GetProxy: PProxy;
begin
  Result := @FProxy;
end;

function TShareMgrImpl.GetSessionId: string;
begin
  Result := FSessionId;
end;

function TShareMgrImpl.GetIsLogined: Boolean;
begin
  Result := FIsLogined;
end;

function TShareMgrImpl.GetAESKey128: TAESKey128;
begin
  Result := FAESKey128;
end;

function TShareMgrImpl.GetHardDiskIdMD5: string;
begin
  Result := FHardDiskIdMD5;
end;

function TShareMgrImpl.GetAppContext: IAppContext;
begin
  Result := FAppContext;
end;

function TShareMgrImpl.GetReLoginEvent: TReLoginEvent;
begin
  Result := FReLoginEvent;
end;

function TShareMgrImpl.GetHttpContextPool: THttpContextPool;
begin
  Result := FHttpContextPool;
end;

procedure TShareMgrImpl.SetUrl(AUrl: string);
begin
  FUrl := AUrl;
end;

procedure TShareMgrImpl.SetProxy(APProxy: PProxy);
begin
  FProxy.Assign(APProxy);
end;

procedure TShareMgrImpl.SetSessionId(ASessionId: string);
begin
  FSessionId := ASessionId;
end;

procedure TShareMgrImpl.SetIsLogined(AIsLogined: Boolean);
begin
  FIsLogined := AIsLogined;
end;

procedure TShareMgrImpl.SetHardDiskIdMD5(AHardDiskIdMD5: string);
begin
  FHardDiskIdMD5 := AHardDiskIdMD5;
end;

procedure TShareMgrImpl.SetReLoginEvent(AReLoginEvent: TReLoginEvent);
begin
  FReLoginEvent := AReLoginEvent;
end;

procedure TShareMgrImpl.DoInitAESKey128;
const
  KEYS: array [0..9] of AnsiChar = ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0');
  //2346781234568905
  BITS: array [0..15] of Word = (2, 3, 4, 6, 7, 8, 1, 2, 3, 4, 5, 6, 8, 9, 10, 5);
var
//  LIndex: integer;
  LKey: AnsiString;
begin
  LKey := '2346781234568905';
//  for LIndex := Low(BITS) to High(BITS) do begin
//    LKey := LKey + KEYS[BITS[LIndex]-1];
//  end;
  FillChar(FAESKey128, SizeOf(FAESKey128), 0);
  Move(PAnsiChar(LKey)^, FAESKey128, Min(SizeOf(FAESKey128), Length(LKey)));
end;

end.
