unit MsgSubcribeMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º
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
  MsgReceiver,
  CommonRefCounter,
  Generics.Collections;

type

  // Message Subcribe Manager
  TMsgSubcribeMgr = class(TAutoObject)
  private
    // Thread lock
    FLock: TCSLock;
    // Increment Id (Concumer Id)
    FReceiverIncrId: Integer;
    // Message Receiver Interface
    FReceivers: TList<IMsgReceiver>;
    // Message Type Dictionary
    FMsgTypeDic: TDictionary<TMsgType, TList<IMsgReceiver>>;
  protected
    // Clear Dictionary
    procedure DoClearDic;
    // Clear Receiver
    procedure DoReceivers;
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;
    // Dispach Message
    procedure DispachMessageEx(AMsgEx: TMsgEx);
    // New Message Receiver Interface
    function NewReceiver(ACallBack: TMsgFuncCallBack): IMsgReceiver;
    // Subcribe
    procedure Subcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver);
    // UnSubcribe
    procedure UnSubcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver);
  end;

implementation

uses
  MsgExImpl,
  MsgReceiverPend,
  MsgReceiverImpl;

{ TMsgSubcribeMgr }

constructor TMsgSubcribeMgr.Create;
begin
  inherited;
  FReceiverIncrId := 0;
  FLock := TCSLock.Create;
  FReceivers := TList<IMsgReceiver>.Create;
  FMsgTypeDic := TDictionary<TMsgType, TList<IMsgReceiver>>.Create;
end;

destructor TMsgSubcribeMgr.Destroy;
begin
  DoClearDic;
  DoReceivers;
  FMsgTypeDic.Free;
  FReceivers.Free;
  FLock.Free;
  inherited;
end;

procedure TMsgSubcribeMgr.DoClearDic;
var
  LReceivers: TList<IMsgReceiver>;
  LEnum: TDictionary<TMsgType, TList<IMsgReceiver>>.TPairEnumerator;
begin
  LEnum := FMsgTypeDic.GetEnumerator;
  try
    while LEnum.MoveNext do begin
      LReceivers := LEnum.Current.Value;
      if (LReceivers <> nil)
        and (LReceivers.Count > 0) then begin
        LReceivers.Free;
      end;
    end;
    FMsgTypeDic.Clear;
  finally
    LEnum.Free;
  end;
end;

procedure TMsgSubcribeMgr.DoReceivers;
var
  LIndex: Integer;
  LReceiver: IMsgReceiver;
begin
  for LIndex := 0 to FReceivers.Count - 1 do begin
    LReceiver := FReceivers.Items[LIndex];
    if LReceiver <> nil then begin
      LReceiver.ClearPendMsg;
      FReceivers.Items[LIndex] := nil;
      LReceiver := nil;
    end;
  end;
  FReceivers.Clear;
end;

procedure TMsgSubcribeMgr.DispachMessageEx(AMsgEx: TMsgEx);
var
  LIndex: Integer;
  LReceivers: TList<IMsgReceiver>;
begin
  if AMsgEx = nil then Exit;
  FLock.Lock;
  try
    TMsgExImpl(AMsgEx).IncrRefCounter;
    try
      if FMsgTypeDic.TryGetValue(AMsgEx.GetMsgType, LReceivers)
        and (LReceivers <> nil) then begin
        for LIndex := 0 to LReceivers.Count - 1 do begin
          if LReceivers.Items[LIndex] <> nil then begin
            if LReceivers.Items[LIndex].GetActive then begin
              LReceivers.Items[LIndex].InvokeNotify(AMsgEx);
            end else begin
              (LReceivers.Items[LIndex] as IMsgReceiverPend).AddPendMsg(AMsgEx);
            end;
          end;
        end;
      end;
    finally
      TMsgExImpl(AMsgEx).DecrRefCounter;
    end;
  finally
    FLock.UnLock;
  end;
end;

function TMsgSubcribeMgr.NewReceiver(ACallBack: TMsgFuncCallBack): IMsgReceiver;
begin
  FLock.Lock;
  try
    Result := TMsgReceiverImpl.Create(FReceiverIncrId, ACallBack) as IMsgReceiver;
    FReceivers.Add(Result);
    Inc(FReceiverIncrId);
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgSubcribeMgr.Subcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver);
var
  LIndex: Integer;
  LReceivers: TList<IMsgReceiver>;
begin
  if AReceiver = nil then Exit;

  FLock.Lock;
  try
    if FMsgTypeDic.TryGetValue(AMsgType, LReceivers)
      and (LReceivers <> nil) then begin
      LIndex := LReceivers.IndexOf(AReceiver);
      if (LIndex >= 0) and (LIndex < LReceivers.Count) then begin
        LReceivers.Items[LIndex] := AReceiver;
      end else begin
        LReceivers.Add(AReceiver);
      end;
    end else begin
      LReceivers := TList<IMsgReceiver>.Create;
      LReceivers.Add(AReceiver);
      FMsgTypeDic.AddOrSetValue(AMsgType, LReceivers);
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgSubcribeMgr.UnSubcribe(AMsgType: TMsgType; AReceiver: IMsgReceiver);
var
  LIndex: Integer;
  LReceivers: TList<IMsgReceiver>;
begin
  if AReceiver = nil then Exit;
  FLock.Lock;
  try
    if FMsgTypeDic.TryGetValue(AMsgType, LReceivers)
      and (LReceivers <> nil) then begin
      LIndex := LReceivers.IndexOf(AReceiver);
      if (LIndex >= 0) and (LIndex < LReceivers.Count) then begin
        LReceivers.Remove(AReceiver);
        if LReceivers.Count < 0 then begin
          FMsgTypeDic.Remove(AMsgType);
          LReceivers.Free;
        end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
