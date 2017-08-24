unit ServiceAssetPlugInImpl;

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
  ServiceAsset;

type

  // �ʲ�GF���ݷ�����
  TServiceAssetPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // �ʲ�����ӿ�
    FServiceAsset: IServiceAsset;
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
  ServiceAssetImpl;

{ TServiceAssetPlugInImpl }

constructor TServiceAssetPlugInImpl.Create;
begin
  inherited;

end;

destructor TServiceAssetPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TServiceAssetPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FServiceAsset := TServiceAssetImpl.Create as IServiceAsset;
  (FServiceAsset as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IServiceAsset, FServiceAsset);
end;

procedure TServiceAssetPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IServiceAsset);
  (FServiceAsset as ISyncAsync).UnInitialize;
  FServiceAsset := nil;
  FAppContext := nil;
end;

function TServiceAssetPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TServiceAssetPlugInImpl.SyncExecuteOperate;
begin

end;

procedure TServiceAssetPlugInImpl.AsyncExecuteOperate;
begin

end;

end.

