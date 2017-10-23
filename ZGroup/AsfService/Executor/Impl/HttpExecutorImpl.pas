unit HttpExecutorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Http Executor Interface Implementation
// Author£º      lksoulman
// Date£º        2017-9-14
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  IdHTTP,
  IdSocks,
  Channel,
  Windows,
  Classes,
  SysUtils,
  ShareMgr,
  HttpExecutor,
  IdSSLOpenSSLEx,
  ChannelPipeLine,
  CommonRefCounter,
  IdSSLOpenSSLHeadersEx;

type

  // Http Executor Interface Implementation
  THttpExecutorImpl = class(TAutoInterfacedObject, IHttpExecutor)
  private
  protected
    // Id Http
    FIdHttp: TIdHTTP;
    // Share Manager
    FShareMgr: IShareMgr;
    // Temp Stream
    FTempStream: TStream;
    // Request Stream
    FRequestStream: TStream;
    // Response Stream
    FResponseStream: TStream;
    // Id Socks Info
    FIdSocksInfo: TIdSocksInfo;
    // IO Handler
    FIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
    // Channel Pipe Line
    FChannelPipeLine: TChannelPipeLine;

    // Free Http
    procedure DoFreeHttp;
    // Create Http
    procedure DoCreateHttp;
    // Set Proxy
    procedure DoSetProxy;
    // Set Http Proxy
    procedure DoSetHttpProxy;
    // Set Socket Proxy
    procedure DoSetSocketProxy(AVersion: TSocksVersion);
  public
    // Constructor
    constructor Create(AShareMgr: IShareMgr); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IHttpExecutor }

    // Get IdHttp
    function GetIdHttp: TIdHTTP; safecall;
    // Get Share Manager
    function GetShareMgr: IShareMgr; safecall;
    // Get Temp Stream
    function GetTempStream: TStream; safecall;
    // Get Request Stream
    function GetRequestStream: TStream; safecall;
    // Get Response Stream
    function GetResponseStream: TStream; safecall;
    // Request Header Add Compress
    function SetRequestHeaderCompress: boolean; safecall;
    // Get Response Stream Is Compress
    function GetResponseHeaderCompress: Boolean; safecall;
    // Execute
    function Execute(AObject: TObject): Boolean; safecall;
    // Write Bytes To Request Stream
    procedure WriteBytesRequestStream(ABytes: TBytes; ACount: Integer); safecall;
    // Write Bytes To Request Stream
    procedure WriteStreamRequestStream(AStream: TStream; ACount: Integer); safecall;
    // Write Bytes To Response Stream
    procedure WriteStreamResponseStream(AStream: TStream; ACount: Integer); safecall;
  end;

implementation

uses
  LogLevel,
  ErrorCode,
  GFDataParser,
  IdExceptionCore,
  JsonChannelPipeLine;

{ THttpExecutorImpl }

constructor THttpExecutorImpl.Create(AShareMgr: IShareMgr);
begin
  inherited Create;
  FShareMgr := AShareMgr;
  FTempStream := TMemoryStream.Create;
  FRequestStream := TMemoryStream.Create;
  FResponseStream := TMemoryStream.Create;
  FChannelPipeLine := TJsonChannelPipeLine.Create;
end;

destructor THttpExecutorImpl.Destroy;
begin
  FChannelPipeLine.Free;
  FResponseStream.Free;
  FRequestStream.Free;
  FTempStream.Free;
  FShareMgr := nil;
  inherited;
end;

function THttpExecutorImpl.GetIdHttp: TIdHTTP;
begin
  Result := FIdHttp;
end;

function THttpExecutorImpl.GetShareMgr: IShareMgr;
begin
  Result := FShareMgr;
end;

function THttpExecutorImpl.GetTempStream: TStream;
begin
  Result := FTempStream;
end;

function THttpExecutorImpl.GetRequestStream: TStream;
begin
  Result := FRequestStream;
end;

function THttpExecutorImpl.GetResponseStream: TStream;
begin
  Result := FResponseStream;
end;

function THttpExecutorImpl.SetRequestHeaderCompress: Boolean;
begin
  if FIdHttp <> nil then begin
    FIdHttp.Request.CustomHeaders.Add('Encoding: GZIP');
  end;
end;

function THttpExecutorImpl.GetResponseHeaderCompress: Boolean;
begin
  if FIdHTTP.Response.RawHeaders.IndexOf('Encoding: GZIP') >=0 then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

function THttpExecutorImpl.Execute(AObject: TObject): Boolean;
begin
  Result := True;
  DoFreeHttp;
  DoCreateHttp;
  DoSetProxy;
  FChannelPipeLine.DownStream(AObject, Self);
  FChannelPipeLine.UpStream(AObject, Self);
end;

procedure THttpExecutorImpl.WriteBytesRequestStream(ABytes: TBytes; ACount: Integer);
begin
  if ACount <= 0 then Exit;

  FRequestStream.Size := 0;
  FRequestStream.Position := 0;
  FRequestStream.Write(ABytes, ACount);
end;

procedure THttpExecutorImpl.WriteStreamRequestStream(AStream: TStream; ACount: Integer);
begin
  if ACount <= 0 then Exit;

  AStream.Position := 0;
  FRequestStream.Size := 0;
  FRequestStream.Position := 0;
  FRequestStream.CopyFrom(AStream, ACount);
end;

procedure THttpExecutorImpl.WriteStreamResponseStream(AStream: TStream; ACount: Integer);
begin
  if ACount <= 0 then Exit;

  AStream.Position := 0;
  FResponseStream.Size := 0;
  FResponseStream.Position := 0;
  FResponseStream.CopyFrom(AStream, ACount);
end;

procedure THttpExecutorImpl.DoFreeHttp;
begin
  if FIOHandlerSocket <> nil then begin
    FIOHandlerSocket.Free;
    FIOHandlerSocket := nil;
  end;

  if FIdSocksInfo <> nil then begin
    FIdSocksInfo.Free;
    FIdSocksInfo := nil;
  end;

  if FIdHttp <> nil then begin
    FIdHttp.Free;
    FIdHttp := nil;
  end;
end;

procedure THttpExecutorImpl.DoCreateHttp;
begin
  FIdHttp := TIdHTTP.Create(nil);
  FIdHttp.Request.CustomHeaders.Clear;
  FIdHttp.HandleRedirects := true;
  FIdHttp.Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 5.00; Windows)';
  FIdHttp.HTTPOptions := FIdHttp.HTTPOptions + [hoKeepOrigProtocol];
  FIdHttp.Request.CharSet := 'utf-8';
  FIdHttp.Request.ContentEncoding := 'utf-8';
  FIdHttp.Request.ContentType := 'application/json';
  FIdHttp.Request.AcceptEncoding := '';
  FIdHttp.ReadTimeout := 1000 * 60 * 10;
end;

procedure THttpExecutorImpl.DoSetProxy;
begin
  case FShareMgr.GetProxy^.FType of
    ptSocket4:
      begin
        DoSetSocketProxy(svSocks4);
      end;
    ptSocket5:
      begin
        DoSetSocketProxy(svSocks5);
      end;
  else
    begin
      DoSetHttpProxy;
    end;
  end;
end;

procedure THttpExecutorImpl.DoSetHttpProxy;
begin
  FIdHttp.ProxyParams.ProxyServer := FShareMgr.GetProxy^.FIP;
  FIdHttp.ProxyParams.ProxyPort :=  FShareMgr.GetProxy^.FPort;
  FIdHttp.ProxyParams.ProxyUsername := FShareMgr.GetProxy^.FUserName;
  FIdHttp.ProxyParams.ProxyPassword := FShareMgr.GetProxy^.FPassword;
  FIdHttp.ProxyParams.BasicAuthentication := FShareMgr.GetProxy^.FUserName <> '';
end;

procedure THttpExecutorImpl.DoSetSocketProxy(AVersion: TSocksVersion);
begin
  FIdSocksInfo := TIdSocksInfo.Create(nil);
  FIdSocksInfo.Version := AVersion;
  FIdSocksInfo.Host := FShareMgr.GetProxy^.FIP;
  FIdSocksInfo.Port := FShareMgr.GetProxy^.FPort;
  FIdSocksInfo.Username := FShareMgr.GetProxy^.FUserName;
  FIdSocksInfo.Password := FShareMgr.GetProxy^.FPassword;
  if FShareMgr.GetProxy^.FUserName <> '' then begin
    FIdSocksInfo.Authentication := saUsernamePassword
  end else begin
    FIdSocksInfo.Authentication := saNoAuthentication;
  end;
  FIOHandlerSocket.TransparentProxy := FIdSocksInfo;
end;

end.
