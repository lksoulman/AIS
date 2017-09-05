unit QDOMarketMonitor;

interface

uses Windows, Classes, SysUtils, Activex, ComObj, IniFiles, Math, QuoteMngr_TLB,
  QuoteStruct, QuoteConst, QuoteLibrary, IOCPMemory, SyncObjs, QuoteDataMngr,
  GilQuoteStruct, Generics.collections, QDOBase;

const
  MAX_MARKET_EVENT_COUNT = 200;
  UPDATE_MARKET_EVENT = 1001;

type
  TQuoteMarketMonitor = class(TQuoteSync, IQuoteMarketMonitor)
  private
    FDatas: array of TMarketEvent;
    FCount: Integer;
    FVarCode: Long;
  protected
    function Count: Integer; safecall;
    function Get_Datas: Int64; safecall;
    function Get_VarCode: Integer; safecall;

  public
    procedure Update(DataType: Integer; Data: Int64; Size: Integer); override; safecall;

    constructor Create(QuoteDataMngr: TQuoteDataMngr);
    destructor Destroy(); override;
  end;

implementation

uses System.Win.ComServ;

{ TQuoteMarketMonitor }

constructor TQuoteMarketMonitor.Create(QuoteDataMngr: TQuoteDataMngr);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteMarketMonitor);
  FCount := 0;
  FVarCode := 0;
  SetLength(FDatas, MAX_MARKET_EVENT_COUNT);
  ZeroMemory(@FDatas[0], MAX_MARKET_EVENT_COUNT * SizeOf(FDatas[0]));
end;

destructor TQuoteMarketMonitor.Destroy;
begin
  FCount := 0;
  SetLength(FDatas, 0);
  inherited;
end;

function TQuoteMarketMonitor.Count: Integer;
begin
  Result := FCount;
end;

function TQuoteMarketMonitor.Get_Datas: Int64;
begin
  Result := Int64(@FDatas[0]);
end;

function TQuoteMarketMonitor.Get_VarCode: Integer;
begin
  Result := FVarCode;
end;

procedure TQuoteMarketMonitor.Update(DataType: Integer; Data: Int64; Size: Integer);
var
  // p:PMarketEvent;
  NCount, OCount: Integer;
begin
  case DataType of
    UPDATE_MARKET_EVENT:
      begin
        if (Size = 0) or (Data = 0) then
          Exit;
        BeginWrite();
        try
          NCount := Min(Size, Length(FDatas));
          OCount := Min(Length(FDatas) - NCount, FCount);
          if OCount <= 0 then // 全部更新
          begin
            CopyMemory(@FDatas[0], PMarketEvent(Data), SizeOf(TMarketEvent) * NCount);
          end
          else
          begin
            // 先把后面的Copy到前面来
            CopyMemory(@FDatas[0], @FDatas[FCount - OCount], SizeOf(TMarketEvent) * OCount);
            // 再把新的Copy到数组后面
            CopyMemory(@FDatas[OCount], PMarketEvent(Data), SizeOf(TMarketEvent) * NCount);
          end;
          FCount := NCount + OCount;
          inc(FVarCode);
        finally
          EndWrite();
        end;
      end;
  end;
end;

end.
