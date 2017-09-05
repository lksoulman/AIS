unit QuoteCodeInfosExImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-28
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  QuoteStruct,
  QuoteCodeInfosEx,
  CommonRefCounter;

type

  TQuoteCodeInfosExImpl = class(TAutoInterfacedObject, IQuoteCodeInfosEx)
  private
    // 数组长度
    FCount: Integer;
    // 数组容量
    FCapacity: Integer;
    // InnerCode 指针数组
    FInnerCodes: TArray<Integer>;
    // CodeInfo 指针数组
    FCodeInfos: TArray<PCodeInfo>;
  protected
    // 设置容量
    procedure NewCapacity(ACapacity: Integer);
  public
    // 构造函数
    constructor Create; override;
    // 析构函数
    destructor Destroy; override;
    // 设置数组大小
    procedure SetCapacity(ACapacity: Integer);
    // 增加元素
    procedure Add(AInnerCode: Integer; APCodeInfo: PCodeInfo);

    { IQuoteCodeInfosEx }

    // 获取个数
    function GetCount: Integer; safecall;
    // 获取 CodeInfo
    function GetCodeInfo(AIndex: Integer): Int64; safecall;
    // 获取 InnerCode
    function GetInnerCode(AIndex: Integer): Integer; safecall;
  end;

implementation

{ TQuoteCodeInfosExImpl }

constructor TQuoteCodeInfosExImpl.Create;
begin
  inherited;
  FCount := 0;
  FCapacity := 0;
end;

destructor TQuoteCodeInfosExImpl.Destroy;
begin

  inherited;
end;

procedure TQuoteCodeInfosExImpl.SetCapacity(ACapacity: Integer);
begin
  if ACapacity < 0 then Exit;
  NewCapacity(ACapacity);
end;

procedure TQuoteCodeInfosExImpl.Add(AInnerCode: Integer; APCodeInfo: PCodeInfo);
begin
  if FCount >= FCapacity then begin
    NewCapacity(FCapacity + 20);
  end;
  FInnerCodes[FCount] := AInnerCode;
  FCodeInfos[FCount] := APCodeInfo;
  Inc(FCount);
end;

procedure TQuoteCodeInfosExImpl.NewCapacity(ACapacity: Integer);
begin
  if ACapacity > FCapacity then begin
    SetLength(FInnerCodes, ACapacity);
    SetLength(FCodeInfos, ACapacity);
    FCapacity := ACapacity;
  end;
end;

function TQuoteCodeInfosExImpl.GetCount: Integer;
begin
  Result := FCount;
end;

function TQuoteCodeInfosExImpl.GetCodeInfo(AIndex: Integer): Int64;
begin
  if (AIndex >= 0) and (AIndex < FCount) then begin
    Result := Int64(FCodeInfos[AIndex]);
  end else begin
    Result := 0;
  end;
end;

function TQuoteCodeInfosExImpl.GetInnerCode(AIndex: Integer): Integer;
begin
  if (AIndex >= 0) and (AIndex < FCount) then begin
    Result := FInnerCodes[AIndex];
  end else begin
    Result := 0;
  end;
end;

end.
