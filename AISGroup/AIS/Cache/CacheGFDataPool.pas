unit CacheGFDataPool;

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  CommonQueue,
  CacheGFData,
  Generics.Collections;


type

  TCacheGFDataPool = class
  private
    // ���߳���
    FLock: TCSLock;
    // �������ĸ���
    FMaxPoolSize: Integer;
    // ���ݶ���
    FQueue: TQueue<TCacheGFdata>;
  protected
    // ��ն���
    procedure ClearQueue;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ��������
    function Allocate: TCacheGFdata;
    // ��������
    procedure DeAllocate(AData: TCacheGFdata);
  end;

implementation

{ TCacheGFDataPool }

constructor TCacheGFDataPool.Create;
begin
  inherited;
  FMaxPoolSize := 10;
  FLock := TCSLock.Create;
  FQueue := TQueue<TCacheGFdata>.Create;
end;

destructor TCacheGFDataPool.Destroy;
begin
  FQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TCacheGFDataPool.ClearQueue;
var
  LData: TCacheGFData;
begin
  while FQueue.Count > 0 do begin
    LData := FQueue.Dequeue;
    if LData <> nil then begin
      LData.Free;
    end;
  end;
end;

function TCacheGFDataPool.Allocate: TCacheGFdata;
begin
  FLock.Lock;
  try
    if FQueue.Count > 0 then begin
      Result := FQueue.Dequeue;
    end else begin
      Result := TCacheGFdata.Create;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TCacheGFDataPool.DeAllocate(AData: TCacheGFdata);
begin
  if AData = nil then Exit;
  
  FLock.Lock;
  try
    if FQueue.Count < FMaxPoolSize then begin
      FQueue.Enqueue(AData);
    end else begin
      AData.Free;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
