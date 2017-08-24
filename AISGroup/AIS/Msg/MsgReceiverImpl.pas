unit MsgReceiverImpl;

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
  MsgType,
  MsgReceiver;

type

  TMsgReceiverImpl = class(TInterfacedObject, IMsgReceiver)
  private
    // ��ʶ ID
    FID: Integer;
    // �ǲ��Ǽ���
    FActive: Boolean;
    // �ص�����
    FCallBackFunc: TMsgCallBackFunc;
  protected
  public
    // ���캯��
    constructor Create(AID: Integer; ACallBack: TMsgCallBackFunc); virtual;
    // ��������
    destructor Destroy; override;

    { IMsgReceiver }

    // ��Ϣ�����ߵ�״̬
    function Active: Wordbool; safecall;
    // ��ȡ�����ߵ�ID
    function GetReceiverID: Integer; safecall;
    // ������Ϣ�����ߵ�״̬
    procedure SetActive(Active: Wordbool); safecall;
    // ������Ϣ����
    procedure Receive(AProdurerID: Integer; AMsgType: TMsgType; AMsgInfo: WideString); safecall;
  end;

implementation

uses
  FastLogLevel;

{ TMsgReceiverImpl }

constructor TMsgReceiverImpl.Create(AID: Integer; ACallBack: TMsgCallBackFunc);
begin
  inherited Create;

  FCallBackFunc := ACallBack;
end;

destructor TMsgReceiverImpl.Destroy;
begin
  FCallBackFunc := nil;
  inherited;
end;

function TMsgReceiverImpl.Active: Wordbool;
begin
  Result := FActive;
end;

function TMsgReceiverImpl.GetReceiverID: Integer;
begin
  Result := FID;
end;

procedure TMsgReceiverImpl.SetActive(Active: Wordbool);
begin
  FActive := Active;
end;

procedure TMsgReceiverImpl.Receive(AProdurerID: Integer; AMsgType: TMsgType; AMsgInfo: WideString);
var
  LLogTag: string;
begin
  if Assigned(FCallBackFunc) then begin
    LLogTag := '';
    try
      FCallBackFunc(AMsgType, AMsgInfo, LLogTag);
    except
      on Ex: Exception do begin
        FastAppLog(llError, '[TMsgReceiverImpl.Receive] Exception is ' + Ex.ToString
          + ',and LogTag = ' + LLogTag + ' ReceiverID = ' + IntToStr(FID));
      end;
    end;
  end;
end;

end.
