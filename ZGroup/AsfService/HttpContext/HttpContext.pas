unit HttpContext;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Http Context
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  GFData,
  Windows,
  Classes,
  SysUtils,
  WaitMode,
  CommonLock,
  GFDataUpdate,
  CommonRefCounter;

type

  // Http Context
  THttpContext = class(TAutoObject)
  private
    // Lock
    FLock: TCSLock;
    // Indicator
    FIndicator: string;
    // Wait Mode
    FWaitMode: TWaitMode;
    // Wait Event
    FWaitEvent: Cardinal;
    // Data Event
    FDataEvent: TGFDataEvent;
    // Finance Data Update
    FGFDataUpdate: IGFDataUpdate;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Call Back
    procedure CallBack;
    // Reset Init
    procedure ResetInit;
    // Set Wait
    procedure SetWaitStart(AWaitTime: DWORD);
    // Set Wait Finish
    procedure SetWaitFinish(ASuccess: Boolean = True);
    // Set Call Back
    procedure SetCallBack(ACallBack: TGFDataEvent);

    property WaitEvent: Cardinal read FWaitEvent;
    property Indicator: string read FIndicator write FIndicator;
    property WaitMode: TWaitMode read FWaitMode write FWaitMode;
    property DataEvent: TGFDataEvent read FDataEvent write FDataEvent;
    property GFDataUpdate: IGFDataUpdate read FGFDataUpdate write FGFDataUpdate;
  end;

implementation

uses
  ErrorCode;

{ THttpContext }

constructor THttpContext.Create;
begin
  inherited;
  FLock := TCSLock.Create;
  FWaitEvent :=  CreateEvent(nil, false, False, nil);
end;

destructor THttpContext.Destroy;
begin
  if FWaitEvent <> 0 then begin
    SetEvent(FWaitEvent);
    CloseHandle(FWaitEvent);
  end;
  FLock.Free;
  inherited;
end;

procedure THttpContext.ResetInit;
begin
  if FGFDataUpdate <> nil then begin
    FGFDataUpdate := nil;
  end;

  FDataEvent := nil;
end;

procedure THttpContext.SetWaitStart(AWaitTime: DWORD);
var
  LResult: Cardinal;
begin
  LResult := WaitForSingleObject(WaitEvent, AWaitTime);
  FLock.Lock;
  try
    case LResult of
  //    WAIT_OBJECT_0:
  //      begin
  //
  //      end;
      WAIT_TIMEOUT:
        begin
          FGFDataUpdate.SetCancel;
          FGFDataUpdate.SetErrorCode(ErrorCode_Service_Wait_Timeout);
        end;
      WAIT_FAILED:
        begin
          FGFDataUpdate.SetCancel;
          FGFDataUpdate.SetErrorCode(ErrorCode_Service_Wait_Failed);
        end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure THttpContext.SetWaitFinish(ASuccess: Boolean);
begin
  FLock.Lock;
  try
    if ASuccess then begin
      if not FGFDataUpdate.GetIsCancel then begin
        SetEvent(FWaitEvent);
      end;
    end else begin

    end;
  finally
    FLock.UnLock;
  end;
end;

procedure THttpContext.CallBack;
begin
  if Assigned(FDataEvent) then begin
    if FGFDataUpdate.GetIsCancel then Exit;

    FDataEvent(FGFDataUpdate as IGFData);
  end;
end;

procedure THttpContext.SetCallBack(ACallBack: TGFDataEvent);
begin
  FDataEvent := ACallBack;
end;

end.
