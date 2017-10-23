unit HttpExecutor;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Executor Http Interface
// Author£º      lksoulman
// Date£º        2017-10-5
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  IdHTTP,
  Windows,
  Classes,
  SysUtils,
  ShareMgr;

type

  // Http Executor Interface
  IHttpExecutor = interface(IInterface)
    ['{72ED4BBB-5408-427E-A350-C0BC81C2ED76}']
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

end.
