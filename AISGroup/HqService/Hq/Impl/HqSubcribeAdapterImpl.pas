unit HqSubcribeAdapterImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonRefCounter,
  HqSubcribeAdapter;

type

  // ���鶩������
  THqSubcribeAdapterImpl = class(TAutoInterfacedObject, IHqSubcribeAdapter)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqSubcribeAdapter }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
  end;

implementation

{ THqSubcribeAdapterImpl }

constructor THqSubcribeAdapterImpl.Create;
begin
  inherited;

end;

destructor THqSubcribeAdapterImpl.Destroy;
begin

  inherited;
end;

procedure THqSubcribeAdapterImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqSubcribeAdapterImpl.UnInitialize;
begin
  FAppContext := nil;
end;

end.
