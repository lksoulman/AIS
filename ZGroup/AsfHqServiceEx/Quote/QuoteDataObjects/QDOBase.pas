unit QDOBase;

interface

uses Windows, Classes, SysUtils, Activex, ComObj, IniFiles, Math, QuoteMngr_TLB,
  QuoteStruct, QuoteConst, QuoteLibrary, IOCPMemory, SyncObjs, QuoteDataMngr,
  GilQuoteStruct, Generics.collections;

type
  // 线程 管理类 读写
  TQuoteSync = class(TAutoIntfObject, IQuoteSync, IQuoteUpdate)
  protected
    FQuoteDataMngr: TQuoteDataMngr;
    FHideProgress: boolean;
    FReadWriteSync: TMultiReadExclusiveWriteSynchronizer;
  public
    constructor Create(QuoteDataMngr: TQuoteDataMngr; const TypeLib: ITypeLib; const DispIntf: TGUID);
    destructor Destroy; override;
    property QuoteDataMngr: TQuoteDataMngr read FQuoteDataMngr write FQuoteDataMngr;
    procedure WriteDebug(const Value: string);
    procedure Progress(const Msg: string; Max, Value: Integer);
    function AppPath: string;
    { IQuoteSync }
    procedure BeginRead; safecall;
    procedure EndRead; safecall;
    { IQuoteUpdate }
    procedure Update(DataType: Integer; Data: Int64; Size: Integer); virtual; safecall;
    procedure BeginWrite; safecall;
    procedure EndWrite; safecall;
    function DataState(State: Integer; var IValue: Int64; var SValue: WideString; var VValue: OleVariant): WideString;
      virtual; safecall;
  end;

implementation

{ TQuoteSync }

procedure TQuoteSync.BeginRead;
begin
  FReadWriteSync.BeginRead;
end;

procedure TQuoteSync.BeginWrite;
begin
  FReadWriteSync.BeginWrite
end;

constructor TQuoteSync.Create(QuoteDataMngr: TQuoteDataMngr; const TypeLib: ITypeLib; const DispIntf: TGUID);
begin
  inherited Create(TypeLib, DispIntf);
  FQuoteDataMngr := QuoteDataMngr;
  FReadWriteSync := TMultiReadExclusiveWriteSynchronizer.Create;
end;

function TQuoteSync.DataState(State: Integer; var IValue: Int64; var SValue: WideString; var VValue: OleVariant)
  : WideString;
begin
  //
end;

destructor TQuoteSync.Destroy;
begin
  if FReadWriteSync <> nil then
  begin
    FReadWriteSync.Free;
    FReadWriteSync := nil;
  end;
  inherited;
end;

procedure TQuoteSync.EndRead;
begin
  FReadWriteSync.EndRead;
end;

procedure TQuoteSync.EndWrite;
begin
  FReadWriteSync.EndWrite;
end;

procedure TQuoteSync.Update(DataType: Integer; Data: Int64; Size: Integer);
begin
  //
end;

procedure TQuoteSync.Progress(const Msg: string; Max, Value: Integer);
begin
  if (QuoteDataMngr <> nil) and not FHideProgress then
    QuoteDataMngr.Progress(Msg, Max, Value);
end;

procedure TQuoteSync.WriteDebug(const Value: string);
begin
  if QuoteDataMngr <> nil then
    QuoteDataMngr.WriteDebug(Value);
end;

function TQuoteSync.AppPath: string;
begin
  if QuoteDataMngr <> nil then
    result := QuoteDataMngr.AppPath
  else
    result := '';
end;

end.
