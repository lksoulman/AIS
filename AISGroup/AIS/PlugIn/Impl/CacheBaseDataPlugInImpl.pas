unit CacheBaseDataPlugInImpl;

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
  CacheBaseData;

type

  // ʵ�ֻ������ݲ��
  TCacheBaseDataPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ֤ȯ���ݽӿ�
    FCacheBaseData: ICacheBaseData;
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
  CacheBaseDataImpl;

{ TCacheBaseDataPlugInImpl }

constructor TCacheBaseDataPlugInImpl.Create;
begin
  inherited;

end;

destructor TCacheBaseDataPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TCacheBaseDataPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FCacheBaseData := TCacheBaseDataImpl.Create as ICacheBaseData;
  (FCacheBaseData as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICacheBaseData, FCacheBaseData);
end;

procedure TCacheBaseDataPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICacheBaseData);
  (FCacheBaseData as ISyncAsync).UnInitialize;
  FCacheBaseData := nil;
  FAppContext := nil;
end;

function TCacheBaseDataPlugInImpl.IsNeedSync: WordBool;
begin
  Result := False;
  if FCacheBaseData = nil then Exit;

  Result := (FCacheBaseData as ISyncAsync).IsNeedSync;
end;

procedure TCacheBaseDataPlugInImpl.SyncExecuteOperate;
begin
  if FCacheBaseData = nil then Exit;

  (FCacheBaseData as ISyncAsync).SyncExecute;
end;

procedure TCacheBaseDataPlugInImpl.AsyncExecuteOperate;
begin
  if FCacheBaseData = nil then Exit;

  (FCacheBaseData as ISyncAsync).AsyncExecute;
end;

end.
