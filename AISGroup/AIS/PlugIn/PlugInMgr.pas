unit PlugInMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-16
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  PlugIn,
  AppContext,
  PlugInImpl,
  ExecutorThread,
  Generics.Collections;

type

  TPlugInMgr = class
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ����ӿ�
    FPlugIns: TList<IPlugIn>;
    // ���������
    FPlugInClazzs: TList<TPlugInImplClass>;
    // �첽ִ���߳�
    FASyncThread: TExecutorThread;
  protected
    // ��ʼ�����в��
    procedure DoInitializePlugIns;
    // ��պ��ͷŲ��
    procedure DoUnInitializePlugIns;
    // �첽ִ���̷߳���
    procedure DoAsyncThreadExecute(AObject: TObject);
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ͬ��ִ�в��
    procedure SyncExecutePlugIns;
    // �첽ִ�в��
    procedure AsyncExecutePlugIns;
  end;

implementation

uses
  ConfigPlugInImpl,
  LoginMgrPlugInImpl,
  CipherMgrPlugInImpl,
  MsgServicesPlugInImpl,
  ServiceBasePlugInImpl,
  ServiceAssetPlugInImpl,
  SecuBaseDataPlugInImpl,
  CacheBaseDataPlugInImpl,
  CacheUserDataPlugInImpl,
  PermissionMgrPlugInImpl;

{ TPlugInMgr }

constructor TPlugInMgr.Create;
begin
  inherited;
  FPlugIns := TList<IPlugIn>.Create;
  FASyncThread := TExecutorThread.Create;
  FPlugInClazzs := TList<TPlugInImplClass>.Create;

  FPlugInClazzs.Add(TCipherMgrPlugInImpl);
  FPlugInClazzs.Add(TConfigPlugInImpl);
  FPlugInClazzs.Add(TServiceBasePlugInImpl);
  FPlugInClazzs.Add(TServiceAssetPlugInImpl);
  FPlugInClazzs.Add(TLoginMgrPlugInImpl);
  FPlugInClazzs.Add(TPermissionMgrPlugInImpl);
  FPlugInClazzs.Add(TCacheBaseDataPlugInImpl);
  FPlugInClazzs.Add(TCacheUserDataPlugInImpl);
end;

destructor TPlugInMgr.Destroy;
begin
  FPlugInClazzs.Free;
  FPlugIns.Free;
  inherited;
end;

procedure TPlugInMgr.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  DoInitializePlugIns;
end;

procedure TPlugInMgr.UnInitialize;
begin
  DoUnInitializePlugIns;
  FAppContext := nil;
end;

procedure TPlugInMgr.DoInitializePlugIns;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FPlugInClazzs.Count - 1 do begin
    FPlugIns.Add(FPlugInClazzs[LIndex].Create as IPlugIn);
    FPlugIns.Items[LIndex].Initialize(FAppContext);
  end;

  for LIndex := 0 to FPlugInClazzs.Count - 1 do begin
    if FPlugIns.Items[LIndex].IsNeedSync then begin
      FPlugIns.Items[LIndex].SyncExecuteOperate;
    end;
  end;
end;

procedure TPlugInMgr.DoUnInitializePlugIns;
var
  LIndex: Integer;
  LPlugIn: IPlugIn;
begin
  for LIndex := FPlugIns.Count - 1 downto 0 do begin
    LPlugIn := FPlugIns.Items[LIndex];
    if LPlugIn <> nil then begin
      FPlugIns.Items[LIndex] := nil;
      LPlugIn.UnInitialize;
      LPlugIn := nil;
    end;
  end;
  FPlugIns.Clear;
end;

procedure TPlugInMgr.SyncExecutePlugIns;
begin

end;

procedure TPlugInMgr.AsyncExecutePlugIns;
begin

end;

procedure TPlugInMgr.DoAsyncThreadExecute(AObject: TObject);
begin

end;

end.
