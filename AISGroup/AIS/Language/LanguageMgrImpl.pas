unit LanguageMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-21
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Language,
  SyncAsync,
  AppContext,
  LanguageMgr,
  LanguageType,
  CommonRefCounter;

type

  TLanguageMgrImpl = class(TAutoInterfacedObject, ISyncAsync, ILanguageMgr)
  private
    // ���԰�
    FLanguage: TLanguage;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // ��������
    FLanguageType: TLanguageType;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

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

    { ILanguageMgr }

    // �л����԰�
    procedure ChangeLanguage; safecall;
  end;

implementation

{ TLanguageMgrImpl }

constructor TLanguageMgrImpl.Create;
begin
  inherited;

end;

destructor TLanguageMgrImpl.Destroy;
begin

  inherited;
end;

procedure TLanguageMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TLanguageMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TLanguageMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TLanguageMgrImpl.SyncExecute;
begin

end;

procedure TLanguageMgrImpl.AsyncExecute;
begin

end;

procedure TLanguageMgrImpl.ChangeLanguage;
begin

end;

end.
