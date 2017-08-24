unit SecuBaseDataPlugInImpl;

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
  SecuBaseData;

type

  // ʵ������������ݲ��
  TSecuBaseDataPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ֤ȯ���ݽӿ�
    FSecuBaseData: ISecuBaseData;
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
  SecuBaseDataImpl;

{ TSecuBaseDataPlugInImpl }

constructor TSecuBaseDataPlugInImpl.Create;
begin
  inherited;

end;

destructor TSecuBaseDataPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TSecuBaseDataPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FSecuBaseData := TSecuBaseDataImpl.Create as ISecuBaseData;
  (FSecuBaseData as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ISecuBaseData, FSecuBaseData);
end;

procedure TSecuBaseDataPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ISecuBaseData);
  (FSecuBaseData as ISyncAsync).UnInitialize;
  FSecuBaseData := nil;
  FAppContext := nil;
end;

function TSecuBaseDataPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
  if FSecuBaseData = nil then Exit;

  Result := (FSecuBaseData as ISyncAsync).IsNeedSync;
end;

procedure TSecuBaseDataPlugInImpl.SyncExecuteOperate;
begin
  if FSecuBaseData = nil then Exit;

  (FSecuBaseData as ISyncAsync).SyncExecute;
end;

procedure TSecuBaseDataPlugInImpl.AsyncExecuteOperate;
begin
  if FSecuBaseData = nil then Exit;

  (FSecuBaseData as ISyncAsync).AsyncExecute;
end;

end.
