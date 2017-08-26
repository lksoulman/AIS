unit UrlInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-25
// Comments：
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
    // 连接地址
    FUrl: string;
    // Web ID
    FWebID: Integer;
    // 服务器名称
    FServerName: string;
    // 描述
    FDescription: string;
    // 应用程序上下文接口
    FAppContext: IAppContext;
  protected
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { IWebInfo }

    // 初始化需要的资源
    procedure Initialize(AContext: IInterface); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 获取去 url 地址
    function GetUrl: WideString; safecall;
    // 设置 url
    procedure SetUrl(AUrl: WideString); safecall;
    // 获取 webID
    function GetWebID: Integer; safecall;
    // 设置 webID
    procedure SetWebID(AWebID: Integer); safecall;
    // 获取服务器名称
    function GetServerName: WideString; safecall;
    // 设置服务器名称
    procedure SetServerName(AServerName: WideString); safecall;
    // 获取描述
    function GetDescription: WideString; safecall;
    // 设置描述
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
