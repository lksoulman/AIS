unit ServiceBasePlugInImpl;

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
  ServiceBase;

type

  // �ʲ�GF���ݷ�����
  TServiceBasePlugInImpl = class(TPlugInImpl)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // �ʲ�����ӿ�
    FServiceBase: IServiceBase;
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
  ServiceBaseImpl;

{ TServiceBasePlugInImpl }

constructor TServiceBasePlugInImpl.Create;
begin
  inherited;

end;

destructor TServiceBasePlugInImpl.Destroy;
begin

  inherited;
end;

procedure TServiceBasePlugInImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FServiceBase := TServiceBaseImpl.Create as IServiceBase;
  (FServiceBase as ISyncAsync).Initialize(FAppContext);
  FAppContext.RegisterInterface(IServiceBase, FServiceBase);
end;

procedure TServiceBasePlugInImpl.UnInitialize;
begin
  FAppContext.UnRegisterInterface(IServiceBase);
  (FServiceBase as ISyncAsync).UnInitialize;
  FServiceBase := nil;
  FAppContext := nil;
end;

function TServiceBasePlugInImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TServiceBasePlugInImpl.SyncExecuteOperate;
begin

end;

procedure TServiceBasePlugInImpl.AsyncExecuteOperate;
begin

end;

end.
