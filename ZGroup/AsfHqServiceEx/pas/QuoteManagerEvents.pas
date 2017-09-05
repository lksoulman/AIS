unit QuoteManagerEvents;

interface

uses ActiveX, OleServer, QuoteMngr_TLB;

type
  TOnConnected = procedure(const IP: WideString; Port: Word; ServerType: ServerTypeEnum) of object;
  TOnDisconnected = procedure(const IP: WideString; Port: Word; ServerType: ServerTypeEnum) of object;
  TOnWriteLog = procedure(const Log: WideString) of object;
  TOnProgress = procedure(const Msg: WideString; Max, Value: Integer) of object;

  TQuoteManagerEvents = class(TOleServer)
  private
    FServerData: TServerData;
    FIntf: IQuoteManager;
    FOnConnected: TOnConnected;
    FOnDisconnected: TOnDisconnected;
    FOnWriteLog: TOnWriteLog;
    FOnProgress: TOnProgress;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
  public
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IQuoteManager);
    procedure Disconnect; override;
    property OnConnected: TOnConnected read FOnConnected write FOnConnected;
    property OnDisconnected: TOnDisconnected read FOnDisconnected write FOnDisconnected;
    property OnWriteLog: TOnWriteLog read FOnWriteLog write FOnWriteLog;
    property OnProgress: TOnProgress read FOnProgress write FOnProgress;
  end;

implementation

{ TQuoteManagerEvents }

procedure TQuoteManagerEvents.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    FIntf := punk as IQuoteManager;
  end;
end;

procedure TQuoteManagerEvents.ConnectTo(svrIntf: IQuoteManager);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TQuoteManagerEvents.Disconnect;
begin
  if FIntf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

procedure TQuoteManagerEvents.InitServerData;
begin
  FServerData.ClassID := CLASS_QuoteManager;
  FServerData.EventIID := DIID_IQuoteManagerEvents;
  ServerData := @FServerData;
end;

procedure TQuoteManagerEvents.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    201:
      if Assigned(FOnConnected) then
        FOnConnected(Params[0], Params[1], Params[2]);
    202:
      if Assigned(FOnDisconnected) then
        FOnDisconnected(Params[0], Params[1], Params[2]);
    203:
      if Assigned(FOnWriteLog) then
        FOnWriteLog(Params[0]);
    204:
      if Assigned(FOnProgress) then
        FOnProgress(Params[0], Params[1], Params[2]);
  end;
end;

end.
