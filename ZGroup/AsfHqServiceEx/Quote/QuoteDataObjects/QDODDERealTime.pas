unit QDODDERealTime;

interface

uses
  Windows, Classes, SysUtils, Activex, ComObj, IniFiles, Math, QuoteMngr_TLB,
  QuoteStruct, QuoteConst, QuoteLibrary, IOCPMemory, SyncObjs, QuoteDataMngr,
  GilQuoteStruct, Generics.collections, QDOBase, System.Win.ComServ;

const
  UPDATE_DDE_BIGORDER_BYORDER = 1008;

type
  TQuoteDDERealTimeData = class(TQuoteSync, IQuoteDDERealTime)
  protected
    FDataHash: TDictionary<String, PDDERealtimeData>;

    Function GenerateKey(CodeType: Word; const Code: string): string;
    function GetDDERealtimeData(CodeType: Word; const Code: string): PDDERealtimeData;
    function AddDDERealtimeData(CodeType: Word; const Code: string): PDDERealtimeData;
    procedure DoValueNotify(Sender: TObject; Const Item: PDDERealtimeData; Action: TCollectionNotification);

    function Datas(CodeType: Word; const Code: WideString): Int64; safecall;

  public
    procedure Update(DataType: Integer; Data: Int64; Size: Integer); override; safecall;
    constructor Create(QuoteDataMngr: TQuoteDataMngr);
    destructor Destroy(); override;
  end;

implementation

{ TDDERealTimeData }
//

Function TQuoteDDERealTimeData.GenerateKey(CodeType: Word; const Code: string): string;
begin
  Result := inttostr(CodeType) + '_' + Code;
end;

function TQuoteDDERealTimeData.GetDDERealtimeData(CodeType: Word; const Code: string): PDDERealtimeData;
begin
  if not FDataHash.TryGetValue(GenerateKey(CodeType, Code), Result) then
    Result := nil;
end;

function TQuoteDDERealTimeData.AddDDERealtimeData(CodeType: Word; const Code: string): PDDERealtimeData;
var
  p: PDDERealtimeData;
begin
  Result := GetDDERealtimeData(CodeType, Code);
  if Result = nil then
  begin
    Result := GetMemory(sizeof(TDDERealtimeData));
    FillMemory(Result, sizeof(TDDERealtimeData), 0);
    FDataHash.Add(GenerateKey(CodeType, Code), Result);
  end;
end;

procedure TQuoteDDERealTimeData.DoValueNotify(Sender: TObject; Const Item: PDDERealtimeData;
  Action: TCollectionNotification);
begin
  if cnRemoved = Action then
    if Item <> nil then
      FreeMemory(Item);
end;

function TQuoteDDERealTimeData.Datas(CodeType: Word; const Code: WideString): Int64;
begin
  Result := Int64(GetDDERealtimeData(CodeType, Code));
end;

procedure TQuoteDDERealTimeData.Update(DataType: Integer; Data: Int64; Size: Integer);
var
  // p:PAnsTradeClassify_HDA;
  // I:Integer;
  pData: PDDERealtimeData;
  ptmp: pHDATradeClassifyData;
begin
  case DataType of
    UPDATE_DDE_BIGORDER_BYORDER:
      begin
        if (Data = 0) or (Size = 0) then
          exit;
        // p := PAnsTradeClassify_HDA;
        BeginWrite();
        try
          // for I := 0 to  p.m_nSize - 1 do
          // begin
          ptmp := pHDATradeClassifyData(Data);
          pData := AddDDERealtimeData(ptmp.m_StockCode.m_cCodeType, CodeInfoToCode(@ptmp.m_StockCode));
          if pData <> nil then
          begin
            inc(pData.VarCode);
            pData.DDEBigOrderData := ptmp^;
          end;
          // end;
        finally
          EndWrite();
        end;
      end;
  end;
end;

constructor TQuoteDDERealTimeData.Create(QuoteDataMngr: TQuoteDataMngr);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteMarketMonitor);
  FDataHash := TDictionary<String, PDDERealtimeData>.Create(100);
  FDataHash.OnValueNotify := DoValueNotify;
end;

destructor TQuoteDDERealTimeData.Destroy();
begin
  if FDataHash <> nil then
    FDataHash.Clear;
  FreeAndNil(FDataHash);
  inherited;
end;

end.
