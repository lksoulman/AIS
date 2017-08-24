unit ConfigPlugInImpl;

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
  Config,
  PlugInImpl,
  AppContext;

type

  // ���ýӿڲ��
  TConfigPlugInImpl = class(TPlugInImpl)
  private
    // ���ýӿ�
    FConfig: IConfig;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
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
  ConfigImpl;

{ TConfigPlugInImpl }

constructor TConfigPlugInImpl.Create;
begin
  inherited;

end;

destructor TConfigPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TConfigPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FConfig := TConfigImpl.Create as IConfig;
  (FConfig as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IConfig, FConfig);
end;

procedure TConfigPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IConfig);
  (FConfig as ISyncAsync).UnInitialize;
  FConfig := nil;
  FAppContext := nil;
end;

function TConfigPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TConfigPlugInImpl.SyncExecuteOperate;
begin
  if FConfig = nil then Exit;
  
  (FConfig as ISyncAsync).SyncExecute;
end;

procedure TConfigPlugInImpl.AsyncExecuteOperate;
begin
  if FConfig = nil then Exit;

  (FConfig as ISyncAsync).AsyncExecute;
end;

end.
