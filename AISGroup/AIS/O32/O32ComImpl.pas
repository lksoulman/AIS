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
  SyncAsync,
  AppContext,
  ExecutorThread,
  CommonRefCounter;

type

  TO32ComImpl = class(TAutoInterfacedObject, ISyncAsync, IO32Com)
  private
    type
      PO32Record = ^TO32Record;
      TO32Record = packed record
        StockCode   : array[0..6] of Char;  //代码
        MarketNo    : Char;                 //市场
      end;
  private
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 连接监控线程
    FConnectMonitorThread:  TExecutorThread;
  protected
    // 监控线程是不是连接
    procedure DoConnectMonitorThreadExecute(AObject: TObject);
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;

    { ISyncAsync }

    // 初始化需要的资源
    procedure Initialize(AContext: IAppContext); safecall;
    // 释放不需要的资源
    procedure UnInitialize; safecall;
    // 是不是必须同步执行
    function IsNeedSync: WordBool; safecall;
    // 同步执行方法
    procedure SyncExecute; safecall;
    // 异步执行方法
    procedure AsyncExecute; safecall;
  end;

implementation

uses
  FastLogLevel;

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

function TO32ComImpl.IsNeedSync: WordBool;
begin
  Result := False;
end;

procedure TO32ComImpl.SyncExecute;
begin

end;

procedure TO32ComImpl.AsyncExecute;
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
    FAppContext.AppLog(llINFO, 'O32 Connect Thread Start');
  end;
  LThread := TExecutorThread(AObject);
  while not LThread.IsTerminated do begin

  end;
end;

end.
