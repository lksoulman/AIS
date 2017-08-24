unit MsgSysImpl;

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
  AppContext;

type

  TMsgSysImpl = class(TInterfacedObject, IMsgSys)
  protected
    // ��Ϣ��Ϣ
    FMsgInfo: string;
    // ��Ϣ ID
    FMsgType: TMsgType;
    //
    FProducerID: Integer;
    // ����ʱ��
    FProduceDate: TDateTime;
    // Ӧ�ýӿ�
    FAppContext: IAppContext;

    // ��ʼ��
    procedure DoInitialize; virtual;
    // �ͷŽӿ���Դ
    procedure DoUnInitialize; virtual;
    // ִ�в�������
    function DoOperateName: WideString; virtual;
    // ִ�в���ʵ�ַ���
    function DoExecuteOperate: Boolean; virtual;
  public
    // ���캯��
    constructor Create(AProducerID: Integer; AMsgType: TMsgType; AMsgInfo: string); virtual;
    // ��������
    destructor Destroy; override;

    { ISysMsg }

    // ��ʼ��
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŽӿ���Դ
    procedure UnInitialize; safecall;
    // ��Ϣ����
    function MsgType: TMsgType; safecall;
    // ��Ϣ��Ϣ
    function MsgInfo: WideString; safecall;
    // ��Ϣ������ ID
    function ProducerID: Integer; safecall;
    // ��Ϣ����ʱ��
    function ProduceDate: TDateTime; safecall;
    // ִ�в�������
    function OperateName: WideString; safecall;
    // ִ�в���ʵ�ַ���
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
