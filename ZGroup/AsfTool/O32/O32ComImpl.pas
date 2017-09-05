unit O32ComImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  O32Com,
  AppContext,
  SyncAsyncImpl,
  ExecutorThread;

type

  TO32ComImpl = class(TSyncAsyncImpl, IO32Com)
  private
    type
      PO32Record = ^TO32Record;
      TO32Record = packed record
        StockCode   : array[0..6] of Char;  //代码
        MarketNo    : Char;                 //市场
      end;
  private
    // 连接监控线程
    FConnectMonitorThread:  TExecutorThread;
  protected
    // 监控线程是不是连接
    procedure DoConnectMonitorThreadExecute(AObject: TObject);
  public
    // Constructor method
    constructor Create; override;
    // Destructor method
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Obtain dependency
    function Dependences: WideString; override;
  end;

implementation

uses
  FastLogLevel,
  FastLogSdkExport;

const

  SESSION_NAME           = 'FundLinkage';
  MSG_TYPE               = 'MsgType';
  MSG_TYPE_STOCK         = 'Stock';
  MSG_TYPE_OPERATOR      = 'Operator';
  SECUCODE               = 'StockCode';
  SECUMARKET             = 'MarketNo';


{ TO32ComImpl }

constructor TO32ComImpl.Create;
begin
  inherited;

end;

destructor TO32ComImpl.Destroy;
begin

  inherited;
end;

procedure TO32ComImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
  FConnectMonitorThread :=  TExecutorThread.Create;
  FConnectMonitorThread.ThreadMethod := DoConnectMonitorThreadExecute;
end;

procedure TO32ComImpl.UnInitialize;
begin
  if FConnectMonitorThread <> nil then begin
    FConnectMonitorThread.ShutDown;
  end;
  FAppContext := nil;
end;

procedure TO32ComImpl.SyncBlockExecute;
begin

end;

procedure TO32ComImpl.AsyncNoBlockExecute;
begin
  if FConnectMonitorThread <> nil then begin
    FConnectMonitorThread.StartEx;
  end;
end;

procedure TO32ComImpl.DoConnectMonitorThreadExecute(AObject: TObject);
var
  LThread: TExecutorThread;
begin
  if FAppContext <> nil then begin
    FastSysLog(llINFO, 'O32 Connect Thread Start');
  end;
  LThread := TExecutorThread(AObject);
  while not LThread.IsTerminated do begin

  end;
end;

function TO32ComImpl.Dependences: WideString;
begin
  Result := '';
end;

end.
