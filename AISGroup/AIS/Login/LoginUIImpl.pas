unit LoginUIImpl;

interface

uses
  Windows,
  Classes,
  SysUtils,
  SyncAsync,
  LoginUI,
  AppContext,
  LoginMainUI;

type

  TLoginUIImpl = class(TInterfacedObject, ISyncAsync, ILoginUI)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ��¼������
    FLoginMainUI: TLoginMainUI;
  protected

  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { ISyncAsync }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // �ǲ��Ǳ���ͬ��ִ��
    function IsNeedSync: WordBool; safecall;
    // ͬ��ִ�з���
    procedure SyncExecute; safecall;
    // �첽ִ�з���
    procedure AsyncExecute; safecall;

    { ILoginUI }

    // չʾ��¼������
    procedure ShowLoginMainUI; safecall;
    // չʾ�󶨴���
    procedure ShowLoginBindUI; safecall;
    // չʾ��¼��Ϣ
    procedure ShowLoginInfo(AMsg: WideString); safecall;
    // ���õ�¼�ص�����
    procedure SetLoginFunc(ALoginFunc: TCallBackLoginFunc); safecall;
  end;

implementation

{ TLoginUIImpl }

constructor TLoginUIImpl.Create;
begin
  inherited;
  FLoginMainUI := TLoginMainUI.Create(nil);
end;

destructor TLoginUIImpl.Destroy;
begin
  FLoginMainUI.Free;
  inherited;
end;

procedure TLoginUIImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FLoginMainUI.Initialize(FAppContext);
end;

procedure TLoginUIImpl.UnInitialize;
begin
  FLoginMainUI.UnInitialize;
  FAppContext := nil;
end;

function TLoginUIImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TLoginUIImpl.SyncExecute;
begin
  ShowLoginMainUI;
end;

procedure TLoginUIImpl.AsyncExecute;
begin

end;

procedure TLoginUIImpl.ShowLoginMainUI;
begin
  FLoginMainUI.ShowLogin;
end;

procedure TLoginUIImpl.ShowLoginBindUI;
begin
  FLoginMainUI.ShowLoginBindUI(True);
end;

procedure TLoginUIImpl.ShowLoginInfo(AMsg: WideString);
begin
  FLoginMainUI.ShowLoginInfo(AMsg);
end;

procedure TLoginUIImpl.SetLoginFunc(ALoginFunc: TCallBackLoginFunc);
begin
  FLoginMainUI.SetLoginFunc(ALoginFunc);
end;

end.
