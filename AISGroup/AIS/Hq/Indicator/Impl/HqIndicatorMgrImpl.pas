unit HqIndicatorMgrImpl;

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
  HqIndicatorMgr,
  CommonRefCounter;

type

  // ���鶩������
  THqIndicatorMgrImpl = class(TAutoInterfacedObject, IHqIndicatorMgr)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqIndicatorMgr }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
  end;

implementation

{ THqIndicatorMgrImpl }

constructor THqIndicatorMgrImpl.Create;
begin
  inherited;

end;

destructor THqIndicatorMgrImpl.Destroy;
begin

  inherited;
end;

procedure THqIndicatorMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqIndicatorMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

end.
