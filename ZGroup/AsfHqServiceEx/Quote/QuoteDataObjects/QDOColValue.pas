unit QDOColValue;

interface
uses
  Windows, Classes, SysUtils, Activex, ComObj, IniFiles, Math, QuoteMngr_TLB,
     QuoteStruct, QuoteConst, QuoteLibrary, IOCPMemory, SyncObjs, QuoteDataMngr,
     GilQuoteStruct,Generics.collections,QDOBase;
const
  UPDATE_COLVELUE_COL_CODE = 1100;
  UPDATE_COLVELUE_DATA = 1101;
  UPDATE_COLVULUE_CLEAR = 1102;

type
  TQuoteColValue = class(TQuoteSync,IQuoteColValue)
  protected
    FDatas:PGilQuoteColValues;
    FCount:integer;
    FVarCode:Integer;
    FColCode:integer;

    procedure FreeDatas();

    function Count: Integer; safecall;
    function Get_Datas: Int64; safecall;
    function Get_VarCode: Integer; safecall;
    function Get_ColCode: Integer; safecall;
  public
    procedure Update(DataType: Integer; Data: Int64; Size: Integer);override; safecall;
    constructor Create(QuoteDataMngr: TQuoteDataMngr);
    destructor Destroy();override;
  end;
implementation
  uses System.Win.ComServ;
{ TQuoteColValue }
constructor TQuoteColValue.Create(QuoteDataMngr: TQuoteDataMngr);
begin
  inherited Create(QuoteDataMngr, ComServer.TypeLib, IQuoteMarketMonitor);
  FDatas:= nil;
  FCount := 0;
  FColCode := -1;
  FVarCode := 0;
end;

destructor TQuoteColValue.Destroy;
begin
  FCount := 0;
  FreeDatas;
  inherited;
end;

procedure TQuoteColValue.FreeDatas();
begin
  if FDatas <> nil then
  begin
    FreeMemory(FDatas);
    FDatas := nil;
  end;
end;

function TQuoteColValue.Count: Integer;
begin
  result := FCount;
end;


function TQuoteColValue.Get_ColCode: Integer;
begin
  result := FColCode;
end;

function TQuoteColValue.Get_Datas: Int64;
begin
  Result := Int64(FDatas);
end;

function TQuoteColValue.Get_VarCode: Integer;
begin
  result := FVarCode;
end;

procedure TQuoteColValue.Update(DataType: Integer; Data: Int64; Size: Integer);
var
  AnsHQColValue:PAnsHQColValue;
  tmpData:PGilQuoteColValues;
  tmpCount,i:Integer;
  pData32:PGilQuoteColValue32;
  pData64:PGilQuoteColValue64;
begin
  case DataType of
     UPDATE_COLVELUE_COL_CODE: FColCode := Data;
     UPDATE_COLVULUE_CLEAR:
     begin
       BeginWrite;
       try
         FCount := 0;
         FreeDatas;
       finally
         EndWrite;
       end;
     end;
     UPDATE_COLVELUE_DATA:
     begin
       BeginWrite;
       try
         AnsHQColValue := PAnsHQColValue(Data);
         if (Size = 0) or (Data = 0) or (AnsHQColValue.m_lHQColCount = 0) or
           (AnsHQColValue.m_HQColFields[0].m_lField <> FColCode) then
           exit;
         tmpCount := FCount + AnsHQColValue.m_lHQColCount;
         tmpData := GetMemory(tmpCount * SizeOf(TGilQuoteColValues));
         FillMemory(tmpData,tmpCount * SizeOf(TGilQuoteColValues),0);
         if (FCount > 0) and (FDatas <> nil) then
         begin
           CopyMemory(tmpData,FDatas,FCount * SizeOf(TGilQuoteColValues));
         end
         else
         begin
           FCount := 0;
         end;
         //ÊÍ·ÅÄÚ´æ
         FreeDatas;
         FDatas := tmpData;
         for I := 0 to AnsHQColValue.m_lHQColCount - 1 do
         begin
           inc(FCount);
           tmpData := PGilQuoteColValues(int64(FDatas) + FCount * sizeof(TGilQuoteColValues));
           if AnsHQColValue.m_HQColFields[0].m_lFieldWidth = 4 then //4×Ö½Ú
           begin
             pData32 := PGilQuoteColValue32(Int64(@AnsHQColValue.m_pData[0]) + (sizeof(TGilQuoteColValue32)* I));
             tmpData.m_CodeInfo := pData32.m_CodeInfo;
             tmpData.IntValue :=  pData32.m_Value;
           end
           else if AnsHQColValue.m_HQColFields[0].m_lFieldWidth = 8 then
           begin
             pData64 := PGilQuoteColValue64(Int64(@AnsHQColValue.m_pData[0]) + (sizeof(TGilQuoteColValue64)* I));
             tmpData.m_CodeInfo := pData64.m_CodeInfo;
             tmpData.Int64Value :=  pData64.m_Value;
           end
           else
              dec(FCount);
         end;
         inc(FVarCode);
       finally
         EndWrite;
       end;
     end;
  end;

end;

end.
