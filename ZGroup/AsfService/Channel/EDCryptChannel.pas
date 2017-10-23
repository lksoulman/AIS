unit EDCryptChannel;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º EDCrypt Channel
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

  // Padding Type
  TPaddingType = (ptPKCS5,        // PKCS5
                  ptPKCS7         // PKCS7
                  );

  // EDCrypt Channel
  TEDCryptChannel = class(TChannel)
  private
  protected
    // Add Padding
    procedure AddPadding(APaddingType: TPaddingType; AStream: TStream);
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
  ErrorCode;

{ TEDCryptChannel }

procedure TEDCryptChannel.AddPadding(APaddingType: TPaddingType; AStream: TStream);
const
  BLOCKSIZE = 16;
var
  LIndex: Integer;
  LSurplusBlockSize: Integer;
begin
  if APaddingType = ptPKCS5 then begin
    LSurplusBlockSize := (AStream.Size mod BLOCKSIZE);
    LSurplusBlockSize := BLOCKSIZE - LSurplusBlockSize;
    AStream.Seek(0, soFromEnd);
    for LIndex := 1 to LSurplusBlockSize do begin
      AStream.Write(AnsiChar(LSurplusBlockSize), Sizeof(AnsiChar));
    end;
  end;
end;

procedure TEDCryptChannel.UpStream(AContext: THttpContext; AExecutor: IHttpExecutor);
var
  LTempStream: TStream;
begin
  if AContext.GFDataUpdate.GetIsCancel then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Cancel);
  end;
  if AContext.GFDataUpdate.GetErrorCode <> ErrorCode_Success then Exit;

  try
    LTempStream := AExecutor.GetTempStream;
    LTempStream.Size := 0;
    LTempStream.Position := 0;
    AddPadding(ptPKCS5, AExecutor.GetResponseStream);
    AExecutor.GetResponseStream.Position := 0;
    DecryptAESStreamECB(AExecutor.GetResponseStream, 0, AExecutor.GetShareMgr.GetAESKey128, LTempStream);
    AExecutor.WriteStreamResponseStream(LTempStream, LTempStream.Size);
  except
    on Ex: Exception do begin
      AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Response_Decrypt);
      if AExecutor.GetShareMgr.GetAppContext <> nil then begin
        AExecutor.GetShareMgr.GetAppContext.SysLog(llERROR,
          Format('[TEDCryptChannel][UpStream] DecryptAESStreamECB indicator %s stream is exception, exception is %s',[AContext.Indicator, Ex.Message]));
      end;
    end;
  end;
end;

procedure TEDCryptChannel.DownStream(AContext: THttpContext; AExecutor: IHttpExecutor);
var
  LTempStream: TStream;
begin
  if AContext.GFDataUpdate.GetIsCancel then begin
    AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Cancel);
  end;
  if AContext.GFDataUpdate.GetErrorCode <> ErrorCode_Success then Exit;

  try
    LTempStream := AExecutor.GetTempStream;
    LTempStream.Size := 0;
    LTempStream.Position := 0;
    AddPadding(ptPKCS5, AExecutor.GetRequestStream);
    AExecutor.GetRequestStream.Position := 0;
    EncryptAESStreamECB(AExecutor.GetRequestStream, 0, AExecutor.GetShareMgr.GetAESKey128, LTempStream);
    AExecutor.WriteStreamRequestStream(LTempStream, LTempStream.Size);
  except
    on Ex: Exception do begin
      AContext.GFDataUpdate.SetErrorCode(ErrorCode_Service_Request_Encrypt);
      if AExecutor.GetShareMgr.GetAppContext <> nil then begin
        AExecutor.GetShareMgr.GetAppContext.SysLog(llERROR,
          Format('[TEDCryptChannel][DownStream] EncryptAESStreamECB indicator %s stream is exception, exception is %s',[AContext.Indicator, Ex.Message]));
      end;
    end;
  end;
end;

end.
