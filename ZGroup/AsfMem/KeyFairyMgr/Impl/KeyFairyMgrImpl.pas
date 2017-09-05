unit KeyFairyMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Key Fairy Manager Interface implementation
// Author£º      lksoulman
// Date£º        2017-8-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgType,
  Windows,
  Classes,
  SysUtils,
  Vcl.ExtCtrls,
  SecuMain,
  KeyFairy,
  MsgService,
  AppContext,
  CommonLock,
  MsgReceiver,
  KeyFairyMgr,
  KeyFairyType,
  KeyFairyItem,
  SyncAsyncImpl,
  CommonDynArray,
  ExecutorThread,
  KeyFairyItemPool,
  Generics.Collections;

type

  // Key Fairy Manager Interface implementation
  TKeyFairyMgrImpl = class(TSyncAsyncImpl, IKeyFairyMgr)
  private
    // Thread Lock
    FLock: TCSLock;
    // Is Loaded
    FIsLoaded: Boolean;
    // Is Updating
    FUpdating: Boolean;
    // SecuMain Memory Table
    FSecuMain: ISecuMain;
    // Key Fairy Interface List
    FKeyFairys: TList<IKeyFairy>;
    // Key Fairy Item Pool
    FKeyFairyItemPool: TKeyFairyItemPool;
    // Search Key
    FSearchKey: string;
    // Search Key Char Type
    FSearchKeyCharType: TKeyCharType;
    // Search Timer
    FSearchTimer: TTimer;
    // Search Call Back
    FSearchCallBack: TKeyFairyMgrCallBack;
    // Search Result Key Fairy Items
    FSearchKeyFairyItems: TDynArray<PKeyFairyItem>;
    // Asynchronous Query Thread
    FAsyncQueryThread: TExecutorThread;
  protected
    // Search Timer
    procedure DoSearchTimer(AObject: TObject);
    // Asynchronous Query Execute
    procedure DoAsyncSearchExecute(AObject: TObject);
    // Fuzzy Search Updating
    procedure DoFuzzySearchUpdating(AKey: string);
    // Fuzzy Search No Updating
    procedure DoFuzzySearchNoUpdating(AKey: string);

    // Get Key Char Type
    function DoGetKeyCharType(AKey: string): TKeyCharType;

    // Add Message Type
    procedure DoAddMsgTypes; override;
    // Subcribe Message Call back
    procedure DoMsgCallBack(AMsgEx: TMsgEx; var ALogTag: string); override;

    // Load Key Fairy Item From SecuMain
    procedure DoLoadKeyFairyItems;
    // UnLoad Key Fairy Item
    procedure DoUnLoadKeyFairyItems;
    // Update Key Fairy Item From SecuMain
    procedure DoUpdateKeyFairyItems;
    // Get Key Fairy Interface
    function DoGetKeyFairy(AKeyFairyType: TKeyFairyType): IKeyFairy;
    // Get Key Fairy Type
    function DoGetKeyFairyType(APSecuMainItem: PSecuMainItem): TKeyFairyType;
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

    { IKeyFairyMgr }

    // Fuzzy Search
    procedure FuzzySearch(AKey: string); safecall;
    // Set Call Back
    procedure SetSearchCallBack(ACallBack: TKeyFairyMgrCallBack); safecall;
  end;

implementation

{ TKeyFairyMgrImpl }

constructor TKeyFairyMgrImpl.Create;
begin
  inherited;
  FIsLoaded := False;
  FUpdating := False;
  FIsNeedSubcribeMsg := True;
  FLock := TCSLock.Create;
  FKeyFairys := TList<IKeyFairy>.Create;
  FKeyFairyItemPool := TKeyFairyItemPool.Create;
  FSearchKeyFairyItems := TDynArray<PKeyFairyItem>.Create;
  FAsyncQueryThread := TExecutorThread.Create;
  FAsyncQueryThread.ThreadMethod := DoAsyncSearchExecute;
  FSearchTimer := TTimer.Create(nil);
  FSearchTimer.Enabled := False;
  FSearchTimer.Interval := 300;
end;

destructor TKeyFairyMgrImpl.Destroy;
begin
  FSearchTimer.Enabled := False;
  FSearchTimer.Free;
  FSearchKeyFairyItems.Free;
  FKeyFairyItemPool.Free;
  FKeyFairys.Free;
  FLock.Free;
  inherited;
end;

procedure TKeyFairyMgrImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
  if not FIsLoaded then begin
    DoLoadKeyFairyItems;
    FIsLoaded := True;
  end;
end;

procedure TKeyFairyMgrImpl.UnInitialize;
begin
  if not FIsLoaded then begin
    DoLoadKeyFairyItems;
  end;
  inherited UnInitialize;
end;

procedure TKeyFairyMgrImpl.SyncBlockExecute;
begin
  
end;

procedure TKeyFairyMgrImpl.AsyncNoBlockExecute;
begin

end;

function TKeyFairyMgrImpl.Dependences: WideString;
begin

end;

procedure TKeyFairyMgrImpl.FuzzySearch(AKey: string);
begin
  FSearchKey := AKey;
  FSearchTimer.Enabled := True;
end;

procedure TKeyFairyMgrImpl.DoSearchTimer(AObject: TObject);
begin
  FAsyncQueryThread.ResumeEx;
  FSearchTimer.Enabled := False;
end;

procedure TKeyFairyMgrImpl.DoAsyncSearchExecute(AObject: TObject);
var
  LResult: Cardinal;
begin
  while not FAsyncQueryThread.IsTerminated do begin
    LResult := FAsyncQueryThread.WaitForEx;
    case LResult of
      WAIT_OBJECT_0:
        begin
          FSearchKeyCharType := DoGetKeyCharType(FSearchKey);
          if FUpdating then begin
            DoFuzzySearchUpdating(FSearchKey);
          end else begin
            DoFuzzySearchNoUpdating(FSearchKey);
          end;
        end;
    end;
  end;
end;

procedure TKeyFairyMgrImpl.SetSearchCallBack(ACallBack: TKeyFairyMgrCallBack);
begin
  FSearchCallBack := ACallBack;
end;

procedure TKeyFairyMgrImpl.DoAddMsgTypes;
begin
  DoAddMsgType(mtSecuMainMemUpdate);
end;

procedure TKeyFairyMgrImpl.DoMsgCallBack(AMsgEx: TMsgEx; var ALogTag: string);
begin
  inherited;
  DoUpdateKeyFairyItems;
end;

procedure TKeyFairyMgrImpl.DoLoadKeyFairyItems;
var
  LIndex: Integer;
  LKeyFairy: IKeyFairy;
  LKeyFairyType: TKeyFairyType;
  LPSecuMainItem: PSecuMainItem;
  LPKeyFairyItem: PKeyFairyItem;
begin
  FUpdating := True;
  FLock.Lock;
  try
    if FSecuMain <> nil then begin
      FSecuMain.Lock;
      try
        for LIndex := 0 to FSecuMain.GetItemCount - 1 do begin
          LPSecuMainItem := FSecuMain.GetItem(LIndex);
          if LPSecuMainItem <> nil then begin
            LKeyFairyType := DoGetKeyFairyType(LPSecuMainItem);
            LKeyFairy := DoGetKeyFairy(LKeyFairyType);
            LPKeyFairyItem := LKeyFairy.GetKeyFairyItem(LPSecuMainItem.FInnerCode);
            if LPKeyFairyItem = nil then begin
              LPKeyFairyItem := FKeyFairyItemPool.Allocate;
              LPKeyFairyItem.FId := LPSecuMainItem.FInnerCode;
              LPKeyFairyItem.FPSecuMainItem := LPSecuMainItem;
              LKeyFairy.AddKeyFairyItem(LPKeyFairyItem);
            end;
          end;
        end;
      finally
        FSecuMain.UnLock;
      end;
    end;
  finally
    FLock.UnLock;
    FUpdating := False;
  end;
end;

procedure TKeyFairyMgrImpl.DoUnLoadKeyFairyItems;
begin

end;

procedure TKeyFairyMgrImpl.DoUpdateKeyFairyItems;
begin
  DoLoadKeyFairyItems;
  if not FIsLoaded then begin
    FIsLoaded := True;
  end;
end;

function TKeyFairyMgrImpl.DoGetKeyFairy(AKeyFairyType: TKeyFairyType): IKeyFairy;
var
  LIndex: Integer;
begin
  LIndex := Ord(AKeyFairyType);

end;

function TKeyFairyMgrImpl.DoGetKeyFairyType(APSecuMainItem: PSecuMainItem): TKeyFairyType;
begin
//  Result
end;

procedure TKeyFairyMgrImpl.DoFuzzySearchUpdating(AKey: string);
var
  LIndex: Integer;
begin
  FSearchKeyFairyItems.ClearCount;
  for LIndex := 0 to FKeyFairys.Count - 1 do begin
    FKeyFairys.Items[LIndex].SetSearchKeyCharType(FSearchKeyCharType);
    FKeyFairys.Items[LIndex].FuzzySearchUpdating(AKey, FSearchKeyFairyItems);
  end;
end;

procedure TKeyFairyMgrImpl.DoFuzzySearchNoUpdating(AKey: string);
var
  LIndex: Integer;
begin
  FSearchKeyFairyItems.ClearCount;
  for LIndex := 0 to FKeyFairys.Count - 1 do begin
    FKeyFairys.Items[LIndex].SetSearchKeyCharType(FSearchKeyCharType);
    FKeyFairys.Items[LIndex].FuzzySearchUpdating(AKey, FSearchKeyFairyItems);
  end;
end;

function TKeyFairyMgrImpl.DoGetKeyCharType(AKey: string): TKeyCharType;
var
  LIndex: Integer;
begin
  Result := kcNomeric;
  for LIndex := 1 to Length(AKey) do begin
    if (AKey[LIndex] >= 'A')
      and (AKey[LIndex] <= 'Z') then
    begin
      if Result = kcNomeric then begin
        Result := kcAlpha;
      end;
    end else begin
      if (AKey[LIndex] < '0')
        or (AKey[LIndex] > '9') then
      begin
        Result := kcChinese;
        Break;
      end;
    end;
  end;
end;

end.
