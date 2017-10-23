unit CompressChannel;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Compress Channel
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

  // Compress Channel
  TCompressChannel = class(TChannel)
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
  IdZLib,
  LogLevel,
  ErrorCode,
  IdZLibHeaders;

const
  MIN_COMPRESS_SIZE = 1024 * 1024 * 5;

{ TCompressChannel }

procedure TCompressChannel.UpStream(AContext: THttpContext; AExecutor: IHttpExecutor);
var
  LTempStream: TStream;
begin
  if AContext.GFDataUpdate.GetIsCancel then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Cancel);
  end;
  if AContext.GFDataUpdate.GetErrorCode <> ErrorCode_Success then Exit;

  AContext.GFDataUpdate.SetResponseCompressSize(AExecutor.GetResponseStream.Size);
  if AExecutor.GetResponseHeaderCompress then begin
    try
      LTempStream := AExecutor.GetTempStream;
      LTempStream.Size := 0;
      LTempStream.Position := 0;
      AExecutor.GetResponseStream.Position := 0;
      IdZLib.DecompressStream(AExecutor.GetResponseStream, LTempStream);
      AExecutor.WriteStreamResponseStream(LTempStream, LTempStream.Size);
      AContext.GFDataUpdate.SetResponseSize(LTempStream.Size);
    except
      on Ex: Exception do begin
        AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Response_Uncompress);
        if AExecutor.GetShareMgr.GetAppContext <> nil then begin
          AExecutor.GetShareMgr.GetAppContext.SysLog(llERROR,
            Format('[TCompressChannel][UpStream] IdZLib.DecompressStream indicator %s stream is exception, exception is %s',[AContext.Indicator, Ex.Message]));
        end;
      end;
    end;
  end else begin
    AContext.GFDataUpdate.SetResponseSize(AExecutor.GetResponseStream.Size);
  end;
end;

procedure TCompressChannel.DownStream(AContext: THttpContext; AExecutor: IHttpExecutor);
var
  LTempStream: TStream;
begin
  if AContext.GFDataUpdate.GetIsCancel then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Cancel);
  end;
  if AContext.GFDataUpdate.GetErrorCode <> ErrorCode_Success then Exit;

  AContext.GFDataUpdate.SetRequestSize(AExecutor.GetRequestStream.Size);
  if AExecutor.GetRequestStream.Size >= MIN_COMPRESS_SIZE then begin
    try
      AExecutor.SetRequestHeaderCompress;
      LTempStream := AExecutor.GetTempStream;
      LTempStream.Size := 0;
      LTempStream.Position := 0;
      AExecutor.GetRequestStream.Position := 0;
      IdZLib.CompressStream(AExecutor.GetRequestStream, LTempStream, clDefault, zsGZip);
      AExecutor.WriteStreamRequestStream(LTempStream, LTempStream.Size);
      AContext.GFDataUpdate.SetRequestCompressSize(LTempStream.Size);
    except
      on Ex: Exception do begin
        AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Compress);
        if AExecutor.GetShareMgr.GetAppContext <> nil then begin
          AExecutor.GetShareMgr.GetAppContext.SysLog(llERROR,
            Format('[TCompressChannel][DownStream] IdZLib.CompressStream indicator %s stream is exception, exception is %s',[AContext.Indicator, Ex.Message]));
        end;
      end;
    end;
  end else begin
    AContext.GFDataUpdate.SetRequestCompressSize(AExecutor.GetRequestStream.Size);
  end;
end;

end.
