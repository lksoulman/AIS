unit KeyFairyPool;

interface

uses
  Windows,
  Classes,
  SysUtils,
  KeyFairy,
  CommonLock,
  CommonRefCounter,
  Generics.Collections;

type

  // ��Ϊ�����
  TKeyFairyPool = class
  private
    // �߳���
    FLock: TCSLock;
    // ���Ӵ�С
    FPoolSize: Integer;
    // ��Ϊ�������
    FObjectQueue: TQueue<TKeyFairy>;
  protected
    // ��պ��ͷŶ����ж���
    procedure DoClearQueue;
  public
    // ���췽��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ����һ����Ϊ����
    function Allocate: TKeyFairy;
    // ����һ����Ϊ����
    procedure DeAllocate(AObject: TKeyFairy);
  end;

implementation

{ TKeyFairyPool }

constructor TKeyFairyPool.Create;
begin
  inherited;
  FPoolSize := 100;
  FLock := TCSLock.Create;
  FObjectQueue := TQueue<TKeyFairy>.Create;
end;

destructor TKeyFairyPool.Destroy;
begin
  DoClearQueue;
  FObjectQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TKeyFairyPool.DoClearQueue;
var
  LObject: TKeyFairy;
begin
  while self.FObjectQueue.Count > 0 do begin
    LObject := FObjectQueue.Dequeue;
    if LObject <> nil then begin
      LObject.Free;
    end;
  end;
end;

function TKeyFairyPool.Allocate: TKeyFairy;
begin
  FLock.Lock;
  try
    if FObjectQueue.Count > 0 then begin
      Result := FObjectQueue.Dequeue;
    end else begin
      Result := TKeyFairy.Create;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TKeyFairyPool.DeAllocate(AObject: TKeyFairy);
begin
  FLock.Lock;
  try
    if AObject = nil then Exit;
    if FObjectQueue.Count < self.FPoolSize then begin
      FObjectQueue.Enqueue(AObject);
    end else begin
      AObject.Free;
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
