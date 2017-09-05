unit PlugLoadMsgSysImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-29
// Comments��
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
    // ��ʼ��
    procedure DoInitialize; override;
    // �ͷŽӿ���Դ
    procedure DoUnInitialize; override;
    // ִ�в�������
    function DoOperateName: WideString; override;
    // ִ�в���ʵ�ַ���
    function DoExecuteOperate: Boolean; override;
  public
    // ���캯��
    constructor Create(AProducerID: Integer; AMsgType: TMsgType; AMsgInfo: string); override;
    // ��������
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
