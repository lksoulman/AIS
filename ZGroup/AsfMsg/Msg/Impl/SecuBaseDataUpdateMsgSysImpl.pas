unit SecuBaseDataUpdateMsgSysImpl;

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

  TSecuBaseDataUpdateMsgSysImpl = class(TMsgSysImpl)
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

{ TSecuBaseDataUpdateMsgSysImpl }

constructor TSecuBaseDataUpdateMsgSysImpl.Create(AProducerID: Integer;
  AMsgType: TMsgType; AMsgInfo: string);
begin
  inherited Create(AProducerID, AMsgType, AMsgInfo);

end;

destructor TSecuBaseDataUpdateMsgSysImpl.Destroy;
begin

  inherited;
end;

procedure TSecuBaseDataUpdateMsgSysImpl.DoInitialize;
begin

end;

procedure TSecuBaseDataUpdateMsgSysImpl.DoUnInitialize;
begin

end;

function TSecuBaseDataUpdateMsgSysImpl.DoOperateName: WideString;
begin
  Result := '';
end;

function TSecuBaseDataUpdateMsgSysImpl.DoExecuteOperate: Boolean;
begin
  Result := False;
end;

end.
