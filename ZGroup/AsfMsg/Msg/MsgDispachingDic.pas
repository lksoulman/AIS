unit MsgDispachingDic;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Message system Dispaching
// Author£º      lksoulman
// Date£º        2017-7-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  CommonRefCounter,
  Generics.Collections;

type

  // Message Dispaching Dictionary
  TMsgDispachingDic = class(TAutoObject)
  private
    // Thread lock
    FLock: TCSLock;
    // Message Dictionary
    FMsgExDic: TDictionary<Integer, TMsgEx>;
  protected
    // Remove Message
    procedure RemoveMsgEx(AMsgEx: TMsgEx);
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;
    // Add Message
    procedure AddMsgEx(AMsgEx: TMsgEx);
    // Get Message
    function GeTMsgEx(AId: Integer): TMsgEx;
  end;

implementation

uses
  MsgExImpl;

{ TMsgDispachingDic }

constructor TMsgDispachingDic.Create;
begin
  inherited;
  FMsgExDic := TDictionary<Integer, TMsgEx>.Create;
end;

destructor TMsgDispachingDic.Destroy;
begin
  FMsgExDic.Free;
  inherited;
end;

procedure TMsgDispachingDic.AddMsgEx(AMsgEx: TMsgEx);
var
  LMsgEx: TMsgEx;
begin
  if AMsgEx = nil then Exit;

  FLock.Lock;
  try
    if FMsgExDic.TryGetValue(TMsgExImpl(AMsgEx).GetId, LMsgEx)
      and (LMsgEx <> nil) then begin
      LMsgEx.Free;
    end;
    FMsgExDic.AddOrSetValue(TMsgExImpl(AMsgEx).GetId, AMsgEx);
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgDispachingDic.RemoveMsgEx(AMsgEx: TMsgEx);
begin
  FMsgExDic.Remove(TMsgExImpl(AMsgEx).GetId);
end;

function TMsgDispachingDic.GeTMsgEx(AId: Integer): TMsgEx;
begin
  FLock.Lock;
  try
    if FMsgExDic.TryGetValue(AId, Result)
      and (Result <> nil) then begin
      RemoveMsgEx(Result);
    end else begin
      Result := nil;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
