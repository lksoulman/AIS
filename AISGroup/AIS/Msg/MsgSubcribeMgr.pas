unit MsgSubcribeMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-29
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgSys,
  MsgType,
  MsgReceiver,
  Generics.Collections;

type

  TMsgSubcribeMgr = class
  private
    // 消息类型字典
    FMsgTypeDic: TDictionary<TMsgType, TList<IMsgReceiver>>;
  protected
    // 消息类型字典
    procedure DoClearMsgTypeDic;
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 消息派发
    procedure DispachMsg(ASysMsg: IMsgSys);
    // 订阅消息
    procedure Subcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver);
    // 取消订阅
    procedure DisSubcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver);
  end;

implementation

{ TMsgSubcribeMgr }

constructor TMsgSubcribeMgr.Create;
begin
  inherited;
  FMsgTypeDic := TDictionary<TMsgType, TList<IMsgReceiver>>.Create;
end;

destructor TMsgSubcribeMgr.Destroy;
begin
  FMsgTypeDic.Free;
  inherited;
end;

procedure TMsgSubcribeMgr.DoClearMsgTypeDic;
var
  LIndex: Integer;
  LList: TList<IMsgReceiver>;
  LEnum: TDictionary<TMsgType, TList<IMsgReceiver>>.TPairEnumerator;
begin
  LEnum := FMsgTypeDic.GetEnumerator;
  while LEnum.MoveNext do begin
    LList := LEnum.Current.Value;
    if (LList <> nil)
      and (LList.Count > 0) then begin
      LList.Clear;
    end;
  end;
end;

procedure TMsgSubcribeMgr.DispachMsg(ASysMsg: IMsgSys);
begin
  if ASysMsg = nil then Exit;

end;

procedure TMsgSubcribeMgr.Subcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver);
var
  LIndex: Integer;
  LList: TList<IMsgReceiver>;
begin
  if AMsgReceiver = nil then Exit;

  if FMsgTypeDic.TryGetValue(AMsgType, LList) and Assigned(LList) then begin
    LIndex := LList.IndexOf(AMsgReceiver);
    if (LIndex >= 0) and (LIndex < LList.Count) then begin
      LList.Items[LIndex] := AMsgReceiver;
    end else begin
      LList.Add(AMsgReceiver);
    end;
  end else begin
    LList := TList<IMsgReceiver>.Create;
    LList.Add(AMsgReceiver);
  end;
end;

procedure TMsgSubcribeMgr.DisSubcribe(AMsgType: TMsgType; AMsgReceiver: IMsgReceiver);
var
  LIndex: Integer;
  LList: TList<IMsgReceiver>;
begin
  if AMsgReceiver = nil then Exit;

  if FMsgTypeDic.TryGetValue(AMsgType, LList) and Assigned(LList) then begin
    LIndex := LList.IndexOf(AMsgReceiver);
    if (LIndex >= 0) and (LIndex < LList.Count) then begin
      LList.Remove(AMsgReceiver);
    end;
  end;
end;

end.
