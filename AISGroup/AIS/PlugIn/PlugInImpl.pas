unit PlugInImpl;

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
  AppContext;

type

  TPlugInImpl = class(TInterfacedObject, IPlugIn)
  private
  protected
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;

    { IPlugIn }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); virtual; safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; virtual; safecall;
    // �ǲ�����Ҫͬ�����ز���
    function IsNeedSync: WordBool; virtual; safecall;
    // ͬ��ʵ��
    procedure SyncExecuteOperate; virtual; safecall;
    // �첽ʵ�ֲ���
    procedure AsyncExecuteOperate; virtual; safecall;
    // ���������
    function PlugInClassName: WideString; virtual; safecall;
  end;

  // �����
  TPlugInImplClass = class of TPlugInImpl;

implementation

{ TPlugInImpl }

constructor TPlugInImpl.Create;
begin

end;

destructor TPlugInImpl.Destroy;
begin

  inherited;
end;

procedure TPlugInImpl.Initialize(AContext: IAppContext);
begin

end;

procedure TPlugInImpl.UnInitialize;
begin

end;

function TPlugInImpl.IsNeedSync: WordBool;
begin

end;

procedure TPlugInImpl.SyncExecuteOperate;
begin

end;

procedure TPlugInImpl.AsyncExecuteOperate;
begin

end;

function TPlugInImpl.PlugInClassName: WideString;
begin
  Result := Self.ClassName;
end;

end.
