unit GFDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Finance Data Interface implementation
// Author£º      lksoulman
// Date£º        2017-9-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  GFData,
  Windows,
  Classes,
  SysUtils,
  GFDataUpdate,
  ExecutorThread,
  CommonRefCounter;

type

  // Finance Data Interface implementation
  TGFDataImpl = class(TAutoInterfacedObject, IGFData, IGFDataUpdate)
  private
    // Key
    FKey: Int64;
    // Error Info
    FErrorInfo: string;
    // Error Code
    FErrorCode: Integer;
    // Is Canceled
    FIsCanceled: Boolean;
    // Response Stream
    FDataStream: TStream;
    // Request Size
    FRequestSize: Cardinal;
    // Request Compress Size
    FRequestCompressSize: Cardinal;
    // Response Size
    FResponseSize: Cardinal;
    // Response Compress Size
    FResponseCompressSize: Cardinal;
    // Queue Wait Use Time
    FQueueWaitUseTime: Cardinal;
    // Execute Post Use Time
    FExecutePostUseTime: Cardinal;
    // Request Compress Use Time
    FRequestCompressUseTime: Cardinal;
    // Response Uncompress Use Time
    FResponseUncompressUseTime: Cardinal;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { IGFData }

    // Get Key
    function GetKey: Int64; safecall;
    // Cancel
    function Cancel: Boolean; safecall;
    // Get Error Code
    function GetErrorCode: Integer; safecall;
    // Get Error Info
    function GetErrorInfo: WideString; safecall;
    // Get Data Stream
    function GetDataStream: TStream; safecall;
    // Get Request Size
    function GetRequestSize: Cardinal; safecall;
    // Get Request Compress Size
    function GetRequestCompressSize: Cardinal; safecall;
    // Get Compress Ratio
    function GetRequestCompressRatio: Double; safecall;
    // Get Response Size
    function GetResponseSize: Cardinal; safecall;
    // Get Response Compress Size
    function GetResponseCompressSize: Cardinal; safecall;
    // Get Compress Ratio
    function GetResponseCompressRatio: Double; safecall;
    // Get Queue Wait Use Time
    function GetQueueWaitUseTime: Cardinal; safecall;
    // Get Execute Post Use Time
    function GetExecutePostUseTime: Cardinal; safecall;
    // Get Request Compress Use Time
    function GetRequestCompressUseTime: Cardinal; safecall;
    // Get Response Uncompress Use Time
    function GetResponseUncompressUseTime: Cardinal; safecall;

    { IGFDataUpdate }

    // Get Is Canceled
    function GetIsCancel: Boolean; safecall;
    // Set Key
    function SetKey(AKey: Int64): Boolean; safecall;
    // Set Cancel
    function SetCancel(ACancel: Boolean = True): Boolean; safecall;
    // Set ErrorCode
    function SetErrorCode(AErrorCode: Integer): Boolean; safecall;
    // Set Error Info
    function SetErrorInfo(AErrorInfo: WideString): Boolean; safecall;
    // Set Response Stream
    function SetResponseStream(AResponseStream: TStream): Boolean; safecall;
    // Set Request Size
    function SetRequestSize(ASize: Cardinal): Boolean; safecall;
    // Set Request Compress Size
    function SetRequestCompressSize(ASize: Cardinal): Boolean; safecall;
    // Set Response Size
    function SetResponseSize(ASize: Cardinal): Boolean; safecall;
    // Set Response Compress Size
    function SetResponseCompressSize(ASize: Cardinal): Boolean; safecall;
    // Set Queue Wait Use Time
    function SetQueueWaitUseTime(AUseTime: Cardinal): Boolean; safecall;
    // Set Execute Post Use Time
    function SetExecutePostUseTime(AUseTime: Cardinal): Boolean; safecall;
    // Set Request Compress Use Time
    function SetRequestCompressUseTime(AUseTime: Cardinal): Boolean; safecall;
    // Set Response Uncompress Use Time
    function SetResponseUncompressUseTime(AUseTime: Cardinal): Boolean; safecall;
  end;

implementation

{ TGFDataImpl }

constructor TGFDataImpl.Create;
begin
  inherited;
  FKey := 0;
  FErrorCode := 0;
  FRequestSize := 0;
  FRequestCompressSize := 0;
  FResponseSize := 0;
  FResponseCompressSize := 0;
  FQueueWaitUseTime := 0;
  FExecutePostUseTime := 0;
  FRequestCompressUseTime := 0;
  FResponseUncompressUseTime := 0;
  FIsCanceled := False;
  FDataStream := TMemoryStream.Create;
end;

destructor TGFDataImpl.Destroy;
begin
  FDataStream.Free;
  inherited;
end;

function TGFDataImpl.GetKey: Int64;
begin
  Result := FKey;
end;

function TGFDataImpl.Cancel: Boolean;
begin
  Result := True;
  FIsCanceled := True;
end;

function TGFDataImpl.GetErrorCode: Integer;
begin
  Result := FErrorCode;
end;

function TGFDataImpl.GetErrorInfo: WideString;
begin
  Result := FErrorInfo;
end;

function TGFDataImpl.GetRequestCompressRatio: Double;
begin
  if FRequestSize = 0 then begin
    Result := 1.0;
  end else begin
    Result := FRequestCompressSize / FRequestSize;
  end;
end;

function TGFDataImpl.GetDataStream: TStream;
begin
  Result := FDataStream;
end;

function TGFDataImpl.GetRequestSize: Cardinal;
begin
  Result := FRequestSize;
end;

function TGFDataImpl.GetRequestCompressSize: Cardinal;
begin
  Result := FRequestCompressSize;
end;

function TGFDataImpl.GetResponseSize: Cardinal;
begin
  Result := FResponseSize;
end;

function TGFDataImpl.GetResponseCompressSize: Cardinal;
begin
  Result := FResponseCompressSize;
end;

function TGFDataImpl.GetResponseCompressRatio: Double;
begin
  if FResponseSize = 0 then begin
    Result := 1.0;
  end else begin
    Result := FResponseCompressSize / FResponseSize;
  end;
end;

function TGFDataImpl.GetQueueWaitUseTime: Cardinal;
begin
  Result := FQueueWaitUseTime;
end;

function TGFDataImpl.GetExecutePostUseTime: Cardinal;
begin
  Result := FExecutePostUseTime;
end;

function TGFDataImpl.GetRequestCompressUseTime: Cardinal;
begin
  Result := FRequestCompressUseTime;
end;

function TGFDataImpl.GetResponseUncompressUseTime: Cardinal;
begin
  Result := FResponseUncompressUseTime;
end;

function TGFDataImpl.SetCancel(ACancel: Boolean): Boolean;
begin
  FIsCanceled := True;
  Result := True;
end;

function TGFDataImpl.GetIsCancel: Boolean;
begin
  Result := FIsCanceled;
end;

function TGFDataImpl.SetKey(AKey: Int64): Boolean;
begin
  Result := True;
  FKey := AKey;
end;

function TGFDataImpl.SetErrorCode(AErrorCode: Integer): Boolean;
begin
  Result := True;
  FErrorCode := AErrorCode;
end;

function TGFDataImpl.SetErrorInfo(AErrorInfo: WideString): Boolean;
begin
  FErrorInfo := AErrorInfo;
end;

function TGFDataImpl.SetResponseStream(AResponseStream: TStream): Boolean;
begin
  AResponseStream.Position := 0;
  FDataStream.CopyFrom(AResponseStream, AResponseStream.Size);
  FDataStream.Position := 0;
end;

function TGFDataImpl.SetRequestSize(ASize: Cardinal): Boolean;
begin
  FRequestSize := ASize;
end;

function TGFDataImpl.SetRequestCompressSize(ASize: Cardinal): Boolean;
begin
  FRequestCompressSize := ASize;
end;

function TGFDataImpl.SetResponseSize(ASize: Cardinal): Boolean;
begin
  FResponseSize := ASize;
end;

function TGFDataImpl.SetResponseCompressSize(ASize: Cardinal): Boolean;
begin
  FResponseCompressSize := ASize;
end;

function TGFDataImpl.SetQueueWaitUseTime(AUseTime: Cardinal): Boolean;
begin
  FQueueWaitUseTime := AUseTime;
end;

function TGFDataImpl.SetExecutePostUseTime(AUseTime: Cardinal): Boolean;
begin
  FExecutePostUseTime := AUseTime;
end;

function TGFDataImpl.SetRequestCompressUseTime(AUseTime: Cardinal): Boolean;
begin
  FRequestCompressUseTime := AUseTime;
end;

function TGFDataImpl.SetResponseUncompressUseTime(AUseTime: Cardinal): Boolean;
begin
  FResponseUncompressUseTime := AUseTime;
end;

end.
