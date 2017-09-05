unit SecuMainImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SecuMain Memory Table Interface implementation
// Author：      lksoulman
// Date：        2017-9-2
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  MsgType,
  Windows,
  Classes,
  SysUtils,
  SecuMain,
  AppContext,
  CommonLock,
  MsgService,
  MsgReceiver,
  CommonObject,
  WNDataSetInf,
  SyncAsyncImpl,
  ExecutorThread,
  CommonDynArray,
  CommonRefCounter,
  Generics.Collections;

type

  // SecuMain Memory Table Interface implementation
  TSecuMainImpl = class(TSyncAsyncImpl, ISecuMain, ISecuMainQuery)
  private
    // Thread Lock
    FLock: TCSLock;
    // Is Updating table
    FIsUpdating: Boolean;
    // SecuMainItem Capacity
    FItemCapacity: Integer;
    // Asynchronous update Thread
    FAsyncUpdateThread: TExecutorThread;
    // SecuMainItem List
    FSecuMainItems: TDynArray<PSecuMainItem>;
    // SecuMainItem Dictionary
    FSecuMainItemDic: TDictionary<Integer, PSecuMainItem>;

    // To SecuMarket
    function ToMarket(AValue: Integer): UInt8;
    // To SecuCategory
    function ToCategory(AValue: Integer): UInt16;
    // To SecuSpecialMark
    function ToSpecialMark(AMargin, AThrough: Integer): UInt8;
  protected
    // Add Message Type
    procedure DoAddMsgTypes; override;
    // Subcribe Message Call back
    procedure DoMsgCallBack(AMsgEx: TMsgEx; var ALogTag: string); override;

    // Async Update Excecute
    procedure DoAsyncUpdateExecute(AObject: TObject);

    // Update Table
    procedure DoUpdateTable;
    // Update Table After
    procedure DoUpdateTableAfter;
    // Update Table Before
    procedure DoUpdateTableBefore;
    // Load DataSet
    procedure DoLoadDataSet(ADataSet: IWNDataSet);
    // Load SecuMaintItem
    procedure DoLoadSecuMainItem(APSecuMainItem: PSecuMainItem;
//      AInnerCode,
      ASecuMarket,
      AListedState,
      ASecuCategory,
      AMargin,
      AThrough,
      ASecuAbbr,
      ASecuCode,
      ASecuSpell,
      ASecuSuffix,
      AFormerAbbr,
      AFormerSpell: IWNField);
    // Updating Get Item
    function DoGetItemUpdating(AInnerCode: Integer): PSecuMainItem;
    // No Updating Get Item
    function DoGetItemNoUpdating(AInnerCode: Integer): PSecuMainItem;
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

    { ISecuMainTable }

    // Lock
    procedure Lock; safecall;
    // Un Lock
    procedure UnLock; safecall;
    // Get Item Count
    function GetItemCount: Integer; safecall;
    // Get Item
    function GetItem(AIndex: Integer): PSecuMainItem; safecall;
    // Get Item By InnerCode
    function GetItemByInnerCode(AInnerCode: Integer): PSecuMainItem; safecall;

    { ISecuMainQuery }

    // Get Security By InnerCode
    function GetSecurity(AInnerCode: Integer): PSecuMainItem; safecall;
    // Get Securitys By InnerCodes
    function GetSecuritys(AInnerCodes: TIntegerDynArray; var APSecuMainItems: TPSecuMainItemDynArray): Boolean; safecall;
  end;

implementation

uses
  CacheType,
  FastLogLevel,
  AsfSdkExport,
  SecuMainConst;

const

  SQL_SECUMAIN = 'SELECT  '
	+' NBBM AS InnerCode,   '
	+' GPDM AS SecuCode,    '
	+' Suffix,              '
	+' ZQJC AS SecuAbbr,    '
	+' PYDM AS SecuSpell,   '
	+' ZQSC AS SecuMarket,  '
	+' SSZT AS ListedState, '
	+' oZQLB AS SecuCategory,          '
	+' FormerName AS FormerAbbr,       '
	+' FormerNameCode AS FormerSpell,  '
	+' targetCategory AS Margin,       '
	+' ggt AS Through,                 '
	+' CodeByAgent                     '
  +' FROM                            '
	+' ZQZB A                          '
  +' LEFT JOIN                       '
	+' HSCODE B                        '
  +' ON                              '
	+' A.NBBM = B.InnerCode            ';

{ TSecuMainImpl }

constructor TSecuMainImpl.Create;
begin
  inherited;
  FIsUpdating := False;
  FLock := TCSLock.Create;
  FItemCapacity := 190000;
  FIsNeedSubcribeMsg := True;
  FAsyncUpdateThread := TExecutorThread.Create;
  FAsyncUpdateThread.ThreadMethod := DoAsyncUpdateExecute;
  FSecuMainItems := TDynArray<PSecuMainItem>.Create(FItemCapacity);
  FSecuMainItemDic := TDictionary<Integer, PSecuMainItem>.Create(FItemCapacity);
end;

destructor TSecuMainImpl.Destroy;
begin
  FSecuMainItemDic.Free;
  FSecuMainItems.Free;
  FLock.Free;
  inherited;
end;

procedure TSecuMainImpl.Initialize(AContext: IAppContext);
begin
  inherited Initialize(AContext);
end;

procedure TSecuMainImpl.UnInitialize;
begin
  FAsyncUpdateThread.ShutDown;
  DoUnInitMsgSubcribe;
  inherited UnInitialize;
end;

procedure TSecuMainImpl.SyncBlockExecute;
begin
  DoUpdateTable;
end;

procedure TSecuMainImpl.AsyncNoBlockExecute;
begin
  FLock.Lock;
  try
    if not FAsyncUpdateThread.IsStart then begin
      FAsyncUpdateThread.StartEx;
    end;
    FAsyncUpdateThread.ResumeEx;
  finally
    FLock.UnLock;
  end;
end;

function TSecuMainImpl.Dependences: WideString;
begin
  Result := '';
end;

procedure TSecuMainImpl.Lock;
begin
  FLock.Lock;
end;

procedure TSecuMainImpl.UnLock;
begin
  FLock.UnLock;
end;

function TSecuMainImpl.GetItemCount: Integer;
begin
  Result := FSecuMainItems.GetCount;
end;

function TSecuMainImpl.GetItem(AIndex: Integer): PSecuMainItem;
begin
  Result := FSecuMainItems.GetElement(AIndex);
end;

function TSecuMainImpl.GetItemByInnerCode(AInnerCode: Integer): PSecuMainItem;
begin
  if FIsUpdating then begin
    Result := DoGetItemUpdating(AInnerCode);
  end else begin
    Result := DoGetItemNoUpdating(AInnerCode);
  end;
end;

function TSecuMainImpl.GetSecurity(AInnerCode: Integer): PSecuMainItem;
begin
  Result := GetItemByInnerCode(AInnerCode);
end;

function TSecuMainImpl.GetSecuritys(AInnerCodes: TIntegerDynArray; var APSecuMainItems: TPSecuMainItemDynArray): Boolean;
var
  LIndex, LCount, LTotalCount: Integer;
  LPSecuMainItem: PSecuMainItem;
begin
  Result := True;
  LTotalCount := Length(AInnerCodes);
  SetLength(APSecuMainItems, LTotalCount);
  if LTotalCount <= 0 then Exit;

  LCount := 0;
  for LIndex := 0 to LTotalCount - 1 do begin
    LPSecuMainItem := GetItemByInnerCode(AInnerCodes[LIndex]);
    if LPSecuMainItem <> nil then begin
      APSecuMainItems[LCount] := LPSecuMainItem;
      Inc(LCount);
    end;
  end;
end;

function TSecuMainImpl.ToMarket(AValue: Integer): UInt8;
begin
  if AValue < SECUMARKET_310 then begin
    Result := AValue;
  end else if AValue = GIL_SECUMARKET_310 then begin
    Result := SECUMARKET_310;
  end else if AValue = GIL_SECUMARKET_320 then begin
    Result := SECUMARKET_320;
  end else begin
    Result := 0;
  end;
end;

function TSecuMainImpl.ToCategory(AValue: Integer): UInt16;
begin
  Result := AValue;
end;

function TSecuMainImpl.ToSpecialMark(AMargin, AThrough: Integer): UInt8;
var
  LMargin, LThrough: UInt8;
begin
  LMargin := AMargin;
  LMargin := (LMargin shl 4) and MARGIN_MASK;
  LThrough := AThrough;
  LThrough := LThrough and THROUGH_MASK;
  Result := LMargin or LThrough;
end;

procedure TSecuMainImpl.DoAddMsgTypes;
begin
  DoAddMsgType(mtSecuMainUpdate);
end;

procedure TSecuMainImpl.DoMsgCallBack(AMsgEx: TMsgEx; var ALogTag: string);
begin
  inherited;
  AsyncNoBlockExecute;
end;

procedure TSecuMainImpl.DoAsyncUpdateExecute(AObject: TObject);
var
  LResult: Cardinal;
begin
  while not FAsyncUpdateThread.IsTerminated do begin
    LResult := FAsyncUpdateThread.WaitForEx;
    case LResult of
      WAIT_OBJECT_0:
        begin
          DoUpdateTable;
        end;
    end;
  end;
end;

procedure TSecuMainImpl.DoUpdateTable;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    if FAppContext = nil then Exit;

    DoUpdateTableBefore;

    LDataSet := FAppContext.CacheSyncQuery(ctBaseData, SQL_SECUMAIN);

    // 防止线程退出了循环还没有退出
    if FAsyncUpdateThread.IsTerminated then Exit;

    if (LDataSet <> nil) then begin
      if (LDataSet.RecordCount > 0) then begin
        DoLoadDataSet(LDataSet);
      end;
      LDataSet := nil;
    end else begin
      FastSysLog(llWARN, '[TSecuMainImpl][DoUpdateTable] Load dateset is nil.');
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[TSecuMainImpl][DoUpdateTable] Load permissions data to dictionary use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TSecuMainImpl.DoUpdateTableAfter;
begin
  DoPostMessageEx(mtSecuMainMemUpdate, 'SecuMain Memory Table Update Finish.');
end;

procedure TSecuMainImpl.DoUpdateTableBefore;
var
  LIndex: Integer;
begin
  for LIndex := 0 to self.FSecuMainItems.GetCount - 1 do begin
    FSecuMainItems.GetElement(LIndex).FIsUsed := False;
  end;
end;

procedure TSecuMainImpl.DoLoadDataSet(ADataSet: IWNDataSet);
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}

  LPSecuMainItem: PSecuMainItem;
  LInnerCode: Integer;
  LInnerCodeF,
  LSecuMarket,
  LListedState,
  LSecuCategory,
  LMargin,
  LThrough,
  LSecuAbbr,
  LSecuCode,
  LSecuSpell,
  LSecuSuffix,
  LFormerAbbr,
  LFormerSpell: IWNField;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  FIsUpdating := True;
  try
    ADataSet.First;
    LInnerCodeF := ADataSet.FieldByName('InnerCode');
    LSecuMarket := ADataSet.FieldByName('SecuMarket');
    LListedState := ADataSet.FieldByName('ListedState');
    LSecuCategory := ADataSet.FieldByName('SecuCategory');
    LMargin := ADataSet.FieldByName('Margin');
    LThrough := ADataSet.FieldByName('Through');
    LSecuAbbr := ADataSet.FieldByName('SecuAbbr');
    LSecuCode := ADataSet.FieldByName('SecuCode');
    LSecuSpell := ADataSet.FieldByName('SecuSpell');
    LSecuSuffix := ADataSet.FieldByName('Suffix');
    LFormerAbbr := ADataSet.FieldByName('FormerAbbr');
    LFormerSpell := ADataSet.FieldByName('FormerSpell');
    while not ADataSet.Eof do begin
      // 防止线程退出了循环还没有退出
      if FAsyncUpdateThread.IsTerminated then Exit;

      LInnerCode := LInnerCodeF.AsInteger;

      if FSecuMainItemDic.TryGetValue(LInnerCode, LPSecuMainItem)
        and (LPSecuMainItem <> nil) then begin
        LPSecuMainItem.FIsUsed := True;
      end else begin
        New(LPSecuMainItem);
        FSecuMainItemDic.AddOrSetValue(LInnerCode, LPSecuMainItem);
        LPSecuMainItem.FIsUsed := True;
        LPSecuMainItem.FInnerCode := LInnerCode;
      end;

      DoLoadSecuMainItem(LPSecuMainItem, LSecuMarket,
        LListedState,
        LSecuCategory,
        LMargin,
        LThrough,
        LSecuAbbr,
        LSecuCode,
        LSecuSpell,
        LSecuSuffix,
        LFormerAbbr,
        LFormerSpell);

      LPSecuMainItem.SetUpdate;

      ADataSet.Next;
    end;
  finally
    FIsUpdating := False;

{$IFDEF DEBUG}
    LTick := GetTickCount - LTick;
    FastSysLog(llSLOW, Format('[TSecuMainImpl][DoLoadDataSet] Load permissions data to dictionary use time is %d ms.', [LTick]), LTick);
{$ENDIF}
  end;
end;

procedure TSecuMainImpl.DoLoadSecuMainItem(APSecuMainItem: PSecuMainItem;
//  AInnerCode,
  ASecuMarket,
  AListedState,
  ASecuCategory,
  AMargin,
  AThrough,
  ASecuAbbr,
  ASecuCode,
  ASecuSpell,
  ASecuSuffix,
  AFormerAbbr,
  AFormerSpell: IWNField);
begin
//  APSecuMainItem^.FInnerCode := ;
  APSecuMainItem^.FSecuMarket := ToMarket(StrToIntDef(ASecuMarket.AsString, 0));
  APSecuMainItem^.FListedState := AListedState.AsInteger;
  APSecuMainItem^.FSecuCategory := ToCategory(ASecuCategory.AsInteger);
  APSecuMainItem^.FSecuSpecialMark := ToSpecialMark(StrToIntDef(AMargin.AsString, 0), StrToIntDef(AThrough.AsString, 0));
  APSecuMainItem^.FSecuAbbr := ASecuAbbr.AsString;
  APSecuMainItem^.FSecuCode := ASecuCode.AsString;
  APSecuMainItem^.FSecuSpell := ASecuSpell.AsString;
  APSecuMainItem^.FSecuSuffix := ASecuSuffix.AsString;
  APSecuMainItem^.FFormerAbbr := AFormerAbbr.AsString;
  APSecuMainItem^.FFormerSpell := AFormerSpell.AsString;
end;

function TSecuMainImpl.DoGetItemUpdating(AInnerCode: Integer): PSecuMainItem;
begin
  if not (FSecuMainItemDic.TryGetValue(AInnerCode, Result)
    and (Result <> nil)) then begin
   Result := nil;
  end;
end;

function TSecuMainImpl.DoGetItemNoUpdating(AInnerCode: Integer): PSecuMainItem;
begin
  if not (FSecuMainItemDic.TryGetValue(AInnerCode, Result)
    and (Result <> nil)) and Result.FIsUsed then begin
   Result := nil;
  end;
end;

end.
