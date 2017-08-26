unit CommandImpl;

interface

uses
  Command,
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter;

type

  // ����ӿڻ���ʵ��
  TCommandImpl = class(TAutoInterfacedObject, ICommand)
  private
  protected
    // Ȩ������
    FPermMask: Integer;
    // ���� ID
    FCommandID: Integer;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  public
    // ���캯��
    constructor Create(ACommandID, APermMask: Integer); virtual;
    // ��������
    destructor Destroy; override;

    { ICommand }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; virtual; safecall;
    // ���ü���
    procedure SetActive; virtual; safecall;
    // ���÷Ǽ���
    procedure SetNoActive; virtual; safecall;
    // ����ִ�з���
    procedure ExecCommand(APermMask: Integer; AParams: WideString); virtual; safecall;
  end;

  // ����ӿڻ�������
  TCommandImplClass = class of TCommandImpl;

implementation

{ TCommandImpl }

constructor TCommandImpl.Create(ACommandID, APermMask: Integer);
begin
  inherited Create;
  FPermMask := APermMask;
  FCommandID := ACommandID;
end;

destructor TCommandImpl.Destroy;
begin

  inherited;
end;

procedure TCommandImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TCommandImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TCommandImpl.SetActive;
begin

end;

procedure TCommandImpl.SetNoActive;
begin

end;

procedure TCommandImpl.ExecCommand(APermMask: Integer; AParams: WideString);
begin

end;

end.
