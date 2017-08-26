unit UserBehaviorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
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
  SyncAsync,
  AppContext,
  CommonQueue,
  UserBehavior,
  BehaviorPool,
  ExecutorThread;

type

  // 用户行为上传接口实现
  TUserBehaviorImpl = class(TInterfacedObject, ISyncAsync, IUserBehavior)
  private
    // 保存文件
    FFile: string;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 行为字符串
    FBehaviorStrs: TStringList;
    // 行为对象池
    FBehaviorPool: TBehaviorPool;
    // 用户行为处理数据上传线程
    FBehaviorThread: TExecutorThread;
    // 添加队列
    FAddBehaviorQuene: TSafeSemaphoreQueue<TBehavior>;
  protected
    // 保存数据到本地
    procedure DoSaveCache(AThread: TExecutorThread);
    // 上传数据到服务端
    procedure DoUploadBehaviors(AThread: TExecutorThread);
    // 用户行为处理数据上传线程方法
    procedure DoHandleBehaviorThreadExecute(AObject: TObject);
  public
    // 构造方法
    constructor Create;
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

    { IUserBehavior }

    // 添加用户行为方法
    procedure AddBehavior(ABehavior: WideString); safecall;
  end;

implementation

uses
  Config,
  ServiceType,
  FastLogLevel,
  WNDataSetInf;

{ TUserBehaviorImpl }

constructor TUserBehaviorImpl.Create;
begin
  inherited;
  FBehaviorStrs := TStringList.Create;
  FBehaviorPool := TBehaviorPool.Create;
  FBehaviorThread := TExecutorThread.Create;
  FBehaviorThread.ThreadMethod := DoHandleBehaviorThreadExecute;
  FAddBehaviorQuene := TSafeSemaphoreQueue<TBehavior>.Create;
end;

destructor TUserBehaviorImpl.Destroy;
begin
  FAddBehaviorQuene.Free;
  FBehaviorPool.Free;
  FBehaviorStrs.Free;
  inherited;
end;

procedure TUserBehaviorImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TUserBehaviorImpl.UnInitialize;
begin
  FBehaviorThread.ShutDown;
  FAppContext := nil;
end;

function TUserBehaviorImpl.IsNeedSync: WordBool;
begin
  Result := False;
end;

procedure TUserBehaviorImpl.SyncExecute;
begin
//  FFile := FAppContext.GetConfig.
end;

procedure TUserBehaviorImpl.AsyncExecute;
begin
  FBehaviorThread.StartEx;
end;

procedure TUserBehaviorImpl.AddBehavior(ABehavior: WideString);
var
  LBehavior: TBehavior;
begin
  LBehavior := FBehaviorPool.Allocate;
  if LBehavior <> nil then begin
    LBehavior.DateTime := Now;
    LBehavior.ScreenID := '1';
    LBehavior.ModuleID := ABehavior;
    try
      FAddBehaviorQuene.Enqueue(LBehavior);
      FAddBehaviorQuene.ReleaseSemaphore;
    except
      on Ex: Exception do begin
        if (FAppContext <> nil) then begin
          FAppContext.AppLog(llError, Format('[TUserBehaviorImpl.AddBehavior] Exception is %s',[Ex.Message]));
        end;
      end;
    end;
  end else begin
    if (FAppContext <> nil) then begin
      FAppContext.AppLog(llError, '[TUserBehaviorImpl.AddBehavior] FBehaviorPool.Allocate');
    end;
  end;
end;

procedure TUserBehaviorImpl.DoSaveCache(AThread: TExecutorThread);
const
  BEHAVIOR_REPLACE_STR = '[""%s"",""%s"",""%s""]';
var
  LBehaviorStr: string;
  LBehavior: TBehavior;
begin
  LBehavior := FAddBehaviorQuene.Dequeue;
  if LBehavior <> nil then begin
    LBehaviorStr := Format(BEHAVIOR_REPLACE_STR,
      [FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', LBehavior.DateTime),
      LBehavior.ScreenID, LBehavior.ModuleID]);
    FBehaviorStrs.Add(LBehaviorStr);
    if FileExists(FFile) then begin
      FBehaviorStrs.SaveToFile(FFile);
    end;
    FBehaviorPool.DeAllocate(LBehavior);
  end;
end;

procedure TUserBehaviorImpl.DoUploadBehaviors(AThread: TExecutorThread);
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
    LDataSet := FAppContext.GFSyncQueryHighData(stAsset, 'LOG_MODULE' + LBehaviorStrs, 0, INFINITE);
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
      LDataSet := FAppContext.GFSyncQueryHighData(stBase, 'CLOUD_LOG_MODULE2' + LBehaviorStrs, 0, INFINITE);
      if LDataSet <> nil then begin
        LDataSet := nil;
      end;
    end;
  end;
end;

procedure TUserBehaviorImpl.DoHandleBehaviorThreadExecute(AObject: TObject);
var
  LResult: Cardinal;
  LThread: TExecutorThread;
begin
  LThread := TExecutorThread(AObject);
  while not LThread.IsTerminated do begin
    LResult := WaitForSingleObject(FAddBehaviorQuene.Semaphore, 10000);
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
