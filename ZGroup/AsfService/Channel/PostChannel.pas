unit PostChannel;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Post Channel
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Channel,
  Windows,
  Classes,
  SysUtils,
  HttpContext,
  HttpExecutor,
  CommonObject,
  CommonRefCounter;

type

  // Post Channel
  TPostChannel = class(TChannel)
  private
  protected
  public
    // Up Stream
    procedure UpStream(AContext: THttpContext; AExecutor: IHttpExecutor); override;
    // Down Stream
    procedure DownStream(AContext: THttpContext; AExecutor: IHttpExecutor); override;
  end;

implementation

uses
  ElAES,
  ShareMgr,
  LogLevel,
  ErrorCode,
  IdExceptionCore;

{ TPostChannel }

procedure TPostChannel.UpStream(AContext: THttpContext; AExecutor: IHttpExecutor);
begin
  if AContext.GFDataUpdate.GetIsCancel then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Cancel);
  end;
  if AContext.GFDataUpdate.GetErrorCode <> ErrorCode_Success then Exit;

  if AExecutor.GetResponseStream.Size = 0 then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Response_DataIsNull);
  end;
end;

procedure TPostChannel.DownStream(AContext: THttpContext; AExecutor: IHttpExecutor);
begin
  if AContext.GFDataUpdate.GetIsCancel then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Cancel);
  end;
  if AContext.GFDataUpdate.GetErrorCode <> ErrorCode_Success then Exit;

  AExecutor.GetRequestStream.Position := 0;
  AExecutor.GetResponseStream.Size := 0;
  AExecutor.GetResponseStream.Position := 0;
  try
    AExecutor.GetIdHttp.Post(AExecutor.GetShareMgr.GetUrl, AExecutor.GetRequestStream,
      AExecutor.GetResponseStream);
  except
    on Ex: Exception do begin
      if Ex Is EIdSocksError then begin
        AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Network_Except);
      end else begin
        AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Post);
      end;
      if AExecutor.GetShareMgr.GetAppContext <> nil then begin
        AExecutor.GetShareMgr.GetAppContext.SysLog(llERROR,
          Format('[TPostChannel][DownStream] Post indicator %s is exception, exception is %s',
          [AContext.Indicator, Ex.Message]));
      end;
    end;
  end;
end;

end.
