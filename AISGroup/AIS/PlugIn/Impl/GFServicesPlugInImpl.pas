unit GFServicesPlugInImpl;

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugInImpl,
  AppContext,
  GFDataMngr_TLB;

type

  // GF ���ݷ���ӿ�ʵ��
  TGFServicesPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // GF ����ӿ�
    FGFDataManager: IGFDataManager;
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

{ TGFServicesPlugInImpl }

constructor TGFServicesPlugInImpl.Create;
begin
  inherited;

end;

destructor TGFServicesPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TGFServicesPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
//  FGFDataManager := IGFDataManager;
  FAppContext.RegisterInterface(IGFDataManager, FGFDataManager);
end;

procedure TGFServicesPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IGFDataManager);
  FGFDataManager := nil;
  FAppContext := nil;
end;

function TGFServicesPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TGFServicesPlugInImpl.SyncExecuteOperate;
begin
  if FGFDataManager = nil then Exit;

  FGFDataManager.StartService;
end;

procedure TGFServicesPlugInImpl.AsyncExecuteOperate;
begin

end;

end.
