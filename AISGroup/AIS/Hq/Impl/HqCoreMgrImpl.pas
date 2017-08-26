unit HqCoreMgrImpl;

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
  HqCoreMgr,
  SyncAsync,
  AppContext,
  HqDataCenter,
  HqIndicatorMgr,
  CommonRefCounter,
  HqSubcribeAdapter;

type

  // ������Ĺ�����
  THqCoreMgrImpl = class(TAutoInterfacedObject, ISyncAsync, IHqCoreMgr)
  private
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
    // �������Ľӿ�
    FHqDataCenter: IHqDataCenter;
    // ָ�����ӿ�
    FHqIndicatorMgr: IHqIndicatorMgr;
    // �����������ӿ�
    FHqSubcribeAdapter: IHqSubcribeAdapter;
  protected
  public
    // ���캯��
    constructor Create; override;
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

    { IHqCoreMgr }

    // ��ȡ�������Ľӿ�
    function GetHqDataCenter: IHqDataCenter; safecall;
    // ��ȡָ�����ӿ�
    function GetHqIndicatorMgr: IHqIndicatorMgr; safecall;
    // ��ȡ�����������ӿ�
    function GetHqSubcribeAdapter: IHqSubcribeAdapter; safecall;
  end;

implementation

{ THqCoreMgrImpl }

constructor THqCoreMgrImpl.Create;
begin
  inherited;

end;

destructor THqCoreMgrImpl.Destroy;
begin

  inherited;
end;

procedure THqCoreMgrImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure THqCoreMgrImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function THqCoreMgrImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure THqCoreMgrImpl.SyncExecute;
begin

end;

procedure THqCoreMgrImpl.AsyncExecute;
begin

end;

function THqCoreMgrImpl.GetHqDataCenter: IHqDataCenter;
begin
  Result := FHqDataCenter;
end;

function THqCoreMgrImpl.GetHqIndicatorMgr: IHqIndicatorMgr;
begin
  Result := FHqIndicatorMgr;
end;

function THqCoreMgrImpl.GetHqSubcribeAdapter: IHqSubcribeAdapter;
begin
  Result := FHqSubcribeAdapter;
end;

end.
