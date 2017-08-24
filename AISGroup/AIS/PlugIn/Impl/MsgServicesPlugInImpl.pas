unit MsgServicesPlugInImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-20
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  MsgServices;

type

  // ��Ϣ����ӿڲ��
  TMsgServicesPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ֤ȯ���ݽӿ�
    FMsgServices: IMsgServices;
  protected
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { IPlugIn }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); override;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; override;
    // �ǲ�����Ҫͬ�����ز���
    function IsNeedSync: WordBool; override;
    // ͬ��ʵ��
    procedure SyncExecuteOperate; override;
    // �첽ʵ�ֲ���
    procedure AsyncExecuteOperate; override;
  end;

implementation

uses
  SyncAsync,
  MsgServicesImpl;

{ TMsgServicesPlugInImpl }

constructor TMsgServicesPlugInImpl.Create;
begin
  inherited;

end;

destructor TMsgServicesPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TMsgServicesPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FMsgServices := TMsgServicesImpl.Create as IMsgServices;
  (FMsgServices as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IMsgServices, FMsgServices);
end;

procedure TMsgServicesPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IMsgServices);
  (FMsgServices as ISyncAsync).UnInitialize;
  FMsgServices := nil;
  FAppContext := nil;
end;

function TMsgServicesPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
  if FMsgServices = nil then Exit;

  Result := (FMsgServices as ISyncAsync).IsNeedSync;
end;

procedure TMsgServicesPlugInImpl.SyncExecuteOperate;
begin
  if FMsgServices = nil then Exit;

  (FMsgServices as ISyncAsync).SyncExecute;
end;

procedure TMsgServicesPlugInImpl.AsyncExecuteOperate;
begin
  if FMsgServices = nil then Exit;

  (FMsgServices as ISyncAsync).AsyncExecute;
end;

end.
