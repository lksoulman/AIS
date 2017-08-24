unit MsgSysImpl;

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
  AppContext;

type

  TMsgSysImpl = class(TInterfacedObject, IMsgSys)
  protected
    // 消息信息
    FMsgInfo: string;
    // 消息 ID
    FMsgType: TMsgType;
    //
    FProducerID: Integer;
    // 产生时间
    FProduceDate: TDateTime;
    // 应用接口
    FAppContext: IAppContext;

    // 初始化
    procedure DoInitialize; virtual;
    // 释放接口资源
    procedure DoUnInitialize; virtual;
    // 执行操作名称
    function DoOperateName: WideString; virtual;
    // 执行操作实现方法
    function DoExecuteOperate: Boolean; virtual;
  public
    // 构造函数
    constructor Create(AProducerID: Integer; AMsgType: TMsgType; AMsgInfo: string); virtual;
    // 析构函数
    destructor Destroy; override;

    { ISysMsg }

    // 初始化
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放接口资源
    procedure UnInitialize; safecall;
    // 消息类型
    function MsgType: TMsgType; safecall;
    // 消息信息
    function MsgInfo: WideString; safecall;
    // 消息产生者 ID
    function ProducerID: Integer; safecall;
    // 消息产生时间
    function ProduceDate: TDateTime; safecall;
    // 执行操作名称
    function OperateName: WideString; safecall;
    // 执行操作实现方法
    function ExecuteOperate: WordBool; safecall;
  end;


implementation

{ TMsgSysImpl }

constructor TMsgSysImpl.Create(AProducerID: Integer; AMsgType: TMsgType; AMsgInfo: string);
begin
  inherited Create;
  FMsgInfo := AMsgInfo;
  FMsgType := AMsgType;
  FProducerID := AProducerID;
  FProduceDate := Now;
end;

destructor TMsgSysImpl.Destroy;
begin

  inherited;
end;

procedure TMsgSysImpl.DoInitialize;
begin

end;

procedure TMsgSysImpl.DoUnInitialize;
begin

end;

function TMsgSysImpl.DoOperateName: WideString;
begin
  Result := '';
end;

function TMsgSysImpl.DoExecuteOperate: Boolean;
begin
  Result := False;
end;

procedure TMsgSysImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  DoInitialize;
end;

procedure TMsgSysImpl.UnInitialize;
begin
  DoUnInitialize;
  FAppContext := nil;
end;

function TMsgSysImpl.MsgInfo: WideString;
begin
  Result := FMsgInfo;
end;

function TMsgSysImpl.ProducerID: Integer;
begin
  Result := FProducerID;
end;

function TMsgSysImpl.MsgType: TMsgType;
begin
  Result := FMsgType;
end;

function TMsgSysImpl.ProduceDate: TDateTime;
begin
  Result := FProduceDate;
end;

function TMsgSysImpl.OperateName: WideString;
begin
  Result := DoOperateName;
end;

function TMsgSysImpl.ExecuteOperate: WordBool;
begin
  Result := DoExecuteOperate;
end;

end.
