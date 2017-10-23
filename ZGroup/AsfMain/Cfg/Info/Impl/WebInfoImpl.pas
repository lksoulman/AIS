unit WebInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Web Info Interface Implementation
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  WebInfo,
  Windows,
  Classes,
  SysUtils,
  NativeXml,
  AppContext,
  CommonRefCounter;

type

  // Web Info Interface Implementation
  TWebInfoImpl = class(TAutoInterfacedObject, IWebInfo)
  private
    // Url
    FUrl: string;
    // Web ID
    FWebID: Integer;
    // Server Name
    FServerName: string;
    // Description
    FDescription: string;
    // Application Context Interface
    FAppContext: IAppContext;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IWebInfo }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IInterface);
    // Releasing resources(only execute once)
    procedure UnInitialize;
    // Get Url
    function GetUrl: WideString; safecall;
    // Set Url
    procedure SetUrl(AUrl: WideString); safecall;
    // Get WebID
    function GetWebID: Integer; safecall;
    // Set WebID
    procedure SetWebID(AWebID: Integer); safecall;
    // Get Server Name
    function GetServerName: WideString; safecall;
    // Set Server Name
    procedure SetServerName(AServerName: WideString); safecall;
    // Get Description
    function GetDescription: WideString; safecall;
    // Set Description
    procedure SetDescription(ADescription: WideString); safecall;
  end;

implementation

{ TWebInfoImpl }

constructor TWebInfoImpl.Create;
begin
  inherited;

end;

destructor TWebInfoImpl.Destroy;
begin

  inherited;
end;

procedure TWebInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;
end;

procedure TWebInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TWebInfoImpl.GetUrl: WideString;
begin
  Result := FUrl;
end;

procedure TWebInfoImpl.SetUrl(AUrl: WideString);
begin
  FUrl := AUrl;
end;

function TWebInfoImpl.GetWebID: Integer;
begin
  Result := FWebID;
end;

procedure TWebInfoImpl.SetWebID(AWebID: Integer);
begin
  FWebID := AWebID;
end;

function TWebInfoImpl.GetServerName: WideString;
begin
  Result := FServerName;
end;

procedure TWebInfoImpl.SetServerName(AServerName: WideString);
begin
  FServerName := AServerName;
end;

function TWebInfoImpl.GetDescription: WideString;
begin
  Result := FDescription;
end;

procedure TWebInfoImpl.SetDescription(ADescription: WideString);
begin
  FDescription := ADescription;
end;

end.
