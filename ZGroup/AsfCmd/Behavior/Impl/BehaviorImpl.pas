unit BehaviorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Behavior Interface implementation
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Behavior,
  AppContext,
  CommonQueue,
  BehaviorItem,
  SyncAsyncImpl,
  ExecutorThread,
  BehaviorItemPool;

type

  // Behavior Interface implementation
  TBehaviorImpl = class(TSyncAsyncImpl, IBehavior)
  private
    // File
    FFile: string;
    // 行为字符串
    FBehaviorStrs: TStringList;
    // 用户行为处理数据上传线程
    FBehaviorThread: TExecutorThread;
    // 行为对象池
    FBehaviorItemPool: TBehaviorItemPool;
    // 添加队列
    FBehaviorQuene: TSafeSemaphoreQueue<PBehaviorItem>;
  protected
    // 保存数据到本地
    procedure DoSaveCache(AThread: TExecutorThread);
    // 上传数据到服务端
    procedure DoUploadBehaviors(AThread: TExecutorThread);
    // 用户行为处理数据上传线程方法
    procedure DoHandleBehaviorThreadExecute(AObject: TObject);
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISyncAsync }

    // Initialize Resources(only execute once)
    procedure Initialize(AContext: IAppContext); override;
    // Releasing Resources(only execute once)
    procedure UnInitialize; override;
    // Blocking primary thread execution(only execute once)
    procedure SyncBlockExecute; override;
    // Non blocking primary thread execution(only execute once)
    procedure AsyncNoBlockExecute; override;
    // Dependency Interface
    function Dependences: WideString; override;

    { IBehavior }

    // Add Behavior
    procedure Add(ABehavior: WideString); safecall;
  end;

implementation

uses
  Config,
  ServiceType,
  WNDataSetInf,
  FastLogLevel,
  AsfSdkExport;

{ TBehaviorImpl }

constructor TBehaviorImpl.Create;
begin
  inherited;
  FBehaviorStrs := TStringList.Create;
  FBehaviorItemPool := TBehaviorItemPool.Create;
  FBehaviorQuene := TSafeSemaphoreQueue<PBehaviorItem>.Create;
  FBehaviorThread := TExecutorThread.Create;
  FBehaviorThread.ThreadMethod := DoHandleBehaviorThreadExecute;
end;

destructor TBehaviorImpl.Destroy;
begin
  FBehaviorItemPool.Free;
  FBehaviorQuene.Free;
  FBehaviorStrs.Free;
  inherited;
end;

procedure TBehaviorImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);

end;

procedure TBehaviorImpl.UnInitialize;
begin
  if FBehaviorThread.IsStart then begin
    FBehaviorThread.ShutDown;
  end;
  inherited UnInitialize;
end;

procedure TBehaviorImpl.SyncBlockExecute;
begin

end;

procedure TBehaviorImpl.AsyncNoBlockExecute;
begin
  FBehaviorThread.StartEx;
end;

function TBehaviorImpl.Dependences: WideString;
begin

end;

procedure TBehaviorImpl.Add(ABehavior: WideString);
var
  LPBehaviorItem: PBehaviorItem;
begin
  LPBehaviorItem := FBehaviorItemPool.Allocate;
  if LPBehaviorItem <> nil then begin
    LPBehaviorItem.FDateTime := Now;
    LPBehaviorItem.FScreenID := '1';
    LPBehaviorItem.FModuleID := ABehavior;
    try
      FBehaviorQuene.Enqueue(LPBehaviorItem);
      FBehaviorQuene.ReleaseSemaphore;
    except
      on Ex: Exception do begin
        FastSysLog(llError, Format('[TUserBehaviorImpl.AddBehavior] Exception is %s',[Ex.Message]));
      end;
    end;
  end else begin
    FastSysLog(llError, '[TUserBehaviorImpl.AddBehavior] FBehaviorPool.Allocate');
  end;
end;

procedure TBehaviorImpl.DoSaveCache(AThread: TExecutorThread);
const
  BEHAVIOR_REPLACE_STR = '[""%s"",""%s"",""%s""]';
var
  LBehaviorStr: string;
  LPBehaviorItem: PBehaviorItem;
begin
  LPBehaviorItem := FBehaviorQuene.Dequeue;
  if LPBehaviorItem <> nil then begin
    LBehaviorStr := Format(BEHAVIOR_REPLACE_STR,
      [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', LPBehaviorItem.FDateTime),
      LPBehaviorItem.FScreenID, LPBehaviorItem.FModuleID]);
    FBehaviorStrs.Add(LBehaviorStr);
    if FileExists(FFile) then begin
      FBehaviorStrs.SaveToFile(FFile);
    end;
    FBehaviorItemPool.DeAllocate(LPBehaviorItem);
  end;
end;

procedure TBehaviorImpl.DoUploadBehaviors(AThread: TExecutorThread);
const
  MAXCOUNT = 30;
var
  LDataSet: IWNDataSet;
  LBehaviorStrs: string;
  LIndex, LCount: Integer;
begin
  LBehaviorStrs := '';
  if FBehaviorStrs.Count >= MAXCOUNT then begin
    LCount := MAXCOUNT;
  end else if FBehaviorStrs.Count > 0 then begin
    LCount := FBehaviorStrs.Count;
  end else begin
    LCount := 0;
  end;

  if LCount = 0 then Exit;

  for LIndex := 0 to LCount - 1 do begin
    if AThread.IsTerminated then Exit;

    if LBehaviorStrs = '' then begin
      LBehaviorStrs := FBehaviorStrs.Strings[LIndex];
    end else begin
      LBehaviorStrs := LBehaviorStrs + ',' + FBehaviorStrs.Strings[LIndex];
    end;
  end;

  if LBehaviorStrs <> '' then begin
    LBehaviorStrs := '("{""Fields"":[""ModuleID"",""ClickTime"",""Screen""],""Data"":['
      + LBehaviorStrs
      + ']}")';
    LDataSet := FAppContext.GFSyncHighQuery(stAsset, 'LOG_MODULE' + LBehaviorStrs, 0, INFINITE);
    if (LDataSet <> nil)
      and (LDataSet.FieldCount >= 1)
      and (LDataSet.RecordCount > 0)
      and (LDataSet.Fields(0) <> nil)
      and (LDataSet.Fields(0).AsString = '0') then begin
      LDataSet := nil;
      while True do begin
        if AThread.IsTerminated then Exit;
        

        if (LCount <= 0)
          or (FBehaviorStrs.Count <= 0) then Break;

        FBehaviorStrs.Delete(0);
        Dec(LCount);
      end;
      FBehaviorStrs.SaveToFile(FFile);
      LDataSet := FAppContext.GFSyncHighQuery(stBase, 'CLOUD_LOG_MODULE2' + LBehaviorStrs, 0, INFINITE);
      if LDataSet <> nil then begin
        LDataSet := nil;
      end;
    end;
  end;
end;

procedure TBehaviorImpl.DoHandleBehaviorThreadExecute(AObject: TObject);
var
  LResult: Cardinal;
  LThread: TExecutorThread;
begin
  LThread := TExecutorThread(AObject);
  while not LThread.IsTerminated do begin
    LResult := WaitForSingleObject(FBehaviorQuene.Semaphore, 10000);
    case LResult of
      WAIT_OBJECT_0:
        begin
          DoSaveCache(LThread);
          DoUploadBehaviors(LThread);
        end;
      WAIT_TIMEOUT:
        begin
          DoUploadBehaviors(LThread);
        end;
    end;
  end;
end;

end.
