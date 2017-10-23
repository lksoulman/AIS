unit MsgReceiverImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message Receiver Interface implementation
// Author£º      lksoulman
// Date£º        2017-7-29
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
  CommonLock,
  MsgFactory,
  MsgReceiver,
  MsgReceiverPend,
  CommonRefCounter,
  Generics.Collections;

type

  // Message Receiver Interface implementation
  TMsgReceiverImpl = class(TAutoInterfacedObject, IMsgReceiver, IMsgReceiverPend)
  private
    // Thread lock
    FLock: TCSLock;
    // ID
    FID: Integer;
    // is active
    FActive: Boolean;
    // call back
    FCallBack: TMsgFuncCallBack;
    // Pending Messgae Extends
    FPendMsgExs: TList<TMsgEx>;
    // Pending Message Type count
    FPendMsgTypeCount: Integer;
    // Pending Message Array
    FPendMsgTypes: TMsgTypeDynArray;
  protected
    // Clear Pend Message Extends
    procedure DoClearPendMsgExs;
    // Is Exist Message Type
    function DoIsExistsMsgType(AMsgType: TMsgType): Boolean;
  public
    // Constructor method
    constructor Create(AID: Integer; ACallBack: TMsgFuncCallBack); reintroduce;
    // Destructor method
    destructor Destroy; override;

    { IMsgReceiver }

    // Lock
    procedure Lock; safecall;
    // Un Lock
    procedure UnLock; safecall;
    // Get Receiver Id
    function GetId: Integer; safecall;
    // Get Active State
    function GetActive: Boolean; safecall;
    // Set Active State
    procedure SetActive(Active: Boolean); safecall;
    // Invoke Notification
    procedure InvokeNotify(AMsgEx: TMsgEx); safecall;
    // Clear Pending Message
    function ClearPendMsg: Boolean; safecall;
    // Get Pending Message Count (No Safe, Lock)
    function GetPendMsgCount: Integer; safecall;
    // Get Pending Message Type (No Safe, Lock)
    function GetPendMsg(AIndex: Integer): TMsgEx; safecall;
    // Get Pending Message Type Count (No Safe, Lock)
    function GetPendMsgTypeCount: Integer; safecall;
    // Get Pending Message Type (No Safe, Lock)
    function GetPendMsgType(AIndex: Integer): TMsgType; safecall;
    // Is Exist Message Type
    function IsExistsMsgType(AMsgType: TMsgType): Boolean; safecall;

    { IMsgReceiverPend }

    // Add Pending Message Extend
    function AddPendMsg(AMsgEx: TMsgEx): Boolean; safecall;
  end;

implementation

uses
  MsgExImpl,
  LogLevel;

{ TMsgReceiverImpl }

constructor TMsgReceiverImpl.Create(AID: Integer; ACallBack: TMsgFuncCallBack);
begin
  inherited Create;
  FCallBack := ACallBack;
  FPendMsgTypeCount := 0;
  FLock := TCSLock.Create;
  FPendMsgExs := TList<TMsgEx>.Create;
end;

destructor TMsgReceiverImpl.Destroy;
begin
  FCallBack := nil;
  FPendMsgExs.Free;
  FLock.Free;
  inherited;
end;

procedure TMsgReceiverImpl.Lock;
begin
  FLock.Lock;
end;

procedure TMsgReceiverImpl.UnLock;
begin
  FLock.UnLock;
end;

function TMsgReceiverImpl.GetId: Integer;
begin
  Result := FID;
end;

function TMsgReceiverImpl.GetActive: Boolean;
begin
  Result := FActive;
end;

procedure TMsgReceiverImpl.SetActive(Active: Boolean);
begin
  FActive := Active;
end;

procedure TMsgReceiverImpl.InvokeNotify(AMsgEx: TMsgEx);
var
  LLogTag: string;
begin
  TMsgExImpl(AMsgEx).IncrRefCounter;
  try
    if Assigned(FCallBack) then begin
      LLogTag := '';
      try
  //      FCallBack(AMsgType, AMsgInfo, LLogTag);
      except
        on Ex: Exception do begin
//          FastSysLog(llERROR, Format('[TMsgExReceiverImpl][InvokeNotify] is exception, exception is %s, LogTag is %s, ID is %d.', [Ex.Message, LLogTag, AMsgEx.GetProId]));
        end;
      end;
    end;
  finally
    TMsgExImpl(AMsgEx).DecrRefCounter;
  end;
end;

function TMsgReceiverImpl.ClearPendMsg: Boolean;
begin
  FLock.Lock;
  try
    if FPendMsgTypeCount > 0 then begin
      FPendMsgTypeCount := 0;
      SetLength(FPendMsgTypes, FPendMsgTypeCount);
    end;

    DoClearPendMsgExs;
    Result := True;
  finally
    FLock.UnLock;
  end;
end;

function TMsgReceiverImpl.GetPendMsgCount: Integer;
begin
  Result := FPendMsgExs.Count - 1;
end;

function TMsgReceiverImpl.GetPendMsg(AIndex: Integer): TMsgEx;
begin
  if (AIndex >= 0)
    and (AIndex < FPendMsgTypeCount) then begin
    Result := FPendMsgExs.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TMsgReceiverImpl.GetPendMsgTypeCount: Integer;
begin
  Result := FPendMsgTypeCount;
end;

function TMsgReceiverImpl.GetPendMsgType(AIndex: Integer): TMsgType;
begin
  if (AIndex >= 0)
    and (AIndex < FPendMsgTypeCount) then begin
    Result := FPendMsgTypes[AIndex];
  end else begin
    Result := mtNone;
  end;
end;

function TMsgReceiverImpl.IsExistsMsgType(AMsgType: TMsgType): Boolean;
begin
  FLock.Lock;
  try
    Result := DoIsExistsMsgType(AMsgType);
  finally
    FLock.UnLock;
  end;
end;

function TMsgReceiverImpl.AddPendMsg(AMsgEx: TMsgEx): Boolean;
begin
  if AMsgEx = nil then Exit;

  FLock.Lock;
  try
    if not DoIsExistsMsgType(AMsgEx.GetMsgType) then begin
      SetLength(FPendMsgTypes, FPendMsgTypeCount + 1);
      FPendMsgTypes[FPendMsgTypeCount] := AMsgEx.GetMsgType;
      Inc(FPendMsgTypeCount);
    end;
    FPendMsgExs.Add(AMsgEx);
    TMsgExImpl(AMsgEx).IncrRefCounter;
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgReceiverImpl.DoClearPendMsgExs;
var
  LMsgEx: TMsgEx;
  LIndex: Integer;
begin
  if FPendMsgExs.Count <= 0 then Exit;

  for LIndex := 0 to FPendMsgExs.Count - 1 do begin
    LMsgEx := FPendMsgExs.Items[LIndex];
    if LMsgEx <> nil then begin
      TMsgExImpl(LMsgEx).DecrRefCounter;
    end;
  end;
  FPendMsgExs.Clear;
end;

function TMsgReceiverImpl.DoIsExistsMsgType(AMsgType: TMsgType): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  if FPendMsgTypeCount = 0 then Exit;

  for LIndex := 0 to FPendMsgTypeCount - 1 do begin
    if AMsgType = FPendMsgTypes[LIndex] then begin
      Result := True;
      Exit;
    end;
  end;
end;

end.
