unit UrlInfoImpl;

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
  UrlInfo,
  Windows,
  Classes,
  SysUtils,
  NativeXml,
  AppContext,
  CommonRefCounter;

type

  TUrlInfoImpl = class(TAutoInterfacedObject, IUrlInfo)
  private
    // ���ӵ�ַ
    FUrl: string;
    // Web ID
    FWebID: Integer;
    // ����������
    FServerName: string;
    // ����
    FDescription: string;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { IWebInfo }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IInterface); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��ȡȥ url ��ַ
    function GetUrl: WideString; safecall;
    // ���� url
    procedure SetUrl(AUrl: WideString); safecall;
    // ��ȡ webID
    function GetWebID: Integer; safecall;
    // ���� webID
    procedure SetWebID(AWebID: Integer); safecall;
    // ��ȡ����������
    function GetServerName: WideString; safecall;
    // ���÷���������
    procedure SetServerName(AServerName: WideString); safecall;
    // ��ȡ����
    function GetDescription: WideString; safecall;
    // ��������
    procedure SetDescription(ADescription: WideString); safecall;
  end;

implementation

{ TUrlInfoImpl }

constructor TUrlInfoImpl.Create;
begin
  inherited;

end;

destructor TUrlInfoImpl.Destroy;
begin

  inherited;
end;

procedure TUrlInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
end;

procedure TUrlInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TUrlInfoImpl.GetUrl: WideString;
begin
  Result := FUrl;
end;

procedure TUrlInfoImpl.SetUrl(AUrl: WideString);
begin
  FUrl := AUrl;
end;

function TUrlInfoImpl.GetWebID: Integer;
begin
  Result := FWebID;
end;

procedure TUrlInfoImpl.SetWebID(AWebID: Integer);
begin
  FWebID := AWebID;
end;

function TUrlInfoImpl.GetServerName: WideString;
begin
  Result := FServerName;
end;

procedure TUrlInfoImpl.SetServerName(AServerName: WideString);
begin
  FServerName := AServerName;
end;

function TUrlInfoImpl.GetDescription: WideString;
begin
  Result := FDescription;
end;

procedure TUrlInfoImpl.SetDescription(ADescription: WideString);
begin
  FDescription := ADescription;
end;

end.
