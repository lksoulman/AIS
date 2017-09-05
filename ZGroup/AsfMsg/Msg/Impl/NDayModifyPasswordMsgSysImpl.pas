unit NDayModifyPasswordMsgSysImpl;

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

  TNDayModifyPasswordMsgSysImpl = class(TMsgSysImpl)
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

{ TNDayModifyPasswordMsgSysImpl }

constructor TNDayModifyPasswordMsgSysImpl.Create(AProducerID: Integer;
  AMsgType: TMsgType; AMsgInfo: string);
begin
  inherited Create(AProducerID, AMsgType, AMsgInfo);

end;

destructor TNDayModifyPasswordMsgSysImpl.Destroy;
begin

  inherited;
end;

procedure TNDayModifyPasswordMsgSysImpl.DoInitialize;
begin

end;

procedure TNDayModifyPasswordMsgSysImpl.DoUnInitialize;
begin

end;

function TNDayModifyPasswordMsgSysImpl.DoOperateName: WideString;
begin
  Result := '';
end;

function TNDayModifyPasswordMsgSysImpl.DoExecuteOperate: Boolean;
begin
  Result := False;
end;

end.
