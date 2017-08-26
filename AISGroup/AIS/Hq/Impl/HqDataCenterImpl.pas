unit HqDataCenterImpl;

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
  HqDataCenter,
  CommonRefCounter;

type

  // ���鶩������
  THqDataCenterImpl = class(TAutoInterfacedObject, IHqDataCenter)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IHqDataCenter }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
  end;

implementation

{ THqDataCenterImpl }

constructor THqDataCenterImpl.Create;
begin
  inherited;

end;

destructor THqDataCenterImpl.Destroy;
begin

  inherited;
end;

procedure THqDataCenterImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqDataCenterImpl.UnInitialize;
begin
  FAppContext := nil;
end;

end.
