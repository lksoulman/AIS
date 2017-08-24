unit MsgReceiverImpl;

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
  MsgType,
  MsgReceiver;

type

  TMsgReceiverImpl = class(TInterfacedObject, IMsgReceiver)
  private
    // 标识 ID
    FID: Integer;
    // 是不是激活
    FActive: Boolean;
    // 回调方法
    FCallBackFunc: TMsgCallBackFunc;
  protected
  public
    // 构造函数
    constructor Create(AID: Integer; ACallBack: TMsgCallBackFunc); virtual;
    // 析构函数
    destructor Destroy; override;

    { IMsgReceiver }

    // 消息接收者的状态
    function Active: Wordbool; safecall;
    // 获取接收者的ID
    function GetReceiverID: Integer; safecall;
    // 设置消息接收者的状态
    procedure SetActive(Active: Wordbool); safecall;
    // 接收消息方法
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
