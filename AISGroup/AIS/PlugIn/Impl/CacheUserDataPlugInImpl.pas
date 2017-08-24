unit CacheUserDataPlugInImpl;

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
  CacheUserData;

type

  // �û��������ݲ��
  TCacheUserDataPlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // �û��������ݽӿ�
    FCacheUserData: ICacheUserData;
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
  CacheUserDataImpl;

{ TCacheUserDataPlugInImpl }

constructor TCacheUserDataPlugInImpl.Create;
begin
  inherited;

end;

destructor TCacheUserDataPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TCacheUserDataPlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FCacheUserData := TCacheUserDataImpl.Create as ICacheUserData;
  (FCacheUserData as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(ICacheUserData, FCacheUserData);
end;

procedure TCacheUserDataPlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(ICacheUserData);
  (FCacheUserData as ISyncAsync).UnInitialize;
  FCacheUserData := nil;
  FAppContext := nil;
end;

function TCacheUserDataPlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
  if FCacheUserData = nil then Exit;

  Result := (FCacheUserData as ISyncAsync).IsNeedSync;
end;

procedure TCacheUserDataPlugInImpl.SyncExecuteOperate;
begin
  if FCacheUserData = nil then Exit;

  (FCacheUserData as ISyncAsync).SyncExecute;
end;

procedure TCacheUserDataPlugInImpl.AsyncExecuteOperate;
begin
  if FCacheUserData = nil then Exit;

  (FCacheUserData as ISyncAsync).AsyncExecute;
end;

end.
