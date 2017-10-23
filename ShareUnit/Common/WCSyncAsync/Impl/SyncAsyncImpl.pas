unit SyncAsyncImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Synchronous asynchronous interface
// Author£º      lksoulman
// Date£º        2017-8-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgType,
  MsgFunc,
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  AppContext,
  MsgService,
  MsgReceiver,
  CommonRefCounter;

type

  // Synchronous and asynchronous interface implementation
  TSyncAsyncImpl = class(TAutoInterfacedObject, ISyncAsync)
  private
  protected
    // Application Context Interface
    FAppContext: IAppContext;
     // Message Service
    FMsgService: IMsgService;
    // Message Receiver
    FMsgReceiver: IMsgReceiver;
    // Is Need Subcribe Message
    FIsNeedSubcribeMsg: Boolean;
    // Subcribe Message Type Count
    FSubcribeMsgTypeCount: Integer;
    // Subcribe Message Types
    FSubcribeMsgTypes: TMsgTypeDynArray;

    // Add Message Type
    procedure DoAddMsgTypes; virtual;
    // Init Message Subcribe
    procedure DoInitMsgSubcribe; virtual;
    // UnInit Message Subcribe
    procedure DoUnInitMsgSubcribe; virtual;
    // Add Message Type
    procedure DoAddMsgType(AMsgType: TMsgType); virtual;
    // Subcribe Message Call back
    procedure DoMsgCallBack(AMsgEx: TMsgEx; var ALogTag: string); virtual;
    // Post Message Extend
    procedure DoPostMessageEx(AMsgType: TMsgType; AMsgInfo: WideString);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize Resources(only execute once)
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // Releasing Resources(only execute once)
    procedure UnInitialize; virtual; safecall;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; virtual; safecall;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; virtual; safecall;
    // Dependency
    function Dependences: WideString; virtual; safecall;
  end;

implementation

{ TSyncAsyncImpl }

constructor TSyncAsyncImpl.Create;
begin
  inherited;
  FIsNeedSubcribeMsg := False;
  FSubcribeMsgTypeCount := 0;
end;

destructor TSyncAsyncImpl.Destroy;
begin

  inherited;
end;

procedure TSyncAsyncImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  if FIsNeedSubcribeMsg then begin
    FMsgService := FAppContext.GetMsgService as IMsgService;
    if FMsgService <> nil then begin
      DoAddMsgTypes;
      DoInitMsgSubcribe;
    end;
  end;
end;

procedure TSyncAsyncImpl.UnInitialize;
begin
  if FIsNeedSubcribeMsg then begin
    if FMsgService <> nil then begin
      DoUnInitMsgSubcribe;
      FMsgService := nil;
    end;
  end;
  FAppContext := nil;
end;

procedure TSyncAsyncImpl.SyncBlockExecute;
begin

end;

procedure TSyncAsyncImpl.AsyncNoBlockExecute;
begin

end;

function TSyncAsyncImpl.Dependences: WideString;
begin
  Result := '';
end;

procedure TSyncAsyncImpl.DoAddMsgTypes;
begin
//  DoAddMsgType()
end;

procedure TSyncAsyncImpl.DoInitMsgSubcribe;
var
  LIndex: Integer;
begin
  FMsgReceiver := FMsgService.NewReceiver(DoMsgCallBack);
  for LIndex := 0 to FSubcribeMsgTypeCount - 1 do begin
    FMsgService.Subcribe(FSubcribeMsgTypes[LIndex], FMsgReceiver);
  end;
end;

procedure TSyncAsyncImpl.DoUnInitMsgSubcribe;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FSubcribeMsgTypeCount - 1 do begin
    FMsgService.UnSubcribe(FSubcribeMsgTypes[LIndex], FMsgReceiver);
  end;
  FMsgReceiver := nil;
  FMsgService := nil;
end;

procedure TSyncAsyncImpl.DoAddMsgType(AMsgType: TMsgType);
begin
  SetLength(FSubcribeMsgTypes, FSubcribeMsgTypeCount + 1);
  FSubcribeMsgTypes[FSubcribeMsgTypeCount] := AMsgType;
  Inc(FSubcribeMsgTypeCount);
end;

procedure TSyncAsyncImpl.DoMsgCallBack(AMsgEx: TMsgEx; var ALogTag: string);
begin
  ALogTag := Format('[%s][DoMsgCallBack]', [Self.ClassName]);
end;

procedure TSyncAsyncImpl.DoPostMessageEx(AMsgType: TMsgType; AMsgInfo: WideString);
begin
  if (FMsgService <> nil)
    and (FMsgReceiver <> nil) then begin
    FMsgService.PostMessageEx(FMsgReceiver.GetId, AMsgType, AMsgInfo);
  end;
end;

end.
