unit SecuBaseDataImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-7-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Security,
  SyncAsync,
  AppContext,
  SecuBaseData,
  CommonObject,
  WNDataSetInf,
  ExecutorThread,
  Generics.Collections;

type

  // 证券主表数据内存管理实现
  TSecuBaseDataImpl = class(TInterfacedObject, ISyncAsync, ISecuBaseData)
  private
    // 线程是不是已经启动
    FIsThreadStart: boolean;
    // 应用程序上下文接口
    FAppContext: IAppContext;
    // 市场接口
    FSecuMarkets: TList<TList<ISecurity>>;
    // 证券存储字典
    FSecuMarketDic: TDictionary<Integer, TList<ISecurity>>;
    // 证券内码存储字典
    FSecuInnerCodeDic: TDictionary<Integer, ISecurity>;
  protected
    // 加载主表数据
    procedure DoSyncLoadSecuMainTable;
    // 加载数据集
    procedure DoLoadData(ADataSet: IWNDataSet);
    // 加载单个证券信息
    procedure DoLoadSecurity(ASecurity: ISecurity; ASecuCodeField, ASufficField, ASecuAbbrField, ASecuSpellField, ASecuMarketField,
      AListedStateField, ASetSecuCategoryField, AFormerAbbrField, AFormerSpellField, AMarginField, AThroughField: IWNField);
  public
    // 构造函数
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

    { ISecuBaseData }

    // 通过证券内码获取证券信息
    function QuerySecurity(AInnerCode: Integer): ISecurity; safecall;
    // 通过多个证券内码获取多个获取证券信息
    function QuerySecuritys(AInnerCodes: TIntegerDynArray; var ASecuritys: TSecuritys): Boolean; safecall;
  end;

implementation

uses
  CacheType,
  SecuConst,
  SecuUpdate,
  SecuritySQL,
  SecurityImpl,
  FastLogLevel;

{ TSecuBaseDataImpl }

constructor TSecuBaseDataImpl.Create;
begin
  inherited;
  FIsThreadStart := False;
  FSecuMarketDic := TDictionary<Integer, TList<ISecurity>>.Create;
  FSecuInnerCodeDic := TDictionary<Integer, ISecurity>.Create(190000);
end;

destructor TSecuBaseDataImpl.Destroy;
begin
  FSecuInnerCodeDic.Clear;
  FSecuMarketDic.Clear;
  inherited;
end;

procedure TSecuBaseDataImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;

end;

procedure TSecuBaseDataImpl.UnInitialize;
begin
  FAppContext := nil;
end;

function TSecuBaseDataImpl.IsNeedSync: WordBool;
begin
  Result := True;
end;

procedure TSecuBaseDataImpl.SyncExecute;
begin
  DoSyncLoadSecuMainTable;
end;

procedure TSecuBaseDataImpl.AsyncExecute;
begin

end;

procedure TSecuBaseDataImpl.DoSyncLoadSecuMainTable;
var
  LTick: Cardinal;
  LInnerCode, LCount: Integer;
  LDataSet: IWNDataSet;
  LSecurity: ISecurity;
begin
  if FAppContext = nil then Exit;

  LCount := 0;
  LTick := GetTickCount;
  LDataSet := FAppContext.SyncCacheQueryData(ctBaseData, SQL_SECUMAIN);
  LTick := GetTickCount - LTick;
  if LTick > 1000 then begin
    FAppContext.AppLog(llSLOW, Format('FAppContext.SyncCacheQueryData(ctBaseData, %s)', [SQL_SECUMAIN]), LTick);
  end;
  if (LDataSet = nil) and (LDataSet.RecordCount > 0) then begin
    LTick := GetTickCount;
    DoLoadData(LDataSet);
  end else begin
    if LTick > 3000 then begin
      FAppContext.AppLog(llSLOW, Format('Load SecuMain data into memory usetime = %d > 3000', [LTick]), LTick);
    end;
  end;
end;

function TSecuBaseDataImpl.QuerySecurity(AInnerCode: Integer): ISecurity;
begin
  if not FSecuInnerCodeDic.TryGetValue(AInnerCode, Result) then begin
    Result := nil;
  end;
end;

function TSecuBaseDataImpl.QuerySecuritys(AInnerCodes: TIntegerDynArray;
  var ASecuritys: TSecuritys): Boolean;
var
  LSecurity: ISecurity;
  LCount, LIndex, LArrayLen: Integer;
begin
  Result := False;
  LArrayLen := Length(AInnerCodes);
  if LArrayLen <= 0 then Exit;

  LCount := 0;
  SetLength(ASecuritys, LArrayLen);
  for LIndex := 0 to LArrayLen - 1 do begin
    LSecurity := QuerySecurity(AInnerCodes[LIndex]);
    if Assigned(LSecurity) then begin
      ASecuritys[LCount] := LSecurity;
      Inc(LCount);
    end;
  end;
  SetLength(ASecuritys, LCount);
  Result := True;
end;

procedure TSecuBaseDataImpl.DoLoadData(ADataSet: IWNDataSet);
var
  LInnerCode: Integer;
  LSecurity: ISecurity;
  LInnerCodeField,
  LSecuCodeField,
  LSufficField,
  LSecuAbbrField,
  LSecuSpellField,
  LSecuMarketField,
  LListedStateField,
  LSetSecuCategoryField,
  LFormerAbbrField,
  LFormerSpellField,
  LMarginField,
  LThroughField: IWNField;
begin
  ADataSet.First;
//    SQL_SECUMAIN = 'SELECT NBBM as InnerCode, '
//               + '        GPDM as SecuCode, '
//               + '                  Suffix, '
//               + '        ZQJC as SecuAbbr, '
//               + '       PYDM as SecuSpell, '
//               + '      ZQSC as SecuMarket, '
//               + '     SSZT as ListedState, '
//               + '   oZQLB as SecuCategory, '
//               + 'FormerName as FormerAbbr, '
//               + 'FormerNameCode as FormerSpell, '
//               + ' targetCategory as Margin, '
//               + '           ggt as Through  '
//               + ' FROM ZQZB';

  LInnerCodeField := ADataSet.FieldByName('InnerCode');
  LSecuCodeField := ADataSet.FieldByName('SecuCode');
  LSufficField := ADataSet.FieldByName('Suffix');
  LSecuAbbrField := ADataSet.FieldByName('SecuAbbr');
  LSecuSpellField := ADataSet.FieldByName('SecuSpell');
  LSecuMarketField := ADataSet.FieldByName('SecuMarket');
  LListedStateField := ADataSet.FieldByName('ListedState');
  LSetSecuCategoryField := ADataSet.FieldByName('SecuCategory');
  LFormerAbbrField := ADataSet.FieldByName('FormerAbbr');
  LFormerSpellField := ADataSet.FieldByName('FormerSpell');
  LMarginField := ADataSet.FieldByName('Margin');
  LThroughField := ADataSet.FieldByName('Through');

  while not ADataSet.Eof do begin
    LInnerCode := LInnerCodeField.AsInteger;
    LSecurity := QuerySecurity(LInnerCode);
    if LSecurity = nil then begin
      LSecurity := TSecurityImpl.Create as ISecurity;
      FSecuInnerCodeDic.AddOrSetValue(LInnerCode, LSecurity);
    end;
    (LSecurity as ISecuUpdate).SetInnerCode(LInnerCode);
    DoLoadSecurity(
      LSecurity,
      LSecuCodeField,
      LSufficField,
      LSecuAbbrField,
      LSecuSpellField,
      LSecuMarketField,
      LListedStateField,
      LSetSecuCategoryField,
      LFormerAbbrField,
      LFormerSpellField,
      LMarginField,
      LThroughField
      );
    ADataSet.Next;
  end;
end;

procedure TSecuBaseDataImpl.DoLoadSecurity(ASecurity: ISecurity; ASecuCodeField, ASufficField, ASecuAbbrField, ASecuSpellField, ASecuMarketField,
  AListedStateField, ASetSecuCategoryField, AFormerAbbrField, AFormerSpellField, AMarginField, AThroughField: IWNField);
var
  LMargin, LThrough: Byte;
begin
  (ASecurity as ISecuUpdate).SetSecuCode(ASecuCodeField.AsString);
  (ASecurity as ISecuUpdate).SetSuffic(ASufficField.AsString);
  (ASecurity as ISecuUpdate).SetSecuAbbr(ASecuAbbrField.AsString);
  (ASecurity as ISecuUpdate).SetSecuSpell(ASecuSpellField.AsString);
  (ASecurity as ISecuUpdate).SetSecuMarket(ASecuMarketField.AsInteger);
  (ASecurity as ISecuUpdate).SetListedState(AListedStateField.AsInteger);
  (ASecurity as ISecuUpdate).SetSecuCategory(ASetSecuCategoryField.AsInteger);
  (ASecurity as ISecuUpdate).SetFormerAbbr(AFormerAbbrField.AsString);
  (ASecurity as ISecuUpdate).SetFormerSpell(AFormerSpellField.AsString);
  LMargin := TGildataUtil.ValueConvertMargin(StrToIntDef(AMarginField.AsString, 0));
  LMargin := (LMargin and MARGIN_MASK);
  LThrough := TGildataUtil.ValueConvertThrough(StrToIntDef(AThroughField.AsString, 0));
  LThrough := (LThrough and THROUGH_MASK) shl 4;
  (ASecurity as ISecuUpdate).SetSecuCategoryI(LMargin or LThrough);
  (ASecurity as ISecuUpdate).UpdateSecurityData;
end;

end.
