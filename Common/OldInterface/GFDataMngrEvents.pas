unit GFDataMngrEvents;

interface

uses ActiveX, OleServer, GFDataMngr_TLB;

{$WARN SYMBOL_PLATFORM OFF}

type
  TOnUserLogin = procedure(Code: integer; const Value: AnsiString) of object;
  TOnWriteDebug = procedure(const Value: AnsiString) of object;
  TOnWriteError = procedure(const URL, SQL: AnsiString; Code: integer; const Value: AnsiString) of object;
  
  TGFDataMngrEvents = class(TOleServer)
  private
    FServerData: TServerData;
    FIntf: IGFDataManager;
    FOnWriteDebug: TOnWriteDebug;
    FOnWriteError: TOnWriteError;
    FOnUserLogin: TOnUserLogin;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
  public
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IGFDataManager);
    procedure Disconnect; override;
    property OnWriteDebug: TOnWriteDebug read FOnWriteDebug write FOnWriteDebug;
    property OnWriteError: TOnWriteError read FOnWriteError write FOnWriteError;
    property OnUserLogin: TOnUserLogin read FOnUserLogin write FOnUserLogin;
  end;
  
implementation

{ TGFDataMngrEvents }

procedure TGFDataMngrEvents.Connect;
var
        punk: IUnknown;
begin
        if FIntf = nil then begin
                punk := GetServer;
                ConnectEvents(punk);
                Fintf:= punk as IGFDataManager;
        end;
end;

procedure TGFDataMngrEvents.ConnectTo(svrIntf: IGFDataManager);
begin
        Disconnect;
        FIntf := svrIntf;
        ConnectEvents(FIntf);
end;

procedure TGFDataMngrEvents.Disconnect;
begin
        if Fintf <> nil then begin
                DisconnectEvents(FIntf);
                FIntf := nil;
        end;
end;

procedure TGFDataMngrEvents.InitServerData;
begin
        FServerData.ClassID := CLASS_GFDataManager;
        FServerData.EventIID := DIID_IGFDataManagerEvents;
        ServerData := @FServerData;
end;

procedure TGFDataMngrEvents.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin


        case DispID of
                201: if Assigned(OnWriteDebug) then begin

                        FOnWriteDebug(Params[0]);
                end;

                202: if Assigned(FOnWriteError) then begin
                         FOnWriteError(Params[0], Params[1], Params[2], Params[3]);
                end;
                203: if Assigned(FOnUserLogin) then begin
                         FOnUserLogin(Params[0], Params[1]);
                end;
        end;
end;

end.
