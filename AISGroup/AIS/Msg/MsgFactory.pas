unit MsgFactory;

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
  MsgType;

type

  // 消息创建工厂
  TMsgFactory = class
  private
  protected
  public
    // 构造函数
    constructor Create;
    // 析构函数
    destructor Destroy; override;
    // 创建消息
    function CreateSysMsg(AProduceID: Integer; AMsgType: TMsgType; AMsgInfo: string): IMsgSys;
  end;

implementation

uses
  PlugLoadMsgSysImpl,
  NDayModifyPasswordMsgSysImpl,
  SecuBaseDataUpdateMsgSysImpl;

{ TMsgFactory }

constructor TMsgFactory.Create;
begin
  inherited;

end;

destructor TMsgFactory.Destroy;
begin

  inherited;
end;

function TMsgFactory.CreateSysMsg(AProduceID: Integer; AMsgType: TMsgType; AMsgInfo: string): IMsgSys;
begin
  case AMsgType of
    mtLoadPlugs:
      begin
        Result := TPlugLoadMsgSysImpl.Create(AProduceID, AMsgType, AMsgInfo) as IMsgSys;
      end;
    mtNDayModifyPassword:
      begin
        Result := TNDayModifyPasswordMsgSysImpl.Create(AProduceID, AMsgType, AMsgInfo) as IMsgSys;
      end;
    mtSecuBaseDataUpdate:
      begin
        Result := TSecuBaseDataUpdateMsgSysImpl.Create(AProduceID, AMsgType, AMsgInfo) as IMsgSys;
      end;
  end;
end;

end.
