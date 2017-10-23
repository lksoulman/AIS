unit ServerInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Server Info Interface Implementation
// Author£º      lksoulman
// Date£º        2017-7-21
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Json,
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  ServerInfo,
  AppContext,
  CommonRefCounter;

type

  // Server Info Interface Implementation
  TServerInfoImpl = class(TAutoInterfacedObject, IServerInfo)
  private
    // Server Mame
    FServerName: string;
    // Server Index
    FServerIndex: Integer;
    // Attempt Count
    FAttemptCount: Integer;
    // Server List
    FServerList: TStringList;
    // Application Context Interface
    FAppContext: IAppContext;
  protected
  public
    // Constructor
    constructor Create(AServerName: string); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IServerInfo }

    // Init
    procedure Initialize(AContext: IInterface); safecall;
    // Un Init
    procedure UnInitialize; safecall;
    // Save Cache
    procedure SaveCache; safecall;
    // Load File
    procedure LoadFile(AFile: TIniFile); safecall;
    // Next
    procedure NextServer; safecall;
    // First
    procedure FirstServer; safecall;
    // Is EOF
    function IsEOF: boolean; safecall;
    // Get Server Index
    function GetServerIndex: Integer; safecall;
    // Get Server Url
    function GetServerUrl: WideString; safecall;
    // Get Server Urls
    function GetServerUrls: WideString; safecall;
    // Get Server Name
    function GetServerName: WideString; safecall;
  end;

implementation

uses
  Utils;

{ TServerInfoImpl }

constructor TServerInfoImpl.Create(AServerName: string);
begin
  inherited Create;
  FServerIndex := 0;
  FAttemptCount := 0;
  FServerName := AServerName;
  FServerList := TStringList.Create;
  FServerList.Delimiter := ';';
end;

destructor TServerInfoImpl.Destroy;
begin
  FServerList.Free;
  inherited;
end;

procedure TServerInfoImpl.Initialize(AContext: IInterface);
begin
  FAppContext := AContext as IAppContext;

end;

procedure TServerInfoImpl.UnInitialize;
begin

  FAppContext := nil;
end;

procedure TServerInfoImpl.SaveCache;
begin

end;

procedure TServerInfoImpl.LoadFile(AFile: TIniFile);
begin
  FServerList.DelimitedText := AFile.ReadString('ServerInfo', FServerName, '');
end;

procedure TServerInfoImpl.NextServer;
begin
  if FServerList.Count <= 0 then Exit;

  Inc(FAttemptCount);
  FServerIndex := (FServerIndex + 1) mod FServerList.Count;
end;

procedure TServerInfoImpl.FirstServer;
begin
  FAttemptCount := 0;
end;

function TServerInfoImpl.IsEOF: boolean;
begin
  Result := True;
  if FServerList.Count <= 0 then Exit;

  if FAttemptCount < FServerList.Count then begin
    Result := False;
  end else begin
    Result := True;
  end;
end;

function TServerInfoImpl.GetServerUrl: WideString;
begin
  if (FServerIndex >= 0) and (FServerIndex < FServerList.Count) then begin
    Result := FServerList.Strings[FServerIndex];
  end else begin
    Result := '';
  end;
end;

function TServerInfoImpl.GetServerUrls: WideString;
begin
  Result := FServerList.DelimitedText;
end;

function TServerInfoImpl.GetServerName: WideString;
begin
  Result := FServerName;
end;

function TServerInfoImpl.GetServerIndex: Integer;
begin
  Result := FServerIndex;
end;

end.
