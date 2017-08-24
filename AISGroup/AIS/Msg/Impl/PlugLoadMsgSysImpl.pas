unit PlugLoadMsgSysImpl;

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
  MsgSysImpl;

type

  TPlugLoadMsgSysImpl = class(TMsgSysImpl)
  protected
    // 初始化
    procedure DoInitialize; override;
    // 释放接口资源
    procedure DoUnInitialize; override;
    // 执行操作名称
    function DoOperateName: WideString; override;
    // 执行操作实现方法
    function DoExecuteOperate: Boolean; override;
  public
    // 构造函数
    constructor Create(AProducerID: Integer; AMsgType: TMsgType; AMsgInfo: string); override;
    // 析构函数
    destructor Destroy; override;
  end;

implementation

{ TPlugLoadMsgSysImpl }

constructor TPlugLoadMsgSysImpl.Create(AProducerID: Integer; AMsgType: TMsgType;
  AMsgInfo: string);
begin
  inherited Create(AProducerID, AMsgType, AMsgInfo);

end;

destructor TPlugLoadMsgSysImpl.Destroy;
begin

  inherited;
end;

procedure TPlugLoadMsgSysImpl.DoInitialize;
begin

end;

procedure TPlugLoadMsgSysImpl.DoUnInitialize;
begin

end;

function TPlugLoadMsgSysImpl.DoOperateName: WideString;
begin
  Result := '';
end;

function TPlugLoadMsgSysImpl.DoExecuteOperate: Boolean;
begin
  Result := False;
end;

end.
