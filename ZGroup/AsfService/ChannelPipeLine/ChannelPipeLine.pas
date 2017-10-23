unit ChannelPipeLine;

interface

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Channel Pipe Line
// Author£º      lksoulman
// Date£º        2017-9-29
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

uses
  Channel,
  Windows,
  Classes,
  SysUtils,
  HttpExecutor,
  CommonRefCounter;

type

  // Channel Pipe Line
  TChannelPipeLine = class(TAutoObject)
  private
  protected
    // Head Channel
    FHead: TChannel;
    // Tail Channel
    FTail: TChannel;

    // Init Pipe Line
    procedure DoInitPipeLine; virtual;
    // Un Init Pipe Line
    procedure DoUnInitPipeLine; virtual;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Add Channel
    procedure AddChannel(AChannel: TChannel);
    // Up Stream
    procedure UpStream(AObject: TObject; AExecutor: IHttpExecutor); virtual;
    // Down Stream
    procedure DownStream(AObject: TObject; AExecutor: IHttpExecutor); virtual;
  end;

implementation

uses
  HttpContext;

{ TChannelPipeLine }

constructor TChannelPipeLine.Create;
begin
  inherited;
  FHead := nil;
  FTail := nil;
  DoInitPipeLine;
end;

destructor TChannelPipeLine.Destroy;
begin
  DoUnInitPipeLine;
  FHead := nil;
  FTail := nil;
  inherited;
end;

procedure TChannelPipeLine.AddChannel(AChannel: TChannel);
begin
  if (FHead = nil) and (FHead = nil) then begin
    FHead := AChannel;
    FTail := AChannel;
  end else begin
    FTail.Next := AChannel;
    AChannel.Prev := FTail;
    FTail := AChannel;
  end;
end;

procedure TChannelPipeLine.DoInitPipeLine;
begin

end;

procedure TChannelPipeLine.DoUnInitPipeLine;
var
  LCurrChannel, LNextChannel: TChannel;
begin
  LNextChannel := FHead;
  while LNextChannel <> nil do begin
    LCurrChannel := LNextChannel;
    LNextChannel := LNextChannel.Next;
    LCurrChannel.Free;
  end;
end;

procedure TChannelPipeLine.UpStream(AObject: TObject; AExecutor: IHttpExecutor);
var
  LChannel: TChannel;
begin
  LChannel := FTail;
  while LChannel <> nil do begin
    LChannel.UpStream(THttpContext(AObject), AExecutor);
    LChannel := LChannel.Prev;
  end;
end;

procedure TChannelPipeLine.DownStream(AObject: TObject; AExecutor: IHttpExecutor);
var
  LChannel: TChannel;
begin
  LChannel := FHead;
  while LChannel <> nil do begin
    LChannel.DownStream(THttpContext(AObject), AExecutor);
    LChannel := LChannel.Next;
  end;
end;

end.
