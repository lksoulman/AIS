unit QuoteCodeInfosExImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-28
// Comments��
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
    // ���鳤��
    FCount: Integer;
    // ��������
    FCapacity: Integer;
    // InnerCode ָ������
    FInnerCodes: TArray<Integer>;
    // CodeInfo ָ������
    FCodeInfos: TArray<PCodeInfo>;
  protected
    // ��������
    procedure NewCapacity(ACapacity: Integer);
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
    // ���������С
    procedure SetCapacity(ACapacity: Integer);
    // ����Ԫ��
    procedure Add(AInnerCode: Integer; APCodeInfo: PCodeInfo);

    { IQuoteCodeInfosEx }

    // ��ȡ����
    function GetCount: Integer; safecall;
    // ��ȡ CodeInfo
    function GetCodeInfo(AIndex: Integer): Int64; safecall;
    // ��ȡ InnerCode
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
